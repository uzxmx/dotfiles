#!/usr/bin/env bash
#
# Install GNU binutils (https://www.gnu.org/software/binutils/binutils.html).
#
# TODO merge with ./binutils-for-osx.sh

set -eo pipefail

export DOTFILES_DIR="${DOTFILES_DIR:-$(cd -- "$(dirname "$0")/../.." &>/dev/null && pwd -P)}"
export DOTFILES_TARGET_DIR="${DOTFILES_TARGET_DIR:-$HOME}"

version="2.39"
temp_dir=/tmp/binutils

usage() {
  cat <<-EOF
Usage: $0 [version]

Install GNU binutils.

Options:
  --host <host>  The system that is going to run the software once it is built, e.g. arm-linux-gnueabi
                 Note: toolchains have a loose name convention like arch[-vendor][-os]-abi.
                 Visit https://stackoverflow.com/a/13798214 for more info.

  --target <target> The system against which the software being built will run on
                    E.g. x86_64-unknown-linux-gnu, arm-linux-gnueabi
                    Note: toolchains have a loose name convention like arch[-vendor][-os]-abi.
                    Visit https://stackoverflow.com/a/13798214 for more info.

  --temp-dir <dir> Temp dir to store the src and build files, default is '/tmp/binutils'

Examples:
  # Build binutils which runs on current system, but can build linux app with arm arch.
  $> $0 --target arm-linux-gnueabi
EOF
  exit 1
}

parse_args="
  --host)
    shift
    host=\"\$1\"
    ;;
  --target)
    shift
    target=\"\$1\"
    ;;
  --temp-dir)
    shift
    temp_dir=\"\$1\"
    ;;
  -*)
    usage
    ;;
  *)
    version=\"\$1\"
    ;;
"

source "$DOTFILES_DIR/scripts/lib/install.sh"

dest_path="$DOTFILES_TARGET_DIR/opt/binutils-$version"
[ -d "$dest_path/bin" ] && exit

install_fn() {
  local dir="$(find "$1" -maxdepth 1 -type d | grep -v '^\.$' | tail -1)"
  cd "$dir"

  local build_dir
  if [ -n "$target" ]; then
    build_dir="-$target"
  fi
  if [ -n "$host" ]; then
    build_dir="build-$host$build_dir"
  else
    build_dir="build$build_dir"
  fi
  mkdir -p "$build_dir"
  cd "$build_dir"

  if [ ! -e Makefile ]; then
    local -a opts
    if [ -n "$host" ]; then
      opts+=("--host=$host")
    fi
    if [ -n "$target" ]; then
      opts+=("--target=$target")
    fi
    ../configure --prefix="$dest_path" "${opts[@]}"
  fi

  make -j$(nproc)
  make install
}

download_and_install "https://mirrors.tuna.tsinghua.edu.cn/gnu/binutils/binutils-$version.tar.xz" install_fn "$temp_dir"
