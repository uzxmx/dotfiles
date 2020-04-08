# Windows

## How to reload after updating `/etc/wsl.conf`?

Run `Windows PowerShell` as administrator:

```
Restart-Service -Name "LxssManager"
```

## Restore umask

* Method 1:

  In ~/.bashrc or ~/.zshrc, check and add `umask 002`.

* Method 2:

  Start a session with `wsl.exe -u root -- /bin/login/ -f username`.

  > The side-effect is that specific paths will be removed from PATH environment variable.

  Ref:

  https://github.com/microsoft/WSL/issues/3153#issuecomment-386903821
  https://github.com/microsoft/WSL/issues/352#issuecomment-575421509
