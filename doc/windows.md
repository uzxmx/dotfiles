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

  Start a session with `wsl.exe -u root -- /bin/login -f username`.

  > The side-effect is that specific paths will be removed from PATH environment variable.

  Ref:

  https://github.com/microsoft/WSL/issues/3153#issuecomment-386903821
  https://github.com/microsoft/WSL/issues/352#issuecomment-575421509

## Show cmd help

```
cmd.exec "/?"
cmd.exec /c start "/?"
```

## Get clipboard content

```
powershell.exe -command "Get-Clipboard"
```

## Run vagrant from WSL

If you use VirtualBox as provider, be sure to add VirtualBox path to PATH environment variable like:

```
export PATH="$PATH:/mnt/c/Program Files/Oracle/VirtualBox"
```

Ref: https://www.vagrantup.com/docs/other/wsl.html

## Chocolatey

```
wslsudo choco.exe uninstall <package>
```

## Scoop

```
# Check package version
cd <path-to-main-bucket>
powershell.exe -command "$(wslpath -w bin/checkver.ps1)" <package>
powershell.exe -command "$(wslpath -w bin/checkver.ps1)" <package> -f

# Show proxy config
scoop config proxy
# Set proxy, don't prefix with http/https
scoop config proxy localhost:8123
# Remove proxy config
scoop config rm proxy

# Install from WSL
scoop install "$(wslpath -w app.json)"
# Install from remote manifest
scoop install https://raw.githubusercontent.com/app.json
powershell.exe -command scoop install https://raw.githubusercontent.com/app.json
```
