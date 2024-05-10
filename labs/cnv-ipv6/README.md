# cnv-ipv6 lab
In this lab the goal is install an Openshift Cluster with Single Stack IPv6 addressing.  
The QE team will use the lab to do some testing with CNV. Because of this, we will install ODF and MCE in the lab.

## Requirements
For this lab, an IPv6-only libvirt network is required.  
There is an example in the file [libvirt/net.xml](libvirt/net.xml).  
You can define it with:
```shell
virsh # net-define --file /tmp/net.xml
```

## Steps
1. Execute the playbook `deploy.yaml`:
```shell
ap labs/cnv-ipv6/deploy.yaml --tags ocp
```
2. Unfortunately, we do not know at installation time what role will be assigned to each node. So once the cluster is installed, we need to stop the worker nodes and increase their data disk manually.
  2.1. Check the nodes:
```shell
$ oc get nodes
NAME         STATUS   ROLES                  AGE     VERSION
cnv-node-1   Ready    control-plane,master   3h22m   v1.28.7+f1b5f6c
cnv-node-2   Ready    control-plane,master   3h40m   v1.28.7+f1b5f6c
cnv-node-3   Ready    control-plane,master   3h40m   v1.28.7+f1b5f6c
cnv-node-4   Ready    worker                 3h29m   v1.28.7+f1b5f6c
cnv-node-5   Ready    worker                 3h29m   v1.28.7+f1b5f6c
cnv-node-6   Ready    worker                 3h29m   v1.28.7+f1b5f6c
```
  2.2. Step by step, switch off each VM, increase its data disk and start the VM:
```
$ qemu-img resize /var/lib/libvirt/images/cnv-node-4_1.img +199G
$ qemu-img resize /var/lib/libvirt/images/cnv-node-5_1.img +199G
$ qemu-img resize /var/lib/libvirt/images/cnv-node-6_1.img +199G
```
3. Apply post-installation setup
```shell
ap labs/ipv6-single-stack/deploy.yaml --tags postinst
```
4. Finally, for the QE team, we will need to configure additional components, not included here to avoid exposing internal information:
  * `ConfigMap` with internal certificates, to mark it as trusted.
  * `CatalogSources` with the internal catalog.
  * `ImageContentSourcePolicy` with the internal registry mirroring.
  * Set the `secret/pull-secret` in `openshift-config` with a valid token for the internal registry.

