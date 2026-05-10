#!/usr/bin/env python3
"""
通用终端 UI 组件库

提供：
  LineEditor  — 带光标的单行编辑器（left/right/home/end/kill 等）
  Panel       — 带 hints / items / 输入框的列表面板
  TUI         — 多面板网格（ANSI + termios，不依赖 curses）

用法示例::

    from tui import Panel, TUI

    panels = [
        Panel('选项 A', 'a', hints=('说明文字',)),
        Panel('选项 B', 'b'),
    ]
    results = TUI('我的工具标题', panels).run()
    # → [['a', 'item1'], ['b', 'item2'], ...]
"""

import select
import struct
import sys
import termios
import tty
import unicodedata

# ── /dev/tty I/O ─────────────────────────────────────────────────────────────

_tty = None


def _get_tty():
    global _tty
    if _tty is None:
        _tty = open('/dev/tty', 'r+b', buffering=0)
    return _tty


def _w(s: str):
    t = _get_tty()
    t.write(s.encode('utf-8'))
    t.flush()


def term_size() -> tuple[int, int]:
    """返回终端 (rows, cols)，无法获取时回退到 (24, 80)。"""
    import fcntl
    try:
        data = fcntl.ioctl(_get_tty().fileno(), termios.TIOCGWINSZ, b'\0' * 8)
        r, c = struct.unpack('HHHH', data)[:2]
        return max(r, 8), max(c, 40)
    except Exception:
        return 24, 80


# ── ANSI ──────────────────────────────────────────────────────────────────────

def _at(r, c):   return f'\033[{r};{c}H'
def _alt_on():   return '\033[?1049h'
def _alt_off():  return '\033[?1049l'
def _cur_hide(): return '\033[?25l'
def _cur_show(): return '\033[?25h'
def _mouse_on():  return '\033[?1000h\033[?1006h'
def _mouse_off(): return '\033[?1000l\033[?1006l'

RESET = '\033[0m'
BOLD  = '\033[1m'
DIM   = '\033[2m'
GREEN = '\033[32m'
CYAN  = '\033[36m'
INV   = '\033[7m'


# ── 宽字符工具 ────────────────────────────────────────────────────────────────

def str_width(s: str) -> int:
    """字符串显示宽度（CJK 宽字符计 2 列）。"""
    return sum(2 if unicodedata.east_asian_width(c) in ('W', 'F') else 1
               for c in s)


def str_clip(s: str, cols: int) -> str:
    """裁剪字符串到 cols 显示列（避免宽字符截断为半个）。"""
    w = 0
    for i, c in enumerate(s):
        cw = 2 if unicodedata.east_asian_width(c) in ('W', 'F') else 1
        if w + cw > cols:
            return s[:i]
        w += cw
    return s


def str_pad(s: str, cols: int) -> str:
    """右填充到 cols 显示列。"""
    return s + ' ' * max(0, cols - str_width(s))


# ── 读键 ──────────────────────────────────────────────────────────────────────

def _read_byte(timeout=0.05):
    t = _get_tty()
    r, _, _ = select.select([t], [], [], timeout)
    return t.read(1) if r else None


