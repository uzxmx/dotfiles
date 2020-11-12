@echo off

if not defined JAVA_HOME (
  if exist "D:\android_studio\jre" (
    set JAVA_HOME=D:\android_studio\jre
  )
)

if defined JAVA_HOME (
  set "PATH=%JAVA_HOME%\bin;%PATH%"
)

if not defined ANDROID_SDK_ROOT (
  if exist "%USERPROFILE%\AppData\Local\Android\Sdk" (
    set "ANDROID_SDK_ROOT=%USERPROFILE%\AppData\Local\Android\Sdk"
  )
)

if defined ANDROID_SDK_ROOT (
  set "PATH=%ANDROID_SDK_ROOT%\tools\bin;%ANDROID_SDK_ROOT%\emulator;%PATH%"
)

cd %USERPROFILE%
