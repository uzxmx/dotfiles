usage_proxy() {
  cat <<-EOF
Usage: curl proxy <proxy> [options]

Benchmark a proxy by sending requests through it multiple times. A request is
considered failed if it times out, fails to connect, or the HTTP status code is
not 2xx/3xx.

There are two modes:
  latency   (default) request a tiny resource to measure round-trip latency and
            connection stability, suitable for browsing and API calls
  bandwidth (-b) download a large file to measure sustained throughput,
            suitable for downloading large files

The proxy can be specified like:
  http://127.0.0.1:7890
  http://user:pass@host:port
  socks5h://host:port

Options:
  -b <size>    bandwidth mode, download <size> bytes from Cloudflare speed test,
               supports K/M/G suffix (decimal), e.g. 100M. Use at least 50M to
               get past TCP slow start and reveal throttling. Cloudflare only
               allows less than 100M per request, so larger sizes are capped;
               use -u with your own large file to test more, in which case
               <size> is ignored
  -n <count>   number of requests, default 20 (latency) or 3 (bandwidth)
  -t <seconds> timeout of each request, default 10 (latency) or 300 (bandwidth)
  -u <url>     url to test, default https://www.google.com/generate_204, or
               https://speed.cloudflare.com/__down?bytes=<size> in bandwidth mode
  -            indicate options after this are used as curl options

Example:
  $> curl proxy http://127.0.0.1:7890
  $> curl proxy socks5h://127.0.0.1:1080 -n 50 -t 5 -u https://github.com
  $> curl proxy http://127.0.0.1:7890 -b 100M -n 1
  $> curl proxy http://127.0.0.1:7890 -b 1 -u https://example.com/large.zip
EOF
  exit 1
}

# Convert size like 100M, 1.5G, 512K, 1000 to bytes, using decimal units.
proxy_parse_size() {
  echo "$1" | awk '
    match($0, /^[0-9]+(\.[0-9]+)?/) {
      n = substr($0, 1, RLENGTH); unit = toupper(substr($0, RLENGTH + 1))
      sub(/I?B$/, "", unit)
      if (unit == "") m = 1
      else if (unit == "K") m = 1e3
      else if (unit == "M") m = 1e6
      else if (unit == "G") m = 1e9
      else exit 1
      printf "%d\n", n * m
      exit 0
    }
    { exit 1 }'
}

cmd_proxy() {
  local proxy count timeout url size bytes
  local -a remainder
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -b)
        shift
        size="$1"
        ;;
      -n)
        shift
        count="$1"
        ;;
      -t)
        shift
        timeout="$1"
        ;;
      -u)
        shift
        url="$1"
        ;;
      -)
        shift
        remainder=("$@")
        break
        ;;
      -*)
        usage_proxy
        ;;
      *)
        proxy="$1"
        ;;
    esac
    shift
  done

  [ -z "$proxy" ] && usage_proxy

  if [ -n "$size" ]; then
    bytes="$(proxy_parse_size "$size")" || abort "Invalid size: $size"
    count="${count:-3}"
    timeout="${timeout:-300}"
    if [ -z "$url" ]; then
      if [ "$bytes" -ge 100000000 ]; then
        bytes=99999999
        echo "Size capped to $bytes bytes, the limit of Cloudflare speed test"
      fi
      url="https://speed.cloudflare.com/__down?bytes=$bytes"
    fi
    echo "Mode: bandwidth"
  else
    count="${count:-20}"
    timeout="${timeout:-10}"
    url="${url:-https://www.google.com/generate_204}"
    echo "Mode: latency"
  fi

  echo "Proxy: $proxy"
  echo "URL: $url, count: $count, timeout: ${timeout}s"
  echo

  local tmp ok=0 i out
  # Show curl's progress meter (current speed, time left) in bandwidth mode when
  # stderr is a terminal, the stats from -w still go to stdout.
  local -a quiet=(-s)
  [ -n "$size" ] && [ -t 2 ] && quiet=()
  tmp="$(mktemp)"
  trap "rm -f '$tmp'" EXIT

  for ((i = 1; i <= count; i++)); do
    # Output: total ssldone starttransfer speed size http_code
    if out="$(curl -x "$proxy" -o /dev/null "${quiet[@]}" -m "$timeout" "${remainder[@]}" \
          -w '%{time_total} %{time_appconnect} %{time_starttransfer} %{speed_download} %{size_download} %{http_code}' "$url")" \
        && [[ "${out##* }" =~ ^[23] ]]; then
      echo "$out" >>"$tmp"
      ok=$((ok + 1))
      if [ -n "$size" ]; then
        echo "$i $out" | awk '{ printf "  #%-3d %8.2f Mbps  %7.1f MB in %.1fs\n", $1, $5 * 8 / 1e6, $6 / 1e6, $2 }'
      else
        printf '  #%-3d %ss\n' "$i" "${out%% *}"
      fi
    else
      # A timed out download still reports partial speed, which hints at throttling.
      echo "$i ${out:-0 0 0 0 0 000}" | awk -v bw="$size" '{
        if (bw) printf "  #%-3d failed (HTTP %s, %.2f Mbps before failing)\n", $1, $7, $5 * 8 / 1e6
        else printf "  #%-3d failed (HTTP %s)\n", $1, $7
      }'
    fi
  done

  echo -e "-------------------------\n"

  if [ "$ok" -eq 0 ]; then
    echo "Success: 0/${count}, all requests failed"
    exit 1
  fi

  if [ -n "$size" ]; then
    sort -n -k4,4 "$tmp" | awk -v total="$count" '
      { v[NR] = $4 * 8 / 1e6; s += v[NR]; t += $1 }
      END {
        n = NR
        med = (n % 2) ? v[(n + 1) / 2] : (v[n / 2] + v[n / 2 + 1]) / 2
        printf "      success:  %d/%d (%.0f%%)\n", n, total, n * 100 / total
        printf "    median bw:  %.2f Mbps (%.2f MB/s)\n", med, med / 8
        printf "       avg bw:  %.2f Mbps\n", s / n
        printf "      min/max:  %.2f / %.2f Mbps\n", v[1], v[n]
        printf "     avg time:  %.1fs\n", t / n
      }'
  else
    sort -n -k1,1 "$tmp" | awk -v total="$count" '
      { t[NR] = $1; s += $1; ssl += $2; ttfb += $3 }
      END {
        n = NR
        med = (n % 2) ? t[(n + 1) / 2] : (t[n / 2] + t[n / 2 + 1]) / 2
        p90 = t[int(n * 0.9 + 0.999)]
        avg = s / n
        for (i = 1; i <= n; i++) sd += (t[i] - avg) ^ 2
        printf "      success:  %d/%d (%.0f%%)\n", n, total, n * 100 / total
        printf "          avg:  %.3fs\n", avg
        printf "       median:  %.3fs\n", med
        printf "          p90:  %.3fs\n", p90
        printf "      min/max:  %.3fs / %.3fs\n", t[1], t[n]
        printf "       stddev:  %.3fs\n", sqrt(sd / n)
        printf "  ssldone avg:  %.3fs\n", ssl / n
        printf "     ttfb avg:  %.3fs\n", ttfb / n
      }'
  fi
}
