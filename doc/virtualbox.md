## VERR_VD_VMDK_INVALID_HEADER

Stderr: VBoxManage: error: Could not open the medium '/Users/xmx/VirtualBox VMs/cert-manager_k8s-1_1569835682147_54099/box-disk001.vmdk'.
VBoxManage: error: VMDK: inconsistency between grain table and backup grain table in '/Users/xmx/VirtualBox VMs/cert-manager_k8s-1_1569835682147_54099/box-disk001.vmdk' (VERR_VD_VMDK_INVALID_HEADER).
VBoxManage: error: VD: error VERR_VD_VMDK_INVALID_HEADER opening image file '/Users/xmx/VirtualBox VMs/cert-manager_k8s-1_1569835682147_54099/box-disk001.vmdk' (VERR_VD_VMDK_INVALID_HEADER)
VBoxManage: error: Details: code NS_ERROR_FAILURE (0x80004005), component MediumWrap, interface IMedium

```
vmware-vdiskmanager -R <your_disk>.vmdk
```

Ref: https://serverfault.com/questions/324271/virtualbox-grain-table-inconsistency/575058#575058
