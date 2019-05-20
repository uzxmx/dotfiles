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
