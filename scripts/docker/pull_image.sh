usage_p() {
  cat <<-EOF
Usage: docker p <image>

Pull an image from a mirror.
EOF
  exit 1
}

cmd_p() {
  local name="$1"
  if [ -z "$name" ]; then
    echo 'An image name is required.'
    exit 1
  fi

  local fullname
  if [[ ! "$name" =~ .+/.+ ]]; then
    fullname="library/$name"
  else
    fullname="$name"
  fi

  local mirror="docker.mirrors.ustc.edu.cn"
  echo "Pulling image from $mirror..."
  docker pull "$mirror/$fullname"
  docker tag "$mirror/$fullname" "$name"
}
