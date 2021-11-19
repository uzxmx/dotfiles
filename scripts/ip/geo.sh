usage_geo() {
  cat <<-EOF
Usage: ip geo <ip>

Get the geo info of an IP.

Example:
  $> ip geo 8.8.8.8
EOF
  exit 1
}

cmd_geo() {
  [ -z "$1" ] && usage_geo

  # Note: we get our external IP geo info when query is empty.
  local result="$(curl -s "http://api.geoiplookup.net/?query=$1")"
  if [ -n "$result" ]; then
    local isp="$(echo "$result" | xmllint --html --xpath "//result/isp/text()" - 2>/dev/null)"
    local city="$(echo "$result" | xmllint --html --xpath "//result/city/text()" - 2>/dev/null)"
    local country_name="$(echo "$result" | xmllint --html --xpath "//result/countryname/text()" - 2>/dev/null)"
    echo "$isp - $city - $country_name"
  else
    local json="$(curl -s https://ipvigilante.com/$1)"
    local address=($(echo $json | jq -r '.data.continent_name, .data.country_name, (.data.subdivision_1_name | select(. != null)), (.data.subdivision_2_name | select(. != null)), .data.city_name'))
    local location="($(echo $json | jq -r '.data.longitude'),$(echo $json | jq -r '.data.latitude'))"
    local IFS=","
    echo "${address[*]} $location"
  fi
}
