# cnv-ocp lab

## Requirements

## Steps
1. Execute the playbook `deploy.yaml`:
```shell
ap labs/cnv-ocp/deploy.yaml
```
2. Attach a new network interface to the machines for the CNV network.
3. Configure the networking for the CNV environment:
```shell
ap labs/cnv-ocp/deploy.yaml --tags cnv-networking
```
4. Prepare the spoke cluster:
```
ap labs/cnv-ocp/deploy.yaml --tags spoke
```
5. Configure the DHCP networking (manually, here we don't have BMH's)
6. Create the `VirtualMachines`:
```
ap labs/cnv-ocp/deploy.yaml --tags vms
```
7. With the virtual machines stopped, attach the discovery ISO using the Web UI.
> [!WARNING]
> After create a new `BaremetalHost`, bound to the `InfraEnv`, review if the PVC with the discovery ISO has been created. If it's not present, remove the `BaremetalHost` and retry.
8. Start the VMs, the cluster installation should begin.
> [!WARNING]
> The NTP validation takes some time to be validated
> The discovery ISO doesn't work after writing the image to disk. It may require stop the VM and change the boot order or remove the CD-ROM manually.
9. The agent resources must be approved manually.
```shell
$ oc get agent -n spoke
NAMESPACE   NAME                                   CLUSTER   APPROVED   ROLE     STAGE
spoke       53f824e5-d158-5082-827a-03d99fe632ac   spoke     false      worker
spoke       9b75c89d-163a-51ee-893a-9f72c1dbde42   spoke     false      master
spoke       9cca4b6d-65b4-5249-a5e4-e13fbb721abc   spoke     false      worker

$ oc patch agent/53f824e5-d158-5082-827a-03d99fe632ac -n spoke --patch '{"spec":{"approved":true}}' --type=merge
$ oc patch agent/9b75c89d-163a-51ee-893a-9f72c1dbde42 -n spoke --patch '{"spec":{"approved":true}}' --type=merge
$ oc patch agent/9cca4b6d-65b4-5249-a5e4-e13fbb721abc -n spoke --patch '{"spec":{"approved":true}}' --type=merge
```

