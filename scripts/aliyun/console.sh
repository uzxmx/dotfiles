source "$aliyun_dir/common.sh"

CONSOLE_DIR="$aliyun_dir/console"
KEYCHAIN_SERVICE="aliyun-console"
CONSOLE_PROFILES_FILE="$HOME/.aliyun/console_profiles"
NODE_GLOBAL_MODULES="$(npm root -g 2>/dev/null)"

usage_console() {
  cat <<-EOF
Usage: aliyun console [subcommand] [profile]

Subcommands:
  setup [profile]  - save login credentials to macOS Keychain (one-time per profile)
  open  [profile]  - launch browser and auto-login (default)
  show  [profile]  - display stored credentials for a profile

If no profile is given, an interactive selector (fzf) is shown.
EOF
  exit 1
}

_kset() {
  security add-generic-password -U \
    -s "$KEYCHAIN_SERVICE" -a "${1}__${2}" -w "$3" 2>/dev/null
}

_kget() {
  security find-generic-password -s "$KEYCHAIN_SERVICE" -a "${1}__${2}" -w 2>/dev/null
}

_select_console_profile() {
  [ -f "$CONSOLE_PROFILES_FILE" ] || { echo "No profiles found. Run: aliyun console setup <profile>" >&2; exit 1; }
  fzf < "$CONSOLE_PROFILES_FILE"
}

_add_console_profile() {
  local profile_name="$1"
  touch "$CONSOLE_PROFILES_FILE"
  grep -qxF "$profile_name" "$CONSOLE_PROFILES_FILE" || echo "$profile_name" >> "$CONSOLE_PROFILES_FILE"
}

usage_console_setup() {
  cat <<-EOF
Usage: aliyun console setup [profile]

Save login credentials for a console profile to macOS Keychain.
If no profile is given, you will be prompted to enter a name.
EOF
  exit 1
}

cmd_console_setup() {
  [ "${1:-}" = "-h" ] && usage_console_setup
  local profile_name="$1"

  if [ -z "$profile_name" ]; then
    printf 'Profile name: '
    read -r profile_name
  fi
  [ -z "$profile_name" ] && exit 1

  printf 'Username: '
  read -r username

  printf 'Password: '
  read -rs password
  echo

  printf 'TOTP seed (leave blank if no MFA): '
  read -rs totp_seed
  echo

  if [ -n "$totp_seed" ]; then
    _totp_code() {
      local seed="$1"
      if command -v oathtool &>/dev/null; then
        oathtool --totp --base32 "$seed" 2>/dev/null
      else
        python3 - "$seed" <<'PYEOF'
import sys, hmac, hashlib, struct, time, base64
seed = sys.argv[1]
pad = (8 - len(seed) % 8) % 8
key = base64.b32decode(seed.upper() + '=' * pad)
t = int(time.time()) // 30
msg = struct.pack('>Q', t)
h = hmac.new(key, msg, hashlib.sha1).digest()
o = h[19] & 0xf
code = (struct.unpack('>I', h[o:o+4])[0] & 0x7fffffff) % 1000000
print(f'{code:06d}')
PYEOF
      fi
    }

    echo "Verifying TOTP seed — press Enter to refresh, type y to confirm:"
    while true; do
      local code remaining
      code=$(_totp_code "$totp_seed")
      remaining=$((30 - $(date +%s) % 30))
      printf '  TOTP code: \033[1;32m%s\033[0m  (%ds remaining)\n' "$code" "$remaining"
      printf '  Correct? [y=confirm / Enter=refresh]: '
      read -r answer
      case "$answer" in
        y|Y|yes|YES) break ;;
      esac
    done
  fi

  _kset "$profile_name" username "$username"
  _kset "$profile_name" password "$password"
  [ -n "$totp_seed" ] && _kset "$profile_name" totp_seed "$totp_seed"
  _add_console_profile "$profile_name"

  echo "Saved to Keychain for profile: $profile_name"
}

cmd_console_open() {
  local profile_name="$1"
  if [ -z "$profile_name" ]; then
    profile_name="$(_select_console_profile)"
  fi
  [ -z "$profile_name" ] && exit 1

  local username password totp_seed
  username="$(_kget "$profile_name" username)"
  password="$(_kget "$profile_name" password)"
  totp_seed="$(_kget "$profile_name" totp_seed)" || true

  if [ -z "$username" ] || [ -z "$password" ]; then
    echo "No credentials found for '$profile_name'. Run: aliyun console setup $profile_name" >&2
    exit 1
  fi

  NODE_PATH="$NODE_GLOBAL_MODULES" \
  CONSOLE_URL="https://signin.aliyun.com/" \
  ALI_USERNAME="$username" \
  ALI_PASSWORD="$password" \
  ALI_TOTP_SEED="$totp_seed" \
  node "$CONSOLE_DIR/index.js"
}

cmd_console_show() {
  local profile_name="$1"
  if [ -z "$profile_name" ]; then
    profile_name="$(_select_console_profile)"
  fi
  [ -z "$profile_name" ] && exit 1

  local username password totp_seed
  username="$(_kget "$profile_name" username)"
  password="$(_kget "$profile_name" password)"
  totp_seed="$(_kget "$profile_name" totp_seed)" || true

  if [ -z "$username" ] || [ -z "$password" ]; then
    echo "No credentials found for '$profile_name'. Run: aliyun console setup $profile_name" >&2
    exit 1
  fi

  echo "Profile:   $profile_name"
  echo "Username:  $username"
  echo "Password:  $password"
  if [ -n "$totp_seed" ]; then
    echo "TOTP seed: $totp_seed"
  fi
}

cmd_console() {
  local subcmd="$1"
  [ -z "$subcmd" ] && usage_console
  case "$subcmd" in
    --complete)
      echo "setup open show"
      ;;
    setup)
      shift
      cmd_console_setup "$@"
      ;;
    open)
      shift
      cmd_console_open "$@"
      ;;
    show)
      shift
      cmd_console_show "$@"
      ;;
    -h)
      usage_console
      ;;
    *)
      usage_console
      ;;
  esac
}
