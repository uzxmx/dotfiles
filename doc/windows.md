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

## CMD

### Show cmd help

```
cmd.exec "/?"
cmd.exec /c start "/?"
```

### Tricks

```
# The output is '%JAVA_HOME%'.
cmd.exe /c "set JAVA_HOME=foo & echo %JAVA_HOME%"

# The output is 'foo'.
cmd.exe /c "set JAVA_HOME=foo & call echo %JAVA_HOME%"
# Above output actually contains a whitespace.
cmd.exe /c "set JAVA_HOME=foo & call echo %JAVA_HOME%" | hexdump -C
# Below output doesn't contain a whitespace.
cmd.exe /c "set JAVA_HOME=foo& call echo %JAVA_HOME%" | hexdump -C

# The output is 'foo'.
cmd.exe /v /c 'set JAVA_HOME=foo & echo !JAVA_HOME!'
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

## nuget

```
nuget.exe restore <path-to-sln>

# Set http proxy. But unsetting config doesn't work. See
# https://github.com/NuGet/Home/issues/8223.
nuget.exe config -set http_proxy=http://example.com
```

## How to type emoji?

Press shortcut key `Win + .` or run `tabtip` command.

## Tricks on Windows programming

### How to check if a dll is registered?

```
reg.exe query 'HKLM\SOFTWARE\Classes' /s /f target.dll
```

Ref: https://serverfault.com/a/709686

### View tracing log (Windows Performance Analyzer)

```
wslsudo wpr.exe -start src/ConsolePerf.wprp -filemode
wslsudo wpr.exe -status

wslsudo wpr.exe -start GeneralProfile -start src/ConsolePerf.wprp -filemode

# Create `terminal.wprp`, `app.wprp` and `connection.wprp` based on `src/ConsolePerf.wprp`.
wslsudo wpr.exe -start terminal.wprp -start app.wprp -start connection.wprp -filemode

# After stopping, use Windows Performance Analyzer to view the collected log.
wslsudo wpr.exe -stop log.etl
```

Ref:
* https://docs.microsoft.com/zh-cn/windows/win32/tracelogging/tracelogging-record-and-display-tracelogging-events
* https://docs.microsoft.com/en-us/windows-hardware/test/wpt/wpr-command-line-options
* https://docs.microsoft.com/en-us/windows-hardware/drivers/devtest/capture-and-view-tracelogging-data

### Show dependencies of some dll

```
PATH="/mnt/c/Program Files (x86)/Microsoft Visual Studio/2019/Community/VC/Tools/MSVC/14.25.28610/bin/Hostx64/x64/:$PATH"
dumpbin.exe /dependents target.dll
```

### Disable compiler warning of something

```
#pragma warning(disable : 4100)
```

### C-string on Windows

| Windows type | Description                                      | C type          |
|--------------|--------------------------------------------------|-----------------|
| LPSTR        | (long) pointer to string                         | char *          |
| LPCSTR       | (long) pointer to constant string                | const char *    |
| LPWSTR       | (long) pointer to Unicode (wide) string          | wchar_t *       |
| LPCWSTR      | (long) pointer to constant Unicode (wide) string | const wchar_t * |
| LPTSTR       | (long) pointer to TCHAR string                   | TCHAR *         |
| LPCTSTR      | (long) pointer to constant TCHAR string          | const TCHAR *   |

Ref: https://stackoverflow.com/a/1200225/5258527

```
const char* c = "Hello";
LPCWSTR str = TEXT("Hello");
LPCWSTR str1 = L"Hello";
LPCWSTR str2 = _T("Hello");
WCHAR    str3[6];
MultiByteToWideChar(0, 0, c, 5, str3, 6);
LPCWSTR cstr4 = str3;
```

### Show a message box

```
MessageBox(nullptr, L"foo", L"bar", MB_OK | MB_ICONERROR);

#include <atlconv.h>  // for CA2W
#include <atlbase.h>
#include <atlstr.h>

