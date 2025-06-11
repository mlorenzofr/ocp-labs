# ztvp lab
This lab installs a compact Openshift cluster and configures default storage.  
This environment will be used as a base scenario for the deployment of _Validated Patterns_.

## Requirements
None.

## Steps
1. Deploy:
```shell
ap labs/ztvp/deploy.yaml
```

## Validation
1. Check if the Openshift cluster is running:
```shell
$ export KUBECONFIG=~/labs/ztvp/deploy/auth/kubeconfig

$ oc get nodes
NAME          STATUS   ROLES                         AGE    VERSION
ztvp-node-1   Ready    control-plane,master,worker   99m    v1.31.8
ztvp-node-2   Ready    control-plane,master,worker   112m   v1.31.8
ztvp-node-3   Ready    control-plane,master,worker   112m   v1.31.8

$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.18.16   True        False         109s    Cluster version is 4.18.16
```
2. Check if the cluster has a default `StorageClass`:
```shell
$ oc get sc
NAME                 PROVISIONER   RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
lvms-vg1 (default)   topolvm.io    Delete          WaitForFirstConsumer   true                   78s
```

## Links
* [Validated Patterns](https://validatedpatterns.io/)
* [Validated Patters at GitHub](https://github.com/validatedpatterns)
* [Deploying the Multicloud GitOps pattern](https://validatedpatterns.io/patterns/multicloud-gitops/mcg-getting-started/)
* [multicloud-gitops repo](https://github.com/validatedpatterns/multicloud-gitops)
