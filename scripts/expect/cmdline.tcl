# This file can be used for such purposes:
#   - provide commands to cli, e.g. `-c 'puts "foo"'`
#   - after processing, argv only contains arguments after '--'
#
# Usage:
# If you have other options to specify, you can define an array variable
# `options` in the script. For more documentation, please visit
# https://core.tcl-lang.org/tcllib/doc/tcllib-1-18/embedded/www/tcllib/files/modules/cmdline/cmdline.html
#
# You can define a variable `usage` to specify the cli usage. After processing,
# you can get argument value through variable `params`, e.g. `puts "$params(c)"`.
#
# ```
# set options {
#     {a          "set the atime only"}
#     {m          "set the mtime only"}
#     {r.arg  ""  "use time from ref_file"}
#     {t.arg  -1  "use specified time"}
# }
# set usage "- CLI description"
#
# source ~/.dotfiles/scripts/expect/cmdline.tcl
#
# puts "$params(c)"
# ```

package require cmdline

if {![info exists options]} {
  set options {}
}
append options {{c.arg "" "Commands to execute"}}
if {![info exists usage]} {
  set usage "options:"
}
if {[catch {array set params [cmdline::getoptions argv $options $usage]}]} {
  puts [cmdline::usage $options $usage]
  exit 1
}