## Validation
1. Check if the cluster is running:
```shell
$ export KUBECONFIG=/root/labs/okd/deploy/auth/kubeconfig

$ oc get nodes
NAME         STATUS   ROLES                  AGE     VERSION
cnv-node-1   Ready    control-plane,master   3h22m   v1.28.7+f1b5f6c
cnv-node-2   Ready    control-plane,master   3h40m   v1.28.7+f1b5f6c
cnv-node-3   Ready    control-plane,master   3h40m   v1.28.7+f1b5f6c
cnv-node-4   Ready    worker                 3h29m   v1.28.7+f1b5f6c
cnv-node-5   Ready    worker                 3h29m   v1.28.7+f1b5f6c
cnv-node-6   Ready    worker                 3h29m   v1.28.7+f1b5f6c

$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.15.4    True        False         3h10m   Cluster version is 4.15.4

$ oc get co
NAME                                       VERSION   AVAILABLE   PROGRESSING   DEGRADED   SINCE   MESSAGE
authentication                             4.15.4    True        False         False      3h11m
baremetal                                  4.15.4    True        False         False      3h36m
cloud-controller-manager                   4.15.4    True        False         False      3h41m
cloud-credential                           4.15.4    True        False         False      3h41m
cluster-autoscaler                         4.15.4    True        False         False      3h36m
config-operator                            4.15.4    True        False         False      3h38m
console                                    4.15.4    True        False         False      3h18m
control-plane-machine-set                  4.15.4    True        False         False      3h36m
csi-snapshot-controller                    4.15.4    True        False         False      3h37m
dns                                        4.15.4    True        False         False      3h36m
etcd                                       4.15.4    True        False         False      3h29m
image-registry                             4.15.4    True        False         False      3h27m
ingress                                    4.15.4    True        False         False      3h23m
insights                                   4.15.4    True        False         False      3h31m
kube-apiserver                             4.15.4    True        False         False      3h29m
kube-controller-manager                    4.15.4    True        False         False      3h30m
kube-scheduler                             4.15.4    True        False         False      3h29m
kube-storage-version-migrator              4.15.4    True        False         False      3h38m
machine-api                                4.15.4    True        False         False      3h28m
machine-approver                           4.15.4    True        False         False      3h37m
machine-config                             4.15.4    True        False         False      3h36m
marketplace                                4.15.4    True        False         False      3h36m
monitoring                                 4.15.4    True        False         False      3h19m
network                                    4.15.4    True        False         False      3h38m
node-tuning                                4.15.4    True        False         False      3h23m
openshift-apiserver                        4.15.4    True        False         False      3h19m
openshift-controller-manager               4.15.4    True        False         False      3h30m
openshift-samples                          4.15.4    True        False         False      3h27m
operator-lifecycle-manager                 4.15.4    True        False         False      3h36m
operator-lifecycle-manager-catalog         4.15.4    True        False         False      3h36m
operator-lifecycle-manager-packageserver   4.15.4    True        False         False      3h28m
service-ca                                 4.15.4    True        False         False      3h38m
storage                                    4.15.4    True        False         False      3h38m
```
2. Verify that services are running only with IPv6 addresses:
```shell
$ oc get svc -n openshift-console
NAME        TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
console     ClusterIP   fd02::a89a   <none>        443/TCP   3h29m
downloads   ClusterIP   fd02::f285   <none>        80/TCP    3h29m

$ oc get svc -n openshift-ingress
NAME                      TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                   AGE
router-internal-default   ClusterIP   fd02::949a   <none>        80/TCP,443/TCP,1936/TCP   3h38m

$ oc get svc -n openshift-apiserver
NAME              TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)     AGE
api               ClusterIP   fd02::f848   <none>        443/TCP     3h42m
check-endpoints   ClusterIP   fd02::cefe   <none>        17698/TCP   3h42m
```
3. Verify that the ODF SCs and PVCs are present:
```shell
$ oc get sc
NAME                              PROVISIONER                                 RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
localblock                        kubernetes.io/no-provisioner                Delete          WaitForFirstConsumer   false                  14h
ocs1-ceph-rbd                     openshift-storage-odf.rbd.csi.ceph.com      Delete          Immediate              true                   14h
ocs1-ceph-rgw                     openshift-storage-odf.ceph.rook.io/bucket   Delete          Immediate              false                  14h
ocs1-cephfs                       openshift-storage-odf.cephfs.csi.ceph.com   Delete          Immediate              true                   14h
openshift-storage-odf.noobaa.io   openshift-storage-odf.noobaa.io/obc         Delete          Immediate              false                  14h

$ oc get pvc -A
NAMESPACE               NAME                       STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS    AGE
openshift-storage-odf   db-noobaa-db-pg-0          Bound    pvc-b6fd1ada-6338-436d-a229-c4e3f39804bb   50Gi       RWO            ocs1-ceph-rbd   14h
openshift-storage-odf   deviceset1-0-data-0cwbxb   Bound    local-pv-c112504                           200Gi      RWO            localblock      14h
openshift-storage-odf   deviceset1-1-data-0pbjgh   Bound    local-pv-5af1757a                          200Gi      RWO            localblock      14h
openshift-storage-odf   deviceset1-2-data-0b9q66   Bound    local-pv-a32fb595                          200Gi      RWO            localblock      14h
```
4. Check if the _Multicluster Engine_ is installed and running:
```shell
$ oc get csv -n multicluster-engine
NAME                         DISPLAY                              VERSION   REPLACES                     PHASE
multicluster-engine.v2.4.4   multicluster engine for Kubernetes   2.4.4     multicluster-engine.v2.4.3   Succeeded

$ oc get pods -n multicluster-engine
NAME                                                   READY   STATUS    RESTARTS   AGE
cluster-curator-controller-68d89479f-6jwn7             1/1     Running   0          14h
cluster-image-set-controller-75cc44d88d-2c5vz          1/1     Running   0          14h
cluster-manager-5f4ffb94d5-m4mx6                       1/1     Running   0          14h
cluster-manager-5f4ffb94d5-mxb4t                       1/1     Running   0          14h
cluster-manager-5f4ffb94d5-xt68h                       1/1     Running   0          14h
cluster-proxy-addon-manager-66b7755f9b-n5qnm           1/1     Running   0          14h
cluster-proxy-addon-user-6fc7886d6-rp86z               2/2     Running   0          14h
cluster-proxy-c4f8b89bb-mx82z                          1/1     Running   0          14h
clusterclaims-controller-67cbd5947f-wg4q4              2/2     Running   0          14h
clusterlifecycle-state-metrics-v2-6b695659b4-xkwjs     1/1     Running   0          14h
console-mce-console-7f8cbf74bf-pdxml                   1/1     Running   0          14h
discovery-operator-6b65568cd7-hpn9j                    1/1     Running   0          14h
hcp-cli-download-5988975957-w6bct                      1/1     Running   0          14h
hive-operator-7b59b5b4b9-lhb47                         1/1     Running   0          14h
hypershift-addon-manager-f7dfb57c5-vvzlv               1/1     Running   0          14h
infrastructure-operator-79b9978b85-6pcmd               1/1     Running   0          14h
managedcluster-import-controller-v2-5666c7dc6f-q94pv   1/1     Running   0          14h
multicluster-engine-operator-6d6cd5bf87-7b7hp          1/1     Running   0          14h
multicluster-engine-operator-6d6cd5bf87-xbxdp          1/1     Running   0          14h
ocm-controller-69644bb4fd-ljtcg                        1/1     Running   0          14h
ocm-proxyserver-6495cfbf4b-bgxpf                       1/1     Running   0          14h
ocm-webhook-65775d6b76-q27p9                           1/1     Running   0          14h
provider-credential-controller-959695bd6-7hrgd         2/2     Running   0          14h
```

## Links
* [Configure additionalTrustedCA in RHOCP 4](https://access.redhat.com/solutions/6969479)
