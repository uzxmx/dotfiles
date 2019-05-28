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
