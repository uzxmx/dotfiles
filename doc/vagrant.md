# Vagrant

## Export an existing box

```
vagrant box repackage <box-name> <provider> <version>
```

## Mirror for ubuntu boxes

* Ubuntu 18.04

  ```
  vagrant box add \
    https://mirrors.tuna.tsinghua.edu.cn/ubuntu-cloud-images/bionic/current/bionic-server-cloudimg-amd64-vagrant.box \
    --name ubuntu/bionic64
  ```

* Ubuntu 16.04

  ```
  vagrant box add \
    https://mirrors.tuna.tsinghua.edu.cn/ubuntu-cloud-images/xenial/current/xenial-server-cloudimg-amd64-vagrant.box \
    --name ubuntu/xenial64
  ```

* Ubuntu 14.04

  ```
  vagrant box add \
    https://mirrors.tuna.tsinghua.edu.cn/ubuntu-cloud-images/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box \
    --name ubuntu/trusty64
  ```

## Fail to run vagrant after user changes

Error:

```
The VirtualBox VM was created with a user that doesn't match the
current user running Vagrant. VirtualBox requires that the same user
be used to manage the VM that was created. Please re-run Vagrant with
that user. This is not a Vagrant issue.

The UID used to create the VM was: 0
Your UID is: 1000
```

Change UID in PROJECT_ROOT/.vagrant/machines/default/virtualbox/creator_uid.

Ref: https://github.com/hashicorp/vagrant/issues/8630#issuecomment-314219746
