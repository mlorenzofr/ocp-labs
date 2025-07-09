# cnv-ocp lab

## Requirements

## Steps
1. Execute the playbook `deploy.yaml`:
```shell
ap labs/cnv-ocp/deploy.yaml
```
2. Create the virtual machines for the spoke cluster:
```shell
for i in {1..3}; do oc apply -f vms/cnvn-spoke-${i}.yaml; done
```
3. Prepare the **fakefish** image.
4. Deploy **fakefish** in the hub cluster as it's explained in the [documentation](https://github.com/openshift-metal3/fakefish/blob/main/user-docs/running-fakefish-on-ocp-for-kubevirt.md).

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
4. Check the `VirtualMachines`:
```shell
$ oc get virtualmachine -A
NAMESPACE   NAME           AGE     STATUS    READY
default     cnvn-spoke-1   29m     Running   True
default     cnvn-spoke-2   7m11s   Running   True
default     cnvn-spoke-3   3m47s   Running   True
```

## Links
* [Running FakeFish on OCP for KubeVirt Endpoints](https://github.com/openshift-metal3/fakefish/blob/main/user-docs/running-fakefish-on-ocp-for-kubevirt.md)
