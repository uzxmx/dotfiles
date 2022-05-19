DEFAULT_SUBJECT_FOR_CA="/C=CN/ST=SH/O=CA/CN=example.com"
DEFAULT_SUBJECT_FOR_NON_CA="/C=CN/ST=SH/O=Example, Inc./CN=example.com"
DEFAULT_SUBJECT="$DEFAULT_SUBJECT_FOR_NON_CA"

usage_gen() {
  cat <<-EOF
Usage: openssl gen

Subcommands:
  rsa_key, rsa_private_key - generate a RSA private key
  rsa_public_key           - get a RSA public key from its private key
  ca                       - generate a CA
  csr                      - generate a certificate signing request
  cert                     - generate a certificate, or sign a csr
EOF
  exit 1
}

usage_gen_rsa_private_key() {
  cat <<-EOF
Usage: openssl gen rsa_private_key [output-dir]

Generate a RSA private key. The output format is PEM format. By default the
numbits is 2048, you can change it to other value, e.g. 4096.

It also generates another private key file with PKCS#8 syntax, and the
corresponding public key file.

Options:
  -bits <bits> default is 2048
  -des3 use des3 to encrypt the key
EOF
  exit 1
}

cmd_gen_rsa_private_key() {
  local bits
  local -a opts
  local outdir
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -bits)
        shift
        bits="$1"
        ;;
      -des3)
        opts+=("-des3")
        ;;
      -h)
        usage_gen_rsa_private_key
        ;;
      *)
        outdir="$1"
        ;;
    esac
    shift
  done
  if [ -z "$outdir" ]; then
    outdir="."
  else
    mkdir -p "$outdir"
  fi
  openssl genrsa -out "$outdir/privkey.pem" "${opts[@]}" "${bits:-2048}"
  openssl pkcs8 -topk8 -in "$outdir/privkey.pem" -out "$outdir/privkey_pkcs8.pem" -nocrypt
  cmd_gen_rsa_public_key "$outdir/privkey.pem" "$outdir/pubkey.pem" >/dev/null
}

usage_gen_rsa_public_key() {
  cat <<-EOF
Usage: openssl gen rsa_public_key <path-to-private-key> [output-path]

Get a RSA public key from its private key. The output format is PEM format.

To get a public key for SSH purpose, run 'ssh-keygen -y -f privkey.pem'.
EOF
  exit 1
}

cmd_gen_rsa_public_key() {
  [ -z "$1" ] && usage_gen_rsa_public_key
  local outpath="${2:-pubkey.pem}"
  openssl rsa -in "$1" -pubout 2>/dev/null >"$outpath"
  echo "Generated to $outpath"
}

openssl_req_help() {
  local cmd="$1"
  local description="$2"
  cat <<-EOF
Usage: openssl gen $cmd

$description

If a RSA private key is not specified, a key will be generated. You can also
use 'openssl gen rsa_key' to create one beforehand.

By default, it operates interactively. If you want non-interactively, you must
specify '-subj' option.

Options:
  -key <file> a private key file with PEM format to use
  -days <days> number of days cert is valid for, default is 1000
  -subj <subject> the subject, e.g. /C=CN/ST=SH/O=Example, Inc./CN=example.com
EOF
  exit 1
}

openssl_req() {
  local t="$1"
  shift

  local key days
  local -a opts
  local subj
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -key)
        shift
        key="$1"
        ;;
      -days)
        shift
        days="$1"
        ;;
      -subj)
        shift
        subj="$1"
        ;;
    esac
    shift
  done

  local default_key output_file
  if [ "$t" = "ca" ]; then
    opts+=("-x509")
    default_key="ca_key.pem"
    output_file="ca_cert.pem"
  elif [ "$t" = "csr" ]; then
    default_key="key.pem"
    output_file="cert.csr"
  else
    echo Unsupported type: $t
    exit 1
  fi

  source "$dotfiles_dir/scripts/lib/prompt.sh"
  if [ -z "$subj" ]; then
    ask_for_input_empty subj "Subject (empty for using the default wizard of openssl): " "$DEFAULT_SUBJECT"
  fi
  if [ -n "$subj" ]; then
    opts+=("-subj" "$subj")
  fi

  if [ -z "$key" ]; then
    key="$default_key"
    openssl genrsa -out "$key" 2048
  fi

  if [ "$t" = "csr" ]; then
    # Add SANs
    local ALT_NAMES
    ask_for_input_empty ALT_NAMES "SANs (e.g. foo.example.com,bar.example.com): "
    if [ -n "$ALT_NAMES" ]; then
      tmpconf="$(mktemp)"
      handle_exit() {
        [ -e "$tmpconf" ] && rm "$tmpconf"
      }
      trap handle_exit EXIT
      export ALT_NAMES
      "$dotfiles_dir/bin/gen" openssl_conf - -f "$tmpconf" --overwrite >/dev/null
      opts+=("-config" "$tmpconf")
    fi

    openssl req -new -sha256 \
      -key "$key" \
      -days "${days:-1000}" \
      "${opts[@]}" \
      -out "$output_file"
  else
    openssl req -new -sha256 \
      -key "$key" \
      -days "${days:-1000}" \
      "${opts[@]}" \
      -out "$output_file"
  fi
}

usage_gen_ca() {
  openssl_req_help ca "Generate a CA. The format of generated CA certificate is PEM format."
}

cmd_gen_ca() {
  openssl_req ca "$@"
}

usage_gen_csr() {
  openssl_req_help csr "Generate a certificate signing request. The format of generated csr is PEM format."
}

cmd_gen_csr() {
  openssl_req csr "$@"
}

usage_gen_cert() {
  cat <<-EOF
Usage: openssl gen cert

Generate a certificate, or sign a certificate request. The output format is PEM
format. When you don't specify a CA or a CSR, one will be generated.

Options:
  -csr <file> a certificate request file with PEM format
  -ca <file> a CA certificate file with PEM format
  -cakey <file> a CA private key file with PEM format
  -days <days> number of days cert is valid for, default is 1000
EOF
  exit 1
}

cmd_gen_cert() {
  local csr ca cakey days
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -csr)
        shift
        csr="$1"
        ;;
      -ca)
        shift
        ca="$1"
        ;;
      -cakey)
        shift
        cakey="$1"
        ;;
      -days)
        shift
        days="$1"
        ;;
    esac
    shift
  done

  if [ -z "$ca" -a -z "$cakey" ]; then
    echo 'Generate a CA...'
    DEFAULT_SUBJECT="$DEFAULT_SUBJECT_FOR_CA"
    (cmd_gen_ca)
    ca="ca_cert.pem"
    cakey="ca_key.pem"
  elif [ -z "$ca" -o -z "$cakey" ]; then
    echo 'CA certificate and CA key must be both specified.'
    exit 1
  fi

  if [ -z "$csr" ]; then
    echo 'Generate a certificate request...'
    DEFAULT_SUBJECT="$DEFAULT_SUBJECT_FOR_NON_CA"
    (cmd_gen_csr)
    csr="cert.csr"
  fi

  # Allow all SANs in csr
  tmpcsr="$(mktemp)"
  tmpconf="$(mktemp)"
  handle_exit() {
    [ -e "$tmpcsr" ] && rm "$tmpcsr"
    [ -e "$tmpconf" ] && rm "$tmpconf"
  }
  trap handle_exit EXIT

  "$dotfiles_dir/bin/openssl" show cert.csr >"$tmpcsr"

  source "$dotfiles_dir/scripts/lib/awk/find_line.sh"
  local lineno="$(awk_find_line "$tmpcsr" "X509v3 Subject Alternative Name:")"
  local -a opts
  if [ -n "$lineno" ]; then
    export ALT_NAMES="$(sed -n "$(($lineno + 1))p" "$tmpcsr" | "$dotfiles_dir/bin/trim" | sed "s/DNS://g")"
    "$dotfiles_dir/bin/gen" openssl_conf - -f "$tmpconf" --overwrite >/dev/null
    opts+=("-extensions" "req_ext" "-extfile" "$tmpconf")
  fi

  openssl x509 -req -in "$csr" \
    -CA "$ca" -CAkey "$cakey" -CAcreateserial \
    -days "${days:-1000}" -sha256 "${opts[@]}" \
    -out "cert.pem"
}

gen_run() {
  local cmd="$1"
}

cmd_gen() {
  local cmd="$1"
  shift || true
  if [ -z "$cmd" ]; then
      cmd="$(fzf < <(cat <<EOF
rsa_private_key
rsa_public_key
ca
csr
cert
EOF
))"
  fi

  case "$cmd" in
    rsa_key | rsa_private_key | rsa_public_key | ca | csr | cert)
      case "$cmd" in
        rsa_key)
          cmd="rsa_private_key"
          ;;
      esac
      case "$1" in
        -h)
          type "usage_gen_$cmd" &>/dev/null && "usage_gen_$cmd"
          ;;
      esac
      "cmd_gen_$cmd" "$@"
      ;;
    *)
      usage_gen
      ;;
  esac
}
alias_cmd g gen
