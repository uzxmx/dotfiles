# My Dotfiles

![screenshot](images/screenshot.png)

This repository contains configurations and scripts to help setup development environment
quickly in different systems (Mac OSX, Centos, Ubuntu) and ease development. It aims for
developers who are using tmux, zsh, (neo)vim, and programming languages like C/C++,
Ruby, Python, Java, Golang etc in their daily tasks.

## Installation

This repository provides a one-stop setup script. It aims to:

* __Allow to customize (e.g. where to install the repository, and which tools
  (called pods) to setup)__.

* __Try to leave footprints as few as possible on the target system__.

* __Be free to only use one or several pods__.

To setup one or more pods, use below commands as a reference.

For a list of available pods, please visit [here](scripts/bootstrap/pods).

```sh
# Show help.
$ curl -s "https://raw.githubusercontent.com/uzxmx/dotfiles/master/scripts/bootstrap/setup" \
    | bash -s -- -h

# Install the repository into ~/tmp/dotfiles with shallow clone.
$ curl -s "https://raw.githubusercontent.com/uzxmx/dotfiles/master/scripts/bootstrap/setup" \
    | bash -s -- --root /tmp/.dotfiles --git-clone-args "--depth 1"

# Setup tmux.
$ curl -s "https://raw.githubusercontent.com/uzxmx/dotfiles/master/scripts/bootstrap/setup" \
    | bash -s -- prerequisites rcm tmux

# Setup fzf.
$ curl -s "https://raw.githubusercontent.com/uzxmx/dotfiles/master/scripts/bootstrap/setup" \
    | bash -s -- fzf
```

## Setup for Mac OSX

```
# Check if `ApplePressAndHoldEnabled` is turned off.
defaults read -g ApplePressAndHoldEnabled

# Turn off `ApplePressAndHoldEnabled` to enable key-repeat.
# After this, we need to log out and log in again or restart the machine.
# Ref: https://macos-defaults.com/misc/applepressandholdenabled.html
defaults write -g ApplePressAndHoldEnabled -bool false
```

Install `iTerm2`, and run below command to configure.

```
$DOTFILES_DIR/scripts/misc/setup_iterm2.sh
```

Install `homebrew`, and then install below dependencies.

```
brew install pkg-config
brew install gnu-sed
brew install coreutils
# brew install openssl@1.1
brew install openssl
brew install rar
```

Install `vscode`, and run below command to configure.

```
vscode rcup
```

## NeoVim

When you execute `vi` for the first time, `vim-plug` will be automatically installed and then plugins
will also be installed. You can also use `:PlugInstall` to make sure plugins installed manually.

## Guidelines

For fast zsh loading, prefer to add commands under `bin/` directory, rather than in `zshrc` file. You
can use `scripts/misc/benchmark_zsh_startup_time` to check zsh startup time.

## Some helpful dotfiles repos

* https://github.com/dhruvasagar/dotfiles
* https://github.com/Stratus3D/dotfiles
* https://github.com/joshukraine/dotfiles
* https://github.com/docwhat/dotfiles
* https://github.com/caarlos0/dotfiles
* https://github.com/paulirish/dotfiles

## License

[MIT License](LICENSE)