// Show a message with a c-string.
char buf[1024];
int index = 1;
sprintf_s(buf, "index: %d", index);
MessageBox(nullptr, CA2W(buf, CP_UTF8), L"bar", MB_OK | MB_ICONERROR);

LPCSTR psz = "foo";
MessageBox(nullptr, CA2W(psz, CP_UTF8), L"", MB_OK | MB_ICONERROR);

// Convert char * to WCHAR * (LPCWSTR)
// Ref: https://docs.microsoft.com/en-us/windows/win32/api/stringapiset/nf-stringapiset-multibytetowidechar
WCHAR wbuf[1024];
MultiByteToWideChar(0, 0, buf, -1, wbuf, 1024);
MessageBox(nullptr, wbuf, L"", MB_OK | MB_ICONERROR);
```

Pty:
https://devblogs.microsoft.com/commandline/windows-command-line-introducing-the-windows-pseudo-console-conpty/

https://github.com/microsoft/terminal/issues/608
https://www.iterm2.com/documentation-escape-codes.html

https://docs.microsoft.com/en-us/visualstudio/msbuild/msbuild-command-line-reference?view=vs-2019

## Notes about Windows Terminal

```
# You may need to pull submodules for the first time.
$ git submodule update --init

# Build through cmd.exe on WSL.
$ cmd.exe

# Setup build environment.
#
# It may fail with vswhere not found, which is caused by unsuccessful
#`nuget.exe restore OpenConsole.sln`. The version of `nuget.exe` located at
# `dep/nuget` may be too old that it fails when parsing `OpenConsole.sln`. So we
# may try to install a latest version by `scoop install nuget`. The version
# 5.6.0 works.
> .\tools\razzle.cmd

# Compile with `bcz` or `bcz no_clean`.
#
# If some error happens, you may need to check `tools/bcz.cmd`. It may be
# because of compilation options. You can manually invoke `msbuild.exe` to see
# if some option works. Pay attention to `/m` option, see if that option works.
#
# If you don't want `msbuild.exe` to show output with color, pass in
# `/clp:"DisableConsoleColor"` option.
#
> bcz

# Run it. If some error happens when running the executable, it may be because
# of dll dependencies issues. Check if there is any dll missing in the target
# folder, e.g. copy `x64/Debug/TerminalConnection/{telnetpp.dll,cpprest142_2_10d.dll}`
# to `src/cascadia/CascadiaPackage/bin/x64/Debug`
#
$ ./src/cascadia/CascadiaPackage/bin/x64/Debug/WindowsTerminal.exe

# Run unit tests
> runut.cmd

# Only Run some tests
> runut.cmd /name:*TestSomething*

# Check code format (On WSL, if some file is corrected, it may be recreated with
# executable permission set, so beware to change the file mode back)
> runformat.cmd
```

For more information, please visit `tools/README.md` in project.

### Generate a dev-build and deploy

Use Visual Studio to open `OpenConsole.sln`, and select `Release | x64 |
CascadiaPackage`, then click menu Generate -> Deploy.

## Render Chinese character using pdflatex

```
# Install `mkfontscale` and `mkfontdir`.
sudo apt-get install -y ttf-mscorefonts-installer

# Install `fc-cache`
sudo apt-get install -y fontconfig

sudo mkdir /usr/share/fonts/myfonts
sudo cp /mnt/c/Windows/Fonts/sim*.ttf /usr/share/fonts/myfonts

cd /usr/share/fonts/myfonts
sudo mkfontscale
sudo mkfontdir
sudo fc-cache -fsv

# Check if font is available
fc-list :lang=zh-cn

xelatex test.tex
```

### Where to find MSYH font

MSYH font may be located at `/mnt/c/Program Files (x86)/Microsoft
Office/root/vfs/Fonts/private/MSYH.TTC` (Although it's a TTC file, it works like
TTF file). If that's not the case, you can use file explorer to search `msyh`
