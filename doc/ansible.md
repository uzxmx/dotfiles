## synchronize

When using synchronize module, if you specify `ansible_ssh_common_args` in inventory file, you may also want to
add `use_ssh_args: yes` like below:

```
synchronize:
  src: src
  dest: dest
  use_ssh_args: yes
```

## Best practices

### Use `_` to separate words instead of `-`

ansible-playbook 2.8.5
  config file = None
  configured module search path = [u'/Users/xmx/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']
  ansible python module location = /Users/xmx/.asdf/installs/python/2.7.17/lib/python2.7/site-packages/ansible
  executable location = /Users/xmx/.asdf/installs/python/2.7.17/bin/ansible-playbook
  python version = 2.7.17 (default, Nov 15 2019, 16:02:06) [GCC 4.2.1 Compatible Apple LLVM 10.0.1 (clang-1001.0.46.4)]
No config file found; using defaults
setting up inventory plugins
host_list declined parsing /Users/xmx/projects/tcv_ansible/test_hosts as it did not pass it's verify_file() method
script declined parsing /Users/xmx/projects/tcv_ansible/test_hosts as it did not pass it's verify_file() method
auto declined parsing /Users/xmx/projects/tcv_ansible/test_hosts as it did not pass it's verify_file() method
Not replacing invalid character(s) "set([u'-'])" in group name (disable-password-expiration)
[DEPRECATION WARNING]: The TRANSFORM_INVALID_GROUP_CHARS settings is set to allow bad characters in
group names by default, this will change, but still be user configurable on deprecation. This feature
will be removed in version 2.10. Deprecation warnings can be disabled by setting
deprecation_warnings=False in ansible.cfg.
 [WARNING]: Invalid characters were found in group names but not replaced, use -vvvv to see details

Not replacing invalid character(s) "set([u'-'])" in group name (disable-password-expiration)
Set default localhost to localhost
