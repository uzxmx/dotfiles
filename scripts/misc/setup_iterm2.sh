#!/usr/bin/env bash
#
# Setup iterm2.

set -e

# Specify the preferences directory
defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "$HOME/.dotfiles/iterm2"

# Tell iTerm2 to use the custom preferences in the directory
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true

# Below preferences are not saved to the custom folder by iTerm2, so set them
# explicitly.
#
# Don't merge new windows into tabs automatically.
defaults write com.googlecode.iterm2 AppleWindowTabbingMode -string manual
# Disable scroll animation.
defaults write com.googlecode.iterm2 AppleScrollAnimationEnabled -int 0
defaults write com.googlecode.iterm2 NSScrollAnimationEnabled -bool false
# Don't scroll content under the title bar.
defaults write com.googlecode.iterm2 NSScrollViewShouldScrollUnderTitlebar -bool false
# Enable font smoothing for all font sizes.
defaults write com.googlecode.iterm2 AppleAntiAliasingThreshold -int 1
defaults write com.googlecode.iterm2 AppleSmoothFixedFontsSizeThreshold -int 1
# Disable automatic update checks.
defaults write com.googlecode.iterm2 SUEnableAutomaticChecks -bool false

# Use Symbols Nerd Font (installed by scripts/install/nerd_font) as the
# non-ASCII font, so icons (e.g. in yazi) are displayed while the regular font
# is still used for text.
#
# It's done via iTerm2 Python API rather than editing the plist directly,
# because iTerm2 overwrites the plist with its in-memory preferences. The
# change is applied to all open sessions immediately, and iTerm2 saves it back
# to the plist in the custom folder.
set_iterm2_non_ascii_font() {
  local font="SymbolsNFM"
  local manual_steps="Please set it manually: Settings > Profiles > Text > Use a different font for non-ASCII text > Symbols Nerd Font Mono"

  if [ ! -f ~/Library/Fonts/SymbolsNerdFontMono-Regular.ttf ]; then
    echo "Symbols Nerd Font is not installed, run scripts/install/nerd_font first."
    return
  fi

  if ! pgrep -xq iTerm2; then
    echo "iTerm2 is not running, skipped setting non-ASCII font. $manual_steps"
    return
  fi

  if ! python3 -c "import iterm2" 2>/dev/null; then
    echo "Installing iterm2 Python module..."
    pip3 install iterm2 || { echo "Failed to install iterm2. $manual_steps"; return; }
  fi

  python3 - "$font" << 'EOF' || echo "Failed to set non-ASCII font, is Python API enabled (Settings > General > Magic)? $manual_steps"
import sys
import iterm2

FONT = sys.argv[1]

async def set_font(profile):
    # Keep the same size as the normal font, e.g. "Monaco 14".
    size = profile.normal_font.rsplit(" ", 1)[-1]
    await profile.async_set_use_non_ascii_font(True)
    await profile.async_set_non_ascii_font(f"{FONT} {size}")

async def main(connection):
    # Persist the change in the Default profile.
    for partial in await iterm2.PartialProfile.async_query(connection):
        if partial.name == "Default":
            await set_font(await partial.async_get_full_profile())

    # Sessions whose profile has been modified locally (e.g. by
    # bin/set_color_scheme) don't follow the Default profile, so update them too.
    app = await iterm2.async_get_app(connection)
    for window in app.windows:
        for tab in window.tabs:
            for session in tab.sessions:
                await set_font(await session.async_get_profile())

iterm2.run_until_complete(main)
EOF
}

set_iterm2_non_ascii_font
