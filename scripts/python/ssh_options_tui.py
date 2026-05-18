#!/usr/bin/env python3
"""
SSH 选项构建 TUI

run_tui(host_label, initial_opts) → [['-L','spec'], ['-R','spec'], ...]
用户中止时 sys.exit(1)。

扩展：在 run_tui() 的 panels 列表追加新 Panel 即可。
"""

import json
import os
import sys

_dir = os.path.dirname(os.path.realpath(__file__))
if _dir not in sys.path:
    sys.path.insert(0, _dir)

from tui import Panel, TUI


def run_tui(host_label: str, initial_opts=None, ssh_info=None) -> list:
    """
    显示 SSH 选项构建 TUI。

    返回 [['-L', 'spec'], ['-R', 'spec'], ...] 列表；
    用户中止时调用 sys.exit(1)。
    """
    opts = list(initial_opts or [])

    panels = [
        Panel('本地转发  -L', '-L',
              hints=(
                  '你的电脑:本地端口 ──SSH──▶ 远端可达的地址:端口',
                  '场景：访问远端内网数据库、Web 后台等',
                  '格式：[绑定地址:]本地端口:目标主机:目标端口',
              ),
              items=[s for f, s in opts if f == '-L']),
        Panel('远程转发  -R', '-R',
              hints=(
                  '远端服务器:远端端口 ──SSH──▶ 你的电脑:地址:端口',
                  '场景：让远端回连本机服务、内网穿透等',
                  '格式：[绑定地址:]远端端口:本机主机:本机端口',
              ),
              items=[s for f, s in opts if f == '-R']),
    ]

    result = TUI(f'SSH 选项构建 — {host_label}', panels).run()
    return [[flag, item] for flag, item in result]


def main():
    host_label = sys.argv[1] if len(sys.argv) > 1 else 'test-host'
    initial_opts = []
    if len(sys.argv) > 2:
        try:
            initial_opts = json.loads(sys.argv[2])
        except (json.JSONDecodeError, ValueError):
            pass

    opts = run_tui(host_label, initial_opts)
    for args in opts:
        for a in args:
            print(a)


if __name__ == '__main__':
    main()
