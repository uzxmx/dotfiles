# GDB

The executable to debug should be rebuilt with debug symbols added. For example,
the file size of executable `postgres` after rebuilt with debug symbols
increases tens of megabytes.

## Usage

### Attach to a running process

Start gdb with `gdb -p <target-pid>`, or use `attach <target-pid>` command when
in a gdb session.

Note that the user running gdb should be the same user as the one running the
target process, or root. In order to be able to view the source code when
debugging, the user running gdb should also have read permissions for those
source files targeted by debug symbols. So running gdb as root is a better
choice.

### Switch to TUI mode

In order to view source codes clearly, press `Ctrl-x a` to show source code
view.

### Breakpoints

```
# Show breakpoints
i b

# Add a breakpoint
b <function-name>

# Remove a breakpoint
d break <breakpoint-number>
```

### Show information

```
help i
# Show breakpoints
i b
```

### Misc

```
help x
x/i $pc
x/i 0xffff0
x/10i 0xffff0
```
