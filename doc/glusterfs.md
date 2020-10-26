## Install glusterfs in kubernetes cluster

* For requirements, see https://github.com/gluster/gluster-kubernetes/blob/master/docs/setup-guide.md#infrastructure-requirements

* In order to use dns name when accessing heketi endpoint, make sure the dnsPolicy of controller manager pod is `ClusterFirstWithHostNet`. (https://github.com/kubernetes/kubernetes/issues/42306#issuecomment-423646732)

* Add kernel module `sudo modprobe dm_thin_pool`. (https://github.com/gluster/gluster-kubernetes/issues/19)
Use `lsmod` to check if a module is loaded, `modinfo <module>` for more information.
If you want to load a module automatically after boot, you may add that module in `/etc/modules` file.

* Make sure glusterfs-client installed on host machine

* Install glusterfs chart by `./scripts/install_glusterfs.sh`

* Add a label to nodes by `kubectl label nodes <node> storagenode=glusterfs`

* Install heketi chart by `./scripts/install_heketi.sh` with bootstrap set to true

* Load glusterfs topology file by `kubectl exec <pod> -- heketi-cli topology load --json=/etc/heketi/topology.json`

* Dump heketi db

```
kubectl exec <pod> -- heketi-cli setup-openshift-heketi-storage --listfile=/tmp/heketi-storage.json --replica=2 --image="heketi/heketi:8"
```

Or if you have only one glusterfs node, you can pass `durability=none` like this:

```
kubectl exec <pod> -- heketi-cli setup-openshift-heketi-storage --listfile=/tmp/heketi-storage.json --durability=none --image="heketi/heketi:8"
```

* Copy the dumped data into glusterfs volume

```
kubectl exec <pod> -- cat /tmp/heketi-storage.json | kubectl create -f -
```

You can list volumes by `kubectl exec <pod> -- heketi-cli volume list`.
You can mount a volume on a directory of the host machine by `sudo mount -t glusterfs <HOSTNAME-OR-IPADDRESS>:/<VOLNAME> <MOUNTDIR>`.

* Delete bootstraping heketi by `helm delete --purge heketi`

* Install heketi chart by `./scripts/install_heketi.sh` with bootstrap set to false

### Notes

* The storage hostname must be ip address, whereas the management hostname can be name. (https://github.com/gluster/gluster-kubernetes/issues/20)

* You can execute `heketi-cli topology info` to view the topology.

* If you reset the glusterfs, you may also want to wipe the device by executing `sudo wipefs <device-file> -af`.

* You must specify `volumetype: "replicate:<replica count, e.g. 2>"` as a parameter of StorageClass resource. And
the replica count must be greater than 1.

* On every glusterfs node, there will be a glusterd process, and each brick will have a glusterfsd process. You may check the brick log at `/var/log/glusterfs/bricks/`.

* You may also need install package `attr` to use `getfattr`, `setfattr`.

* You may use `rm -rf /var/lib/glusterd/*` to reset glusterfs.

### Troubleshoot

* Error: Can't open /dev/sdc exclusively.  Mounted filesystem?

Execute `sudo dmsetup remove_all -f`

### References

* https://kubernetes.io/docs/concepts/storage/storage-classes/#glusterfs

* https://github.com/AcalephStorage/charts/tree/glusterfs/incubator/glusterfs

### Resync device of glusterfs

```
heketi-cli device resync <device-id>
```
