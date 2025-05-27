# parted lab
This lab installs a compact Openshift cluster, partitioning the installation disk. We will have a partition reserved for data.

## Requirements
None.

## Steps
1. Deploy:
```shell
ap labs/parted/deploy.yaml
```

## Validation
1. Check if the Openshift cluster is running:
```shell
$ export KUBECONFIG=/root/labs/parted/deploy/auth/kubeconfig

$ oc get nodes
NAME            STATUS   ROLES                         AGE   VERSION
parted-node-1   Ready    control-plane,master,worker   20m   v1.31.6
parted-node-2   Ready    control-plane,master,worker   36m   v1.31.6
parted-node-3   Ready    control-plane,master,worker   36m   v1.31.6

$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.18.4    True        False         10m     Cluster version is 4.18.4
```

2. Open a debug session on one node and list the disk layout. You should see the vda5 partition unused.
```shell
$ oc debug node/parted-node-2
Starting pod/parted-node-2-debug-gs4mh ...
To use host binaries, run `chroot /host`
Pod IP: 192.168.125.32
If you don't see a command prompt, try pressing enter.
sh-5.1# chroot /host

sh-5.1# lsblk
NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
sr0     11:0    1   1.2G  0 rom
vda    252:0    0   130G  0 disk
|-vda1 252:1    0     1M  0 part
|-vda2 252:2    0   127M  0 part
|-vda3 252:3    0   384M  0 part /boot
|-vda4 252:4    0 116.7G  0 part /var
|                                /sysroot/ostree/deploy/rhcos/var
|                                /sysroot
|                                /usr
|                                /etc
|                                /
`-vda5 252:5    0   8.8G  0 part
vdb    252:16   0     1G  0 disk
```

## Links
* [Configuring partitions for worker nodes in OCP 4](https://access.redhat.com/solutions/5993151)
* [Document Ignition partitioning via MachineConfig](https://github.com/openshift/os/issues/384)
