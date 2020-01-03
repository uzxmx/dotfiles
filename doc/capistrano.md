# Capistrano

## Specify a private key file

```
server host, user: user, roles: options[:roles], port: port, ssh_options: { keys: [File.expand_path('~/.ssh/another-privkey')] }
```
