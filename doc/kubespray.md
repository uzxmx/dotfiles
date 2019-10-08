## `ansible-playbook --become --become-user=root` throws "ERROR! Timeout (12s) waiting for privilege escalation prompt:"

### Solution

```
# Add `-c paramiko`
ansible-playbook -i inventory/mycluster/hosts.ini -u user --become --become-user=root -c paramiko cluster.yml
```

Reference https://github.com/ansible/ansible/issues/14426#issuecomment-183552953

## Ansible fails when checking kube_service_addresses is a network range

FAILED! => {"msg": "The conditional check 'kube_service_addresses | ipaddr('net')' failed. The error was: The ipaddr filter requires python-netaddr be installed on the ansible controller"}

### Solution

Install with `pip install netaddr` on machine that runs `ansible-playbook`.

## The conditional check 'kube_token_auth' failed

### Solution

This problem is related with ansible version, using ansible 2.7.8 will not have this problem.

## For ansible 2.8.5, it throws 'delegate_to' is not a valid attribute for a TaskInclude

### Solution

```
On local machine, run `export ANSIBLE_INVALID_TASK_ATTRIBUTE_FAILED=False`
Reference https://github.com/kubernetes-sigs/kubespray/issues/3985
```
