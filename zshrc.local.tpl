# vi: ft=sh
#
# This is a template file for `.zshrc.local`. Copy this file with name
# `.zshrc.local`, and it will be loaded by `.zshrc` automatically.

# Configure custom directories for shared libraries.
# We can get the shared library dependencies by `ldd` or `readelf`, e.g.
# `ldd /bin/ls`
# `readelf --dynamic /bin/ls`
#
# export LD_LIBRARY_PATH=/opt/lib:$LD_LIBRARY_PATH
