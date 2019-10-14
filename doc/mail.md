## How to send mail to a SMTP server from terminal?

### Install `msmtp`

```
# For mac
brew install msmtp
```

### Send a mail to a SMTP server (e.g. 163 mail)

```
# This command will ask for password.
msmtp -v --host="smtp.163.com" \
  --auth="on" --user="user@163.com" \
  --tls="on" --tls-starttls="on" \
  --from="user@163.com" \
  to-user@example.com

# With a custom host port.
msmtp -v --host="smtpdm.aliyun.com" \
  --port="80" \
  --auth="on" --user="user@example.com" \
  --tls="on" --tls-starttls="on" \
  --from="user@example.com" \
  to-user@example.com

# Use a socks5 proxy.
msmtp -v --host="smtpdm.aliyun.com" \
  --port="80" \
  --auth="on" --user="user@example.com" \
  --tls="on" --tls-starttls="on" \
  --proxy-host="localhost" \
  --proxy-port="10080" \
  --from="user@example.com" \
  to-user@example.com
```
