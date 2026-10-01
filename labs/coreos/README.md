# coreos lab

This lab is done by hand. There is no deploy playbook.

Boot a discovery ISO created with OpenShift **5.0.0-rc.4**. The ISO
installs a single-node OpenShift cluster and is used to test a new
`coreos-installer` binary that includes the changes in
[coreos-installer#1765](https://github.com/coreos/coreos-installer/pull/1765).

## Requirements

### Resources (per node)

| | nodes | vCPUs | Memory | OS Disk | Data Disk | Total Disk |
| :-: | :-----: | :-----: | :------: | :-------: | :---------: | :----------: |
| SNO cluster | 1 | 16 | 22 GB | 0 GB | 0 GB | 0 GB |
| **Total** | **1** | **16** | **22 GB** | 0 GB | 0 GB | **120 GB (iSCSI)** |

## Steps

Manifests are in `labs/coreos/manifest/`. The cluster name is `coreos`,
the base domain is `local.lab`, and the only node is `coreos-node-1`.

1. Use the `openshift-install` binary from OpenShift **5.0.0-rc.4**.

2. Copy `install-config.yaml` and one agent config into a working
   directory.

   The committed `install-config.yaml` has the pull secret and SSH key
   redacted. Put real values in the working copy before generating the
   ISO.

   * `manifest/agent-config.yaml` enables DHCP on both interfaces.
   * `manifest/agent-config-static.yaml` assigns static addresses.

3. Create the discovery ISO:

   ```shell
   openshift-install agent create image --log-level debug --dir <working-directory>
   ```

4. Copy the discovery ISO to the path in the domain XML, then define
   and start the VM:

   ```shell
   cp <working-directory>/agent.x86_64.iso /home/libvirt-ocp/coreos-node-1.iso
   virsh define labs/coreos/libvirt/coreos-node-1.xml
   virsh start coreos-node-1
   ```

   The definition is [coreos-node-1.xml](libvirt/coreos-node-1.xml). The
   VM uses the `lab-network` and `pinnedis-net` networks. The CD-ROM
   source is `/home/libvirt-ocp/coreos-node-1.iso`.

5. SSH to the node as `core` at the rendezvous address
   `192.168.129.178`. When the installation starts,
   `node-image-overlay.service` checks out the ostree and overwrites
   `/usr/bin/coreos-installer`. Save the binary under test before that
   service finishes, then put it back before the installer writes the
   OS to disk.

   ```shell
   ssh core@192.168.129.178
   sudo -i
   cp /usr/bin/coreos-installer /tmp/coreos-installer-orig
   ```

   After `node-image-overlay.service` completes, bind-mount the saved
   binary over the one from the ostree layer:

   ```shell
   mount -o bind /tmp/coreos-installer-orig /usr/bin/coreos-installer
   ```

## Validation

1. After the installation finishes, check the node and the cluster
   version:

```shell
export KUBECONFIG=<working-directory>/auth/kubeconfig

oc get nodes
oc get clusterversion
```

`coreos-node-1` should be `Ready` with roles
`control-plane,master,worker`. The cluster version should be
`5.0.0-rc.4`.

## Links

* [fedora-coreos-config#4336](https://github.com/coreos/fedora-coreos-config/pull/4336)
* [coreos-installer#1765](https://github.com/coreos/coreos-installer/pull/1765)
* [OpenShift 5.0.0-rc.4](https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/5.0.0-rc.4/)
* [assisted-service#10925](https://github.com/openshift/assisted-service/pull/10925)
* [Configuring and using iSCSI](https://dustymabe.com/2024/05/10/configuring-and-using-iscsi/)