def read_key():
    """
    从 /dev/tty 读取一个按键事件。

    返回：
      - 字符串：'UP' 'DOWN' 'LEFT' 'RIGHT' 'HOME' 'END' 'DEL' 'BS'
                'TAB' 'BTAB' 'ENTER' 'ESC' 'QUIT'
                'CTRL_A' 'CTRL_E' 'CTRL_K' 'CTRL_U' 'CTRL_W'
                或单个可打印字符
      - 元组：('CLICK', row, col)  左键按下，坐标 1-indexed
      - None：无法识别的序列
    """
    ch = _get_tty().read(1)
    if ch == b'\x1b':
        b1 = _read_byte()
        if b1 == b'[':
            b2 = _read_byte()
            if b2 == b'A': return 'UP'
            if b2 == b'B': return 'DOWN'
            if b2 == b'C': return 'RIGHT'
            if b2 == b'D': return 'LEFT'
            if b2 == b'H': return 'HOME'
            if b2 == b'F': return 'END'
            if b2 == b'Z': return 'BTAB'
            if b2 == b'1': _read_byte(); return 'HOME'   # \033[1~
            if b2 == b'3': _read_byte(); return 'DEL'    # \033[3~
            if b2 == b'4': _read_byte(); return 'END'    # \033[4~
            if b2 == b'<':                                # SGR 鼠标
                seq = b''
                while True:
                    b = _read_byte(0.1)
                    if not b:
                        break
                    seq += b
                    if b in (b'M', b'm'):
                        break
                try:
                    btn, col, row = (int(x) for x in seq[:-1].split(b';'))
                    if seq[-1:] == b'M' and btn == 0:
                        return ('CLICK', row, col)
                except Exception:
                    pass
                return None
        return 'ESC'
    if ch in (b'\x7f', b'\x08'): return 'BS'
    if ch == b'\t':               return 'TAB'
    if ch in (b'\r', b'\n'):     return 'ENTER'
    if ch == b'\x01':             return 'CTRL_A'
    if ch == b'\x05':             return 'CTRL_E'
    if ch == b'\x0b':             return 'CTRL_K'
    if ch == b'\x15':             return 'CTRL_U'
    if ch == b'\x17':             return 'CTRL_W'
    if ch == b'\x03':             return 'QUIT'
    try:
        return ch.decode('utf-8') if ch else None
    except Exception:
        return None


# ── LineEditor ────────────────────────────────────────────────────────────────

class LineEditor:
    """
    单行文本编辑器，跟踪文本内容与光标位置，可被任意输入框复用。

    约定：text 内容为纯 ASCII（不处理 CJK 宽字符），
          光标 pos 是字节/字符索引（0 = 最左，len(text) = 最右）。
    """

    def __init__(self, text: str = ''):
        self.text = text
        self.pos  = len(text)

    @property
    def value(self) -> str:
        return self.text

    def display(self, width: int) -> tuple[str, int]:
        """
        返回 (visible_text, cursor_col_in_visible)，
        将文本裁窗到 width 列以保持光标始终可见。
        """
        start = max(0, self.pos - width + 1)
        return self.text[start:start + width], self.pos - start

    # ── 编辑操作 ──────────────────────────────────────────────────────────────

    def insert(self, ch: str):
        self.text = self.text[:self.pos] + ch + self.text[self.pos:]
        self.pos += len(ch)

    def backspace(self):
        if self.pos > 0:
            self.text = self.text[:self.pos - 1] + self.text[self.pos:]
            self.pos -= 1

    def delete(self):
        if self.pos < len(self.text):
            self.text = self.text[:self.pos] + self.text[self.pos + 1:]

    def left(self):
        if self.pos > 0:
            self.pos -= 1

    def right(self):
        if self.pos < len(self.text):
            self.pos += 1

    def home(self):
        self.pos = 0

    def end(self):
        self.pos = len(self.text)

    def kill_to_end(self):
        self.text = self.text[:self.pos]

    def kill_to_start(self):
        self.text = self.text[self.pos:]
        self.pos  = 0

    def kill_word_back(self):
        p = self.pos
        while p > 0 and self.text[p - 1] == ' ':
            p -= 1
        while p > 0 and self.text[p - 1] != ' ':
            p -= 1
        self.text = self.text[:p] + self.text[self.pos:]
        self.pos  = p

    def clear(self):
        self.text = ''
        self.pos  = 0


# ── Panel ─────────────────────────────────────────────────────────────────────

class Panel:
    """
    带 hints / items 列表与单行输入框的面板。

    Attributes:
        title   显示在边框标题中的文字
        key     面板的标识键（如 '-L'），run() 结果中用作前缀
        hints   顶部说明行（dim 样式），tuple[str]
        items   已配置的条目列表
        sel     当前选中条目的索引
        editor  输入框的 LineEditor 实例
    """

    def __init__(self, title: str, key: str,
                 hints: tuple[str, ...] = (), items=None):
        self.title  = title
        self.key    = key
        self.hints  = hints
        self.items  = list(items or [])
        self.sel    = 0
        self.editor = LineEditor()

    def add(self, spec: str):
        spec = spec.strip()
        if spec:
            self.items.append(spec)
            self.sel = len(self.items) - 1

    def delete_sel(self):
        if self.items and 0 <= self.sel < len(self.items):
            self.items.pop(self.sel)
            self.sel = min(self.sel, max(0, len(self.items) - 1))


