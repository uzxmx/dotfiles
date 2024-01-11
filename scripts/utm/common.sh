utmctl="/Applications/UTM.app/Contents/MacOS/utmctl"

listvms() {
  "$utmctl" list | sed 1d | awk '{print $3, $1, $2}'
}

select_vm() {
  listvms | fzf | awk '{ print $2 }'
}

select_vm_and_get_name() {
  listvms | fzf | awk '{ print $1 }'
}
