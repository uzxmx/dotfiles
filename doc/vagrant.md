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
