DEFAULT_SUBJECT="CN=example.com,OU=IT,O=Example,L=SH,S=SH,C=CN"

usage_gen() {
  cat <<-EOF
Usage: keytool gen [path-to-jks-file]

Generate a keystore. If the file is not specified, 'keystore.jks' will be used.

Options:
  -a <alias> default is mykey
  -s <subject> the subject, e.g. CN=example.com, OU=YourCompanyDepartment, O=YourCompany, L=SH, S=SH, C=CN
  -p <password> keystore password, default is changeit
  -v <validity> the validity, unit is year, default is 10 years
EOF
  exit 1
}

cmd_gen() {
  local alias_name subject storepass
  local file="keystore.jks"
  local validity="10"
  local -a opts
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -a)
        shift
        alias_name="$1"
        ;;
      -s)
        shift
        subject="$1"
        ;;
      -p)
        shift
        storepass="$1"
        ;;
      -v)
        shift
        validity="$1"
        ;;
      -*)
        usage_gen
        ;;
      *)
        file="$1"
        ;;
    esac
    shift
  done

  [ -f "$file" ] && echo "File $file already exists, please remove it first." && exit 1

  source "$dotfiles_dir/scripts/lib/prompt.sh"
  if [ -z "$subject" ]; then
    ask_for_input subject "Subject: " "$DEFAULT_SUBJECT"
  fi

  if [ -z "$storepass" ]; then
    ask_for_input storepass "Store password: " changeit
  fi

  keytool -genkey --noprompt \
    -alias "${alias_name:-mykey}" \
    -storepass "$storepass" \
    -keyalg RSA -keysize 2048 \
    -dname "$subject" \
    -validity "$((validity * 365))" \
    -keystore "$file"

  source "$(dirname "$BASH_SOURCE")/list.sh"
  cmd_list -p "$storepass" -v "$file"
}
alias_cmd g gen
