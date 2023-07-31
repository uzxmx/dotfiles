if type -p apt-get &>/dev/null; then
  default_user_name="ubuntu"
elif type -p yum &>/dev/null; then
  default_user_name="centos"
else
  echo "Unsupported system" >/dev/stderr
  exit 1
fi

if adduser --disabled-password --gecos '' "$default_user_name"; then
  echo "$default_user_name ALL=(ALL) NOPASSWD: ALL" | tee -a /etc/sudoers >/dev/null
fi
