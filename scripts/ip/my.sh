usage_my() {
  cat <<-EOF
Usage: ip my [--concise]

**Updates**:

The following methods seem not working anymore. Instead, we use 'httpbin.org'
to find our public IP.

Get the external IP of the current machine. We use below APIs to query:

  * https://www.ip138.com
  * https://major.io/icanhazip-com-faq/

We may also use 'https://ipinfo.io/ip' to query.

Note: when visiting different sites, the external IP address may change. To
get all possible results, we first visit a site hosted in China, then a site
abroad, and compare them.

Options:
  --concise Only output IPs.

Example:
  $> ip my
EOF
  exit 1
}

cmd_my() {
  local concise
  case "$1" in
    --concise)
      concise=1
      ;;
    -*)
      usage_my
  esac

  # # See https://www.ip138.com
  # local ip1=$(curl --silent 'https://202020.ip138.com/' \
  #   -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.67 Safari/537.36' | \
  #   xmllint --html --xpath "/html/head/title/text()" - 2>/dev/null | awk -F '：' '{print $2}')
  #
  # local ip2=$(curl --silent https://ipv4.icanhazip.com/)
  #
  # if [ -n "$ip1" -a -n "$ip2" -a ! "$ip1" = "$ip2" ]; then
  #   if [ ! "$concise" = "1" ]; then
  #     echo Got two different IP addresses:
  #   fi
  #   echo $ip1
  #   echo $ip2
  #   exit
  # fi
  #
  # local ip
  # if [ -n "$ip1" ]; then
  #   ip="$ip1"
  # fi
  # if [ -n "$ip2" ]; then
  #   ip="$ip2"
  # fi

  ip="$(curl -s httpbin.org/get | jq -r '.origin')"

  echo "$ip" | tee >("$dotfiles_dir/bin/cb" >/dev/null)
  if [ ! "$concise" = "1" ]; then
    cmd_geo "$ip"
  fi
}