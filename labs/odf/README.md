# ODF lab

In this lab the goal is install an OpenShift Cluster with **O**penShift **D**ata **F**oundation (ODF).

## Requirements

Minimum requirements for ODF nodes:

* 32 GiB of memory
* An additional disk with 150 GB

### Inventory

* resources
  * nodes: 3 (VMs)
  * vCPUs: 36
  * Memory: 144 GB
  * OS disk: 1260 GB (1.2 TB)

## Steps

1. Execute the playbook `deploy.yaml`:

```shell
ap labs/odf/deploy.yaml
```

## Validation

1. Check if the Openshift cluster is running:

```shell
$ export KUBECONFIG=/root/labs/odf/deploy/auth/kubeconfig

$ oc get nodes
NAME         STATUS   ROLES                         AGE   VERSION
odf-node-1   Ready    control-plane,master,worker   17m   v1.33.6
odf-node-2   Ready    control-plane,master,worker   33m   v1.33.6
odf-node-3   Ready    control-plane,master,worker   34m   v1.33.6

$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.20.8    True        False         11m     Cluster version is 4.20.8
```

2. Review if the nodes have the label `cluster.ocs.openshift.io/openshift-storage`. We should see 3 values (one for each ODF node).

```shell
$ oc get nodes -o json | jq -r '.items[].metadata.labels' | grep cluster.ocs.openshift.io/openshift-storage
  "cluster.ocs.openshift.io/openshift-storage": "",
  "cluster.ocs.openshift.io/openshift-storage": "",
  "cluster.ocs.openshift.io/openshift-storage": "",
```

3. Check the resource `StorageCluster`

```shell
oc get storagecluster -A
NAMESPACE           NAME                 AGE   PHASE   EXTERNAL   CREATED AT             VERSION
openshift-storage   ocs-storagecluster   10m   Ready              2026-03-04T08:16:36Z   4.20.6
```

4. Verify if the ODF PVCs have been created and bounded

```shell
oc get pvc -A
NAMESPACE           NAME                                   STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS                  VOLUMEATTRIBUTESCLASS   AGE
openshift-storage   noobaa-db-pg-cluster-1                 Bound    pvc-f9eb2aa2-882b-4830-9f83-42944f752b85   50Gi       RWOP           ocs-storagecluster-ceph-rbd   <unset>                 7m
openshift-storage   noobaa-db-pg-cluster-2                 Bound    pvc-09f86342-070c-4112-9ad7-4de52102464a   50Gi       RWOP           ocs-storagecluster-ceph-rbd   <unset>                 4m42s
openshift-storage   ocs-deviceset-lvms-vg1-0-data-04hs6w   Bound    pvc-dbc4dd16-1088-4583-9182-19f292373339   250Gi      RWO            lvms-vg1                      <unset>                 7m42s
openshift-storage   ocs-deviceset-lvms-vg1-1-data-0bn6s8   Bound    pvc-9e914928-e4a2-48e6-b71f-5b982191607a   250Gi      RWO            lvms-vg1                      <unset>                 7m42s
openshift-storage   ocs-deviceset-lvms-vg1-2-data-0h9png   Bound    pvc-9ffc1276-e7f9-44c1-aa58-242726c2f1d8   250Gi      RWO            lvms-vg1                      <unset>                 7m42s
openshift-storage   rook-ceph-mon-a                        Bound    pvc-4bd8ec17-19d4-49b3-a7b2-04606396e7ed   50Gi       RWO            lvms-vg1                      <unset>                 9m40s
openshift-storage   rook-ceph-mon-b                        Bound    pvc-ed6e140f-5c71-443a-931f-8d6a0442cfa2   50Gi       RWO            lvms-vg1                      <unset>                 9m39s
openshift-storage   rook-ceph-mon-c                        Bound    pvc-21549fd9-e927-46f6-b797-b162123fffc9   50Gi       RWO            lvms-vg1                      <unset>                 9m39s
```

5. In the [Web UI](https://console-openshift-console.apps.odf.local.lab/), go to **Storage** > **StorageCluster**. The _Status_ should be healthy.

## Links

* [Red Hat OpenShift Data Foundation](https://docs.redhat.com/en/documentation/red_hat_openshift_data_foundation/4.20)