usage_mail() {
  cat <<-EOF
Usage: curl mail [message]

Send a mail by smtp.

You can also configure the sender info by below environment variables:
  * MAIL_FROM_ADDRESS
  * MAIL_PASSWORD
  * MAIL_FROM_NAME (optional)

Options:
  --from      <from-address> sender address
  --from-name <from-name> sender name, sender address will be used if empty
  -p          <password> sender password
  --url       <url> address of the smtp server with ssl enforced without the scheme prefix, e.g. smtp.163.com:465
                    Can be inferred from the sender address

  --to      <to-address> receipent address
  --to-name <to-address> receipent name, receipent address will be used if empty
  --self                 send mail to self

  -s <subject> subject
  -f <file>    file to be attached, can be specified multiple times

Example:
  $> curl mail --to to@example.com -s subject message

  $> curl mail --url smtp.exmail.qq.com:465 --from from@example.com -p password --to to@example.com -s subject message
EOF
  exit 1
}

cmd_mail() {
  local from_address="$MAIL_FROM_ADDRESS"
  local password="$MAIL_PASSWORD"
  local from_name="$MAIL_FROM_NAME"
  local to_address to_name to_self url message
  local -a attach_opts
  while [ $# -gt 0 ]; do
    case "$1" in
      --from)
        shift
        from_address="$1"
        ;;
      --from-name)
        shift
        from_name="$1"
        ;;
      -p)
        shift
        password="$1"
        ;;
      --url)
        shift
        url="$1"
        ;;
      --to)
        shift
        to_address="$1"
        ;;
      --to-name)
        shift
        to_name="$1"
        ;;
      --self)
        to_self=1
        ;;
      -s)
        shift
        subject="$1"
        ;;
      -f)
        shift
        attach_opts+=(-F "file=@$1;type=$(file --mime-type "$1" | sed 's/.*: //');encoder=base64")
        ;;
      -*)
        usage_mail
        ;;
      *)
        message="$1"
        ;;
    esac
    shift
  done

  if [ "$to_self" = 1 ]; then
    to_address="$from_address"
    to_name="$from_name"
  fi

  [ -z "$from_address" ] && abort "Sender address must be specified by '--from'."
  [ -z "$to_address" ] && abort "receipent address must be specified by '--to'."
  [ -z "$subject" ] && abort "Subject must be specified by '-s'."

  if [ -z "$url" ]; then
    case "$from_address" in
      *@163.com)
        url="smtp.163.com:465"
        ;;
      *)
        abort "Cannot infer the SMTP server address from $from_address"
        ;;
    esac
  fi

  curl "smtps://$url" \
    -v \
    --ssl-reqd \
    --mail-from "$from_address" \
    --mail-rcpt "$to_address" \
    --user "$from_address:$password" \
    -F '=(;type=multipart/mixed' \
    -F "=$message;type=text/plain" \
    "${attach_opts[@]}" \
    -F '=)' \
    -H "Subject: $subject" \
    -H "From: ${from_name:-$from_address} <$from_address>" \
    -H "To: ${to_name:-$to_address} <$to_address>"
}
