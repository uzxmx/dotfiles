#!/usr/bin/env python3
"""
Xvfb/VNC TUI

run_vnc_tui(host_label, ssh_info) — 显示 VNC display 选择 TUI，
按 Enter 连接后台 VNC 隧道并启动本地 VNC 客户端。
"""

import atexit
import os
import subprocess
import sys
import threading
import time

_dir = os.path.dirname(os.path.realpath(__file__))
if _dir not in sys.path:
    sys.path.insert(0, _dir)

from tui import (Panel, TUI,
                 _at, _w, _cur_hide,
                 str_width, str_clip, str_pad,
                 RESET, BOLD, DIM, GREEN, CYAN, INV)

_VNC_BASE_PORT = 5900


def _build_ssh_cmd(ssh_info, extra_opts=None, remote_cmd=None):
    cmd = ['ssh', '-o', 'BatchMode=yes', '-o', 'ConnectTimeout=5']
    if ssh_info.get('port'):
        cmd += ['-p', str(ssh_info['port'])]
    if ssh_info.get('identity'):
        cmd += ['-i', ssh_info['identity']]
    if extra_opts:
        cmd += extra_opts
    user = ssh_info.get('user')
    host = ssh_info.get('host', '')
    cmd.append(f'{user}@{host}' if user else host)
    if remote_cmd:
        cmd.append(remote_cmd)
    return cmd


def _query_xvfb_displays(ssh_info):
    """返回服务端 Xvfb display 列表，如 [':0', ':1']，失败时返回 []。"""
    cmd = _build_ssh_cmd(
        ssh_info,
        remote_cmd="ls /tmp/.X[0-9]*-lock 2>/dev/null | sed 's|/tmp/.X||;s|-lock||' | sort -n",
    )
    try:
        out = subprocess.check_output(cmd, timeout=5, stderr=subprocess.DEVNULL)
        return [f':{n.strip()}' for n in out.decode().splitlines() if n.strip().isdigit()]
    except Exception:
        return []


class _XvfbTUI(TUI):
    """单面板 VNC TUI：固定焦点，无输入框，无确认键。"""

    _XVFB_IDX = 0

    def __init__(self, title, panels, ssh_info):
        super().__init__(title, panels)
        self.active = 0
        self._ssh_info = ssh_info
        self._connected = {}
        self._next_port = _VNC_BASE_PORT

    def _render(self, rows, cols):
        buf = []

        header = f' {self.title} '
        hcol = max(1, (cols - str_width(header)) // 2 + 1)
        buf.append(_at(1, 1) + ' ' * cols)
        buf.append(_at(1, hcol) + CYAN + BOLD + str_clip(header, cols - hcol + 1) + RESET)

        self._render_panel(buf, self.panels[0], 2, 1, rows - 2, cols, True)

        status = ' [↑↓] 选择  [Enter] 连接  [q] 退出 '
        buf.append(_at(rows, 1) + INV + str_pad(str_clip(status, cols), cols) + RESET)
        buf.append(_cur_hide())

        _w(''.join(buf))

    def _render_panel(self, buf, panel, r1, c1, ph, pw, active):
        inner = pw - 2
        bc = GREEN + BOLD

        def put(dr, dc, text, attr=''):
            buf.append(_at(r1 + dr, c1 + dc) + attr + text + RESET)

        title = f' {panel.title} '
        tw = str_width(title)
        put(0, 0, str_clip('┌' + title + '─' * max(0, inner - tw) + '┐', pw), bc)

        nh = len(panel.hints)
        for i, hint in enumerate(panel.hints):
            put(1 + i, 0, '│', bc)
            put(1 + i, 1, str_pad(str_clip(' ' + hint, inner), inner), DIM)
            put(1 + i, pw - 1, '│', bc)

        list_h = max(0, ph - 2 - nh)
        for i in range(list_h):
            row = 1 + nh + i
            put(row, 0, '│', bc)
            if i < len(panel.items):
                text = f' {i + 1}.  {panel.items[i]}'
                attr = INV if i == panel.sel else ''
                put(row, 1, str_pad(str_clip(text, inner), inner), attr)
            else:
                put(row, 1, ' ' * inner)
            put(row, pw - 1, '│', bc)

        put(ph - 1, 0, '└' + '─' * inner + '┘', bc)

    def _handle(self, key, rows, cols):
        if key is None or isinstance(key, tuple):
            return

        p = self.panels[0]

        if key in ('q', 'Q', 'QUIT', 'ESC'):
            self._abort = True
            self._done = True
        elif key == 'UP':
            if p.sel > 0:
                p.sel -= 1
        elif key == 'DOWN':
            if p.sel < len(p.items) - 1:
                p.sel += 1
        elif key == 'ENTER':
            if p.items:
                base = p.items[p.sel].split()[0]
                if base not in self._connected and self._ssh_info:
                    self._start_vnc(p, p.sel, base)

    def _start_vnc(self, panel, idx, display):
        port = self._next_port
        self._next_port += 1
        self._connected[display] = port

        # Synchronous item update — visible on the very next render cycle
        panel.items[idx] = f'{display}  →  :{port}'

        ssh_info = self._ssh_info

        # Popen is non-blocking — start both processes synchronously so atexit
        # handlers are registered in the main thread before TUI can exit.
        tunnel_proc = subprocess.Popen(
            _build_ssh_cmd(ssh_info, extra_opts=['-L', f'{port}:localhost:{port}', '-N']),
            stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
        )
        atexit.register(tunnel_proc.terminate)

        # Wrap x11vnc with a trap so the remote process is killed when the SSH
        # session ends (sshd sends SIGHUP to the remote shell on disconnect).
        vnc_proc = subprocess.Popen(
            _build_ssh_cmd(
                ssh_info,
                remote_cmd=(
                    f'bash -c \'trap "kill 0" HUP TERM INT EXIT;'
                    f' x11vnc -display {display} -nopw -rfbport {port} 2>/dev/null\''
                ),
            ),
            stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
        )
        atexit.register(vnc_proc.terminate)

        # Open local VNC client after a short delay (daemon thread — no cleanup needed)
        def _open_vnc():
            time.sleep(3)
            vnc_bin = '/Applications/VNC Viewer.app/Contents/MacOS/vncviewer'
            if os.path.exists(vnc_bin):
                subprocess.Popen([vnc_bin, f'localhost::{port}'],
                                  stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            else:
                subprocess.Popen(['open', f'vnc://localhost:{port}'],
                                  stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

        threading.Thread(target=_open_vnc, daemon=True).start()


def run_vnc_tui(host_label: str, ssh_info=None) -> None:
    xvfb_items = _query_xvfb_displays(ssh_info) if ssh_info else []
    vnc_panel = Panel(
        'Xvfb → VNC', '--vnc',
        hints=(
            '↑↓ 选中 display，Enter 立即后台连接（可多次）',
            f'每个 display 自动分配独立本地端口（{_VNC_BASE_PORT}++）',
        ),
        items=xvfb_items,
    )
    _XvfbTUI(f'VNC — {host_label}', [vnc_panel], ssh_info).run()


def main():
    host_label = sys.argv[1] if len(sys.argv) > 1 else 'test-host'
    run_vnc_tui(host_label)


if __name__ == '__main__':
    main()
