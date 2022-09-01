#!/bin/sh

_android_sdk_root="$ANDROID_SDK_ROOT"
if [ -z "$sdk_root" ]; then
  _android_sdk_root="$ANDROID_HOME"
fi
if [ -z "$_android_sdk_root" -o ! -e "$_android_sdk_root" ]; then
  echo "Cannot find Android SDK root directory, please specify it by ANDROID_SDK_ROOT or ANDROID_HOME environment variable."
  exit 1
fi

android_ensure_build_tools_available() {
  local build_tools_dir="$_android_sdk_root/build-tools"
  local choices choice
  choices=$(ls "$build_tools_dir")
  if [ -n "$choices" ]; then
    choice="$(echo "$choices" | fzf --prompt "Select a version for build tools: " -1)"
  fi
  [ -z "$choice" ] && exit
  PATH="$build_tools_dir/$choice:$PATH"
}

# On success, ANDROID_SDK_LLDB_DIR will be set.
android_ensure_lldb_available() {
  local dir="$_android_sdk_root/lldb"
  local choices choice
  choices=$(ls "$dir")
  if [ -n "$choices" ]; then
    choice="$(echo "$choices" | fzf --prompt "Select a version for lldb: " -1)"
  fi
  [ -z "$choice" ] && exit
  ANDROID_SDK_LLDB_DIR="$dir/$choice"
}
