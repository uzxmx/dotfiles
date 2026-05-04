#!/usr/bin/env python3
import json
import os
import shlex
import subprocess
import sys

_PYTHON_DIR = os.path.dirname(os.path.realpath(__file__))
if _PYTHON_DIR not in sys.path:
    sys.path.insert(0, _PYTHON_DIR)

import wrapper

SSH_HOSTS_FILE = os.path.expanduser('~/.ssh_hosts')


def _strip_json_comments(text):
    result = []
    i = 0
    n = len(text)
    in_string = False
    while i < n:
        c = text[i]
        if in_string:
            if c == '\\' and i + 1 < n:
                result.append(c)
                result.append(text[i + 1])
                i += 2
                continue
            if c == '"':
                in_string = False
            result.append(c)
            i += 1
        else:
            if c == '"':
                in_string = True
                result.append(c)
                i += 1
            elif text[i:i + 2] == '//':
                while i < n and text[i] != '\n':
                    i += 1
            elif text[i:i + 2] == '/*':
                i += 2
                while i < n and text[i:i + 2] != '*/':
                    i += 1
                i += 2
            else:
                result.append(c)
                i += 1
    return ''.join(result)


def _strip_trailing_commas(text):
    result = []
    i = 0
    n = len(text)
    in_string = False
    while i < n:
        c = text[i]
        if in_string:
            if c == '\\' and i + 1 < n:
                result.append(c)
                result.append(text[i + 1])
                i += 2
                continue
            if c == '"':
                in_string = False
            result.append(c)
            i += 1
        else:
            if c == '"':
                in_string = True
                result.append(c)
                i += 1
            elif c == ',':
                j = i + 1
                while j < n and text[j] in ' \t\n\r':
                    j += 1
                if j < n and text[j] in '}]':
                    i += 1  # skip trailing comma
                else:
                    result.append(c)
                    i += 1
            else:
                result.append(c)
                i += 1
    return ''.join(result)


def _load_hosts():
    with open(SSH_HOSTS_FILE) as f:
        text = f.read()
    return json.loads(_strip_trailing_commas(_strip_json_comments(text)))


def check_ssh_hosts_file():
    if not os.path.exists(SSH_HOSTS_FILE):
        wrapper.run_original()


def select_host(host_label=None, caller_name=None):
    if not os.path.exists(SSH_HOSTS_FILE):
        wrapper.print_and_exit([os.path.basename(sys.argv[0])], 100)
        return None

    hosts = _load_hosts()

    key = ''
    if host_label is None:
        labels = '\n'.join(h['label'] for h in hosts)
        proc = subprocess.Popen(
            ['fzf', '--expect=ctrl-e'],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
        )
        stdout, _ = proc.communicate(input=labels.encode())
        lines = stdout.decode().splitlines()
        if len(lines) < 2 or not lines[1].strip():
            sys.exit(0)
        key = lines[0].strip()
        host_label = lines[1].strip()

    host = next((h for h in hosts if h['label'] == host_label), None)
    if host is None:
        return None

    if caller_name is None:
        caller_name = os.path.basename(sys.argv[0])

    return HostSelection(key, host, caller_name)


class HostSelection:
    def __init__(self, key, host, caller_name=''):
        self._key = key
        self._host = host
        self.set_interactive(caller_name == 'ssh')

    def set_interactive(self, interactive):
        host = self._host
        if interactive:
            command = host.get('interactive_command') or host.get('command')
        else:
            command = host.get('noninteractive_command') or host.get('command')

        if not isinstance(command, dict):
            command = {'template': command or '{{COMMAND}}'}

        self._command = command

    def get_label(self):
        return self._host['label']

    def get_host(self):
        if 'host' in self._host:
            return self._host['host']
        parts = self._host['label'].split('@', 1)
        return parts[1] if len(parts) == 2 else parts[0]

    def get_port(self):
        port = self._host.get('port')
        return str(port) if port is not None else None

    def get_user(self):
        if 'user' in self._host:
            return self._host['user']
        parts = self._host['label'].split('@', 1)
        return parts[0] if len(parts) == 2 else None

    def get_user_host(self):
        return f"{self.get_user()}@{self.get_host()}"

    def get_identity(self):
        identity = self._host.get('identity')
        return os.path.expanduser(identity) if identity else None

    def get_ssh_options(self):
        return self._command.get('ssh_options')

    def build_command(self, *command):
        template = self._command.get('template', '{{COMMAND}}')
        tokens = shlex.split(template)
        cmd_quoted = ' '.join(shlex.quote(a) for a in command)
        result = []
        for token in tokens:
            if token == '{{COMMAND}}':
                result.extend(command)
            else:
                result.append(token.replace('{{COMMAND_QUOTED}}', cmd_quoted))
        return result

    def run(self, *command):
        cmdline = self.build_command(*command)
        code = 101 if self._key == 'ctrl-e' else 100
        wrapper.print_and_exit(cmdline, code)
