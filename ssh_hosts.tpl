// vim: ft=json
//
// This is a template file for `~/.ssh_hosts` which is used when using fzf to select a ssh host.
[
  {
    "label": "user@host"
  },
  {
    "label": "host-with-some-description",
    "host": "host",
    "user": "user"
  },
  {
    "label": "host-with-identity",
    "host": "host",
    "user": "user",
    "identity": "path-to-identity-file"
  },
  {
    "label": "host-with-customized-port-and-command",
    "host": "host",
    "port": 1234,
    "user": "user",
    "command": "auto_mfa -n secret-name -- {{COMMAND}}"
  },
  {
    "label": "host-with-customized-command",
    "host": "host",
    "port": 1234,
    "user": "user",
    "interactive_command": "auto_mfa -n secret-name -c 'expect \"Opt>\"; send \"p\\n\"; expect \"Opt>\"; send \"6\\n\"' -- {{COMMAND}}",
    "noninteractive_command": {
      "template": "auto_mfa -n secret-name -- {{COMMAND}}",
      "ssh_options": ["SetEnv=AssetName=host Interactive=no"]
    }
  }
]