# ── TUI ───────────────────────────────────────────────────────────────────────

_PROMPT = '> '


class TUI:
    """
    多面板网格 TUI。

    - 2 列布局，每行面板固定占可用高度的一半（留余量给后续扩展）
    - 鼠标点击选中面板；Tab / Shift-Tab 切换；Esc 取消焦点
    - 'c' 确认退出，'q' 中止退出（sys.exit(1)）

    Args:
        title   显示在顶部居中标题栏的文字
        panels  Panel 列表
    """

    def __init__(self, title: str, panels: list[Panel]):
        self.title  = title
        self.panels = panels
        self.active = -1      # -1 = 无焦点
        self._done  = False
        self._abort = False

    # ── 运行 ──────────────────────────────────────────────────────────────────

    def run(self) -> list:
        """
        进入 TUI 主循环。

        返回 [[panel.key, item], ...] 列表（所有面板合并）。
        用户按 'q' / Ctrl-C 时调用 sys.exit(1)。
        """
        fd  = _get_tty().fileno()
        old = termios.tcgetattr(fd)
        try:
            tty.setraw(fd)
            _w(_alt_on() + _cur_hide() + _mouse_on())
            while not self._done:
                rows, cols = term_size()
                self._render(rows, cols)
                self._handle(read_key(), rows, cols)
        finally:
            _w(_mouse_off() + _alt_off() + _cur_show())
            termios.tcsetattr(fd, termios.TCSADRAIN, old)

        if self._abort:
            sys.exit(1)

        return [[p.key, item] for p in self.panels for item in p.items]

    # ── 布局 ──────────────────────────────────────────────────────────────────

    def _layout(self, rows, cols) -> tuple[int, int, int, int]:
        """返回 (panel_cols, panel_rows, panel_h, panel_w)。"""
        n  = len(self.panels)
        pc = min(n, 2)
        pr = (n + pc - 1) // pc
        ph = max(8, (rows - 2) // 2)   # 固定半屏高
        pw = cols // pc
        return pc, pr, ph, pw

    def _rect(self, idx, rows, cols) -> tuple[int, int, int, int]:
        """返回第 idx 面板的 (row1, col1, ph, pw)，1-indexed。"""
        pc, pr, ph, pw = self._layout(rows, cols)
        r, c = divmod(idx, pc)
        row1 = 2 + r * ph
        col1 = c * pw + 1
        apw  = pw if c < pc - 1 else cols - col1 + 1
        return row1, col1, ph, apw

    # ── 渲染 ──────────────────────────────────────────────────────────────────

    def _render(self, rows, cols):
        buf = []

        # 标题行
        header = f' {self.title} '
        hcol   = max(1, (cols - str_width(header)) // 2 + 1)
        buf.append(_at(1, 1) + ' ' * cols)
        buf.append(_at(1, hcol) + CYAN + BOLD +
                   str_clip(header, cols - hcol + 1) + RESET)

        # 面板
        for i, panel in enumerate(self.panels):
            r1, c1, ph, pw = self._rect(i, rows, cols)
            self._render_panel(buf, panel, r1, c1, ph, pw, i == self.active)

        # 状态栏
        if self.active == -1:
            status = ' [Tab] 选择面板  [c] 确认  [q] 退出 '
        else:
            status = (' [Tab] 切换面板  [↑↓] 选择  [Delete] 删除  '
                      '[Enter] 添加  [Esc] 取消焦点  [c] 确认  [q] 退出 ')
        buf.append(_at(rows, 1) + INV +
                   str_pad(str_clip(status, cols), cols) + RESET)

        # 光标
        if self.active >= 0:
            ap = self.panels[self.active]
            r1, c1, ph, pw = self._rect(self.active, rows, cols)
            inp_w = (pw - 2) - len(_PROMPT)
            _, vis_cur = ap.editor.display(inp_w)
            cur_r = r1 + ph - 2
            cur_c = c1 + 1 + len(_PROMPT) + vis_cur
            buf.append(_cur_show() + _at(cur_r, min(cur_c, c1 + pw - 2)))
        else:
            buf.append(_cur_hide())

        _w(''.join(buf))

    def _render_panel(self, buf, panel, r1, c1, ph, pw, active):
        inner = pw - 2
        bc    = (GREEN + BOLD) if active else DIM

        def put(dr, dc, text, attr=''):
            buf.append(_at(r1 + dr, c1 + dc) + attr + text + RESET)

        # 上边框
        title = f' {panel.title} '
        tw    = str_width(title)
        put(0, 0, str_clip('┌' + title + '─' * max(0, inner - tw) + '┐', pw), bc)

        # hints 行
        nh = len(panel.hints)
        for i, hint in enumerate(panel.hints):
            put(1 + i, 0, '│', bc)
            put(1 + i, 1, str_pad(str_clip(' ' + hint, inner), inner), DIM)
            put(1 + i, pw - 1, '│', bc)

        # 条目列表
        list_h = max(0, ph - 4 - nh)
        for i in range(list_h):
            row = 1 + nh + i
            put(row, 0, '│', bc)
            if i < len(panel.items):
                text = f' {i + 1}.  {panel.items[i]}'
                attr = INV if (active and i == panel.sel) else ''
                put(row, 1, str_pad(str_clip(text, inner), inner), attr)
            else:
                put(row, 1, ' ' * inner)
            put(row, pw - 1, '│', bc)

        # 分割线
        label = ' 添加 '
        lw    = str_width(label)
        sep   = '├──' + label + '─' * max(0, inner - 2 - lw) + '┤'
        put(ph - 3, 0, str_clip(sep, pw), bc)

        # 输入框
        put(ph - 2, 0, '│', bc)
        vis_text, _ = panel.editor.display(inner - len(_PROMPT))
        put(ph - 2, 1, str_pad(_PROMPT + vis_text, inner),
            BOLD if active else '')
        put(ph - 2, pw - 1, '│', bc)

        # 下边框
        put(ph - 1, 0, '└' + '─' * inner + '┘', bc)

    # ── 事件处理 ──────────────────────────────────────────────────────────────

    def _panel_at(self, row, col, rows, cols) -> int:
        for i in range(len(self.panels)):
            r1, c1, ph, pw = self._rect(i, rows, cols)
            if r1 <= row < r1 + ph and c1 <= col < c1 + pw:
                return i
        return -1

    def _handle(self, key, rows: int, cols: int):
        if key is None:
            return

        if isinstance(key, tuple) and key[0] == 'CLICK':
            _, row, col = key
            self.active = self._panel_at(row, col, rows, cols)
            return

        if self.active == -1:
            if key in ('q', 'Q', 'QUIT'):
                self._abort = True
                self._done  = True
            elif key in ('c', 'C'):
                self._done = True
            elif key == 'TAB':
                self.active = 0
            elif key == 'BTAB':
                self.active = len(self.panels) - 1
            return

        p = self.panels[self.active]

        if key in ('q', 'Q', 'QUIT'):
            self._abort = True
            self._done  = True
        elif key == 'ESC':
            self.active = -1
        elif key in ('c', 'C'):
            self._done = True
        elif key == 'TAB':
            self.active = (self.active + 1) % len(self.panels)
        elif key == 'BTAB':
            self.active = (self.active - 1) % len(self.panels)
        elif key == 'UP':
            if p.sel > 0:
                p.sel -= 1
        elif key == 'DOWN':
            if p.sel < len(p.items) - 1:
                p.sel += 1
        elif key == 'LEFT':              p.editor.left()
        elif key == 'RIGHT':             p.editor.right()
        elif key in ('HOME', 'CTRL_A'): p.editor.home()
        elif key in ('END',  'CTRL_E'): p.editor.end()
        elif key == 'CTRL_K':            p.editor.kill_to_end()
        elif key == 'CTRL_U':            p.editor.kill_to_start()
        elif key == 'CTRL_W':            p.editor.kill_word_back()
        elif key == 'DEL':
            if p.editor.text:
                p.editor.delete()
            else:
                p.delete_sel()
        elif key == 'BS':
            if p.editor.text:
                p.editor.backspace()
            else:
                p.delete_sel()
        elif key == 'ENTER':
            if p.editor.value.strip():
                p.add(p.editor.value)
                p.editor.clear()
        elif isinstance(key, str) and len(key) == 1 and ord(key) >= 32:
            p.editor.insert(key)
