## Create a file with some initial data

### Method 1: use `cat` with redirection

```
cat <<EOF >newfile
foo
bar
baz
EOF

# Disable variable expansion
cat <<'EOF' >newfile
$foo
$bar
$baz
EOF
```

### Method 2: use `tee`

```
tee newfile <<EOF
foo
bar
baz
EOF
```

## Find and grep

```
find . -name '*.h' -print0 | xargs -0 grep qemu_find_opts
```

## Materials

https://www.gnu.org/software/bash/manual/html_node/ANSI_002dC-Quoting.html

## Error: -bash: _get_comp_words_by_ref: command not found

```
# For centos
yum install bash-completion
```

## Print array elements on separate lines in bash

```
printf '%s\n' "${my_array[@]}"

( IFS=$'\n'; echo "${my_array[*]}"  )
```

Ref: https://stackoverflow.com/questions/15691942/print-array-elements-on-separate-lines-in-bash

## Pass arguments to a script read via stdin

```
cat script.sh | bash -s - arguments
```

## How is return handled in a function while loop?

In Bash, if `while` struct is specified as a pipe side, then it runs in a
subshell. So `return` keyword will not exit from function.

```
testfn() {
  echo "$names" | while read name; do
    return 0
  done
  echo foo
}
```

Instead, we can use process substitution.

```
testfn() {
  while read name; do
    return 0
  done < <(echo "$names")
  echo foo
}
```

Ref: https://stackoverflow.com/questions/20910112/how-is-return-handled-in-a-function-while-loop

## Aliases

In bash, aliases are not expanded when the shell is not interactive, unless the
`expand_aliases` shell option is set using `shopt`.

## Capture output from some descriptor into a shell variable

```
# Capture stderr into a variable, but keep stdout in the console.
{ err=$(cmd 2>&1 >&3 3>&-); } 3>&1
```

Ref:
* https://unix.stackexchange.com/a/474195
* https://unix.stackexchange.com/questions/430161/redirect-stderr-and-stdout-to-different-variables-without-temporary-files
* http://tldp.org/LDP/abs/html/io-redirection.html

## Use additional file descriptors

```
tmp=$(mktemp)
exec 4> "$tmp"
echo foo >&4
exec 4>&-
cat "$tmp"
rm "$tmp"
```

## References

* https://tldp.org/LDP/abs/html/index.html
* http://zsh.sourceforge.net/Doc/Release/Parameters.html
* https://www.gnu.org/software/bash/manual/html_node/index.html
