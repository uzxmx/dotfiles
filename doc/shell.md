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