## Validation
1. Check if the cluster is running:
```shell
$ export KUBECONFIG=~/labs/cnvn/deploy/auth/kubeconfig

$ oc get nodes
NAME            STATUS   ROLES                         AGE   VERSION
cnvn-master-1   Ready    control-plane,master,worker   19h   v1.31.8
cnvn-master-2   Ready    control-plane,master,worker   20h   v1.31.8
cnvn-master-3   Ready    control-plane,master,worker   20h   v1.31.8

$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.18.16   True        False         19h     Cluster version is 4.18.16
```
2. Check `StorageClasses` and `PersistenVolumeClaims`:
```shell
$ oc get sc
NAME                           PROVISIONER                             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
lvms-vg1 (default)             topolvm.io                              Delete          WaitForFirstConsumer   true                   19h
ocs1-ceph-rbd                  openshift-storage.rbd.csi.ceph.com      Delete          Immediate              true                   19h
ocs1-ceph-rbd-virtualization   openshift-storage.rbd.csi.ceph.com      Delete          Immediate              true                   17h
ocs1-ceph-rgw                  openshift-storage.ceph.rook.io/bucket   Delete          Immediate              false                  19h
ocs1-cephfs                    openshift-storage.cephfs.csi.ceph.com   Delete          Immediate              true                   19h

$ oc get pvc -A
NAMESPACE             NAME                                          STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS    VOLUMEATTRIBUTESCLASS   AGE
multicluster-engine   assisted-service                              Bound    pvc-8e68c957-7201-42d1-ba89-725398c5de1c   20Gi       RWO            lvms-vg1        <unset>                 19h
multicluster-engine   image-service-data-assisted-image-service-0   Bound    pvc-ca28eb12-48ff-4850-bf3a-b228d95b3152   10Gi       RWO            lvms-vg1        <unset>                 19h
multicluster-engine   postgres                                      Bound    pvc-f6bfdab8-cb0e-4d68-8705-3e53bc6664b0   10Gi       RWO            lvms-vg1        <unset>                 19h
openshift-storage     db-noobaa-db-pg-0                             Bound    pvc-4f606400-3ca7-45b5-9945-88a74faa3232   50Gi       RWO            ocs1-ceph-rbd   <unset>                 19h
openshift-storage     deviceset1-0-data-0vhg2x                      Bound    pvc-f04edd29-b47c-4eef-84cf-af7e5fac9c09   180Gi      RWO            lvms-vg1        <unset>                 19h
openshift-storage     deviceset1-1-data-04kt9l                      Bound    pvc-d35bd68e-4aee-4ae4-bfc6-a1c343645e86   180Gi      RWO            lvms-vg1        <unset>                 19h
openshift-storage     deviceset1-2-data-0d7s9b                      Bound    pvc-e4f6f4f4-5770-4293-9e69-180c4a2a7ecf   180Gi      RWO            lvms-vg1        <unset>                 19h
```
3. Check if the _Multicluster Engine_ is installed and running:
```shell
$ oc get csv -n multicluster-engine
NAME                         DISPLAY                              VERSION   REPLACES                     PHASE
multicluster-engine.v2.8.2   multicluster engine for Kubernetes   2.8.2     multicluster-engine.v2.8.1   Succeeded

$ oc get pods -n multicluster-engine -l app=assisted-image-service
NAME                       READY   STATUS    RESTARTS   AGE
assisted-image-service-0   1/1     Running   0          17h

$ oc get pods -n multicluster-engine -l app=assisted-service
NAME                               READY   STATUS    RESTARTS   AGE
assisted-service-d4f9885c7-rfl55   2/2     Running   0          19h
```
4. From the Beaker machine, check if the bridge **br-cnv** was configured correctly:
```shell
for i in {1..3}; do kssh cnvn-master-${i} ip a l br-cnv; done
```
5. Check the `VirtualMachines`:
```shell
$ oc get virtualmachine -A
NAMESPACE   NAME           AGE     STATUS    READY
default     cnvn-spoke-1   29m     Running   True
default     cnvn-spoke-2   7m11s   Running   True
default     cnvn-spoke-3   3m47s   Running   True
```
6. Check resources related with the cluster deployment:
```shell
$ oc get infraenv,clusterdeployment,bmh -n spoke
NAME                                        ISO CREATED AT
infraenv.agent-install.openshift.io/spoke   2025-07-11T15:31:21Z

NAME                                        INFRAID                                PLATFORM          REGION   VERSION   CLUSTERTYPE   PROVISIONSTATUS   POWERSTATE   AGE
clusterdeployment.hive.openshift.io/spoke   cecb2a18-d5a3-478f-9f7b-d86ce13c143e   agent-baremetal                                    Provisioned       Running      4d22h

NAME                                   STATE         CONSUMER   ONLINE   ERROR   AGE
baremetalhost.metal3.io/cnvn-spoke-1   provisioned              true             4d22h
```
7. Check if the _spoke_ cluster works:
```
$ export KUBECONFIG=~/labs/cnvn/spoke/auth/kubeconfig-32707

$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.18.16   True        False         4d21h   Cluster version is 4.18.16

$ oc get nodes
NAME           STATUS   ROLES                         AGE     VERSION
cnvn-spoke-1   Ready    control-plane,master,worker   4d21h   v1.31.8

$ oc get co
NAME                                       VERSION   AVAILABLE   PROGRESSING   DEGRADED   SINCE   MESSAGE
authentication                             4.18.16   True        False         False      39h
baremetal                                  4.18.16   True        False         False      4d21h
cloud-controller-manager                   4.18.16   True        False         False      4d21h
cloud-credential                           4.18.16   True        False         False      4d21h
cluster-autoscaler                         4.18.16   True        False         False      4d21h
config-operator                            4.18.16   True        False         False      4d21h
console                                    4.18.16   True        False         False      4d21h
control-plane-machine-set                  4.18.16   True        False         False      4d21h
csi-snapshot-controller                    4.18.16   True        False         False      4d21h
dns                                        4.18.16   True        False         False      4d21h
etcd                                       4.18.16   True        False         False      4d21h
image-registry                             4.18.16   True        False         False      4d21h
ingress                                    4.18.16   True        False         False      4d21h
insights                                   4.18.16   True        False         False      4d21h
kube-apiserver                             4.18.16   True        False         False      4d21h
kube-controller-manager                    4.18.16   True        False         False      4d21h
kube-scheduler                             4.18.16   True        False         False      4d21h
kube-storage-version-migrator              4.18.16   True        False         False      4d21h
machine-api                                4.18.16   True        False         False      4d21h
machine-approver                           4.18.16   True        False         False      4d21h
machine-config                             4.18.16   True        False         False      4d21h
marketplace                                4.18.16   True        False         False      4d21h
monitoring                                 4.18.16   True        False         False      4d21h
network                                    4.18.16   True        False         False      4d21h
node-tuning                                4.18.16   True        False         False      4d21h
olm                                        4.18.16   True        False         False      4d21h
openshift-apiserver                        4.18.16   True        False         False      3d21h
openshift-controller-manager               4.18.16   True        False         False      3d21h
openshift-samples                          4.18.16   True        False         False      4d21h
operator-lifecycle-manager                 4.18.16   True        False         False      4d21h
operator-lifecycle-manager-catalog         4.18.16   True        False         False      4d21h
operator-lifecycle-manager-packageserver   4.18.16   True        False         False      4d21h
service-ca                                 4.18.16   True        False         False      4d21h
storage                                    4.18.16   True        False         False      4d21h
```

## Links
* [Running FakeFish on OCP for KubeVirt Endpoints](https://github.com/openshift-metal3/fakefish/blob/main/user-docs/running-fakefish-on-ocp-for-kubevirt.md)
