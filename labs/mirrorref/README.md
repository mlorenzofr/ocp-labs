# mirrorref lab
In this lab, we install an Openshift Cluster with ACM and internal registry.  
In subsequent steps, we will mirror the Openshift release to the internal registry and deploy a spoke cluster using it.  

## Requirements
None.

## Steps
1. Install the Openlshift cluster `deploy.yaml`:
```shell
ap labs/mirrorref/deploy.yaml --tags ocp
```
2. Enable the Openshift image registry:
```shell
ap labs/mirrorref/deploy.yaml --tags postinst
```
<details>

<summary>
3. Mirror the Openshift release:
</summary>

1. Create a new `auth.json` with the kubeadmin credentials:
```shell
$ export REGISTRY_AUTH_FILE=/root/pull-secret.json
$ podman login --tls-verify=false -u kubeadmin -p $(oc whoami -t) default-route-openshift-image-registry.apps.mirrorref.local.lab
```
2. Create a new namespace
```shell
$ oc create ns openshift-release-dev
$ oc create ns edge-infrastructure
```
3. Mirror the release and assisted-service images to the internal registry:
```shell
$ oc adm release mirror --from=quay.io/openshift-release-dev/ocp-release:4.18.4-x86_64 --to=default-route-openshift-image-registry.apps.mirrorref.local.lab/openshift-release-dev/ocp-release --to-release-image=default-route-openshift-image-registry.apps.mirrorref.local.lab/openshift-release-dev/ocp-release:4.18.4-x86_64 --insecure=true -a /root/pull-secret.json

oc image mirror --insecure=true -a /root/pull-secret.json quay.io/edge-infrastructure/assisted-installer:latest default-route-openshift-image-registry.apps.mirrorref.local.lab/edge-infrastructure/assisted-installer:latest
oc image mirror --insecure=true -a /root/pull-secret.json quay.io/edge-infrastructure/assisted-installer-controller:latest default-route-openshift-image-registry.apps.mirrorref.local.lab/edge-infrastructure/assisted-installer-controller:latest
oc image mirror --insecure=true -a /root/pull-secret.json quay.io/edge-infrastructure/assisted-installer-agent:latest default-route-openshift-image-registry.apps.mirrorref.local.lab/edge-infrastructure/assisted-installer-agent:latest
```

</details>

4. Create the spoke cluster:
```shell
ap labs/mirrorref/deploy.yaml --tags hive
```

## Validation
1. Check if the Openshift cluster is running:
```shell
$ export KUBECONFIG=/root/labs/mirrorref/deploy/auth/kubeconfig

$ oc get nodes
NAME               STATUS   ROLES                         AGE     VERSION
mirrorref-node-1   Ready    control-plane,master,worker   5d14h   v1.31.6
mirrorref-node-2   Ready    control-plane,master,worker   5d14h   v1.31.6
mirrorref-node-3   Ready    control-plane,master,worker   5d14h   v1.31.6

$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.18.4    True        False         5d14h   Cluster version is 4.18.4
```
2. Validate that the _openshift-image-registry_ is running:
```shell
$ oc get pods -n openshift-image-registry
NAME                                              READY   STATUS      RESTARTS        AGE
cluster-image-registry-operator-f4d45f6c9-lnvmc   1/1     Running     2 (5d15h ago)   5d15h
image-registry-7797645547-w8w6p                   1/1     Running     0               4d22h
node-ca-b7qm9                                     1/1     Running     0               5d15h
node-ca-p78mm                                     1/1     Running     0               5d15h
node-ca-q5z2r                                     1/1     Running     0               5d15h

$ oc get pvc -n openshift-image-registry
NAME                     STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
image-registry-storage   Bound    pvc-d670c88a-a224-4f31-9da4-2b522dcf1bab   25Gi       RWO            lvms-vg1       <unset>                 4d23h

$ oc get route -n openshift-image-registry
NAME            HOST/PORT                                                         PATH   SERVICES         PORT    TERMINATION   WILDCARD
default-route   default-route-openshift-image-registry.apps.mirrorref.local.lab          image-registry   <all>   reencrypt     None
```
3. Check if the _spoke_ cluster works:
```shell
$ export KUBECONFIG=/root/labs/hive/spoke/auth/kubeconfig

$ oc get nodes
NAME              STATUS   ROLES                         AGE     VERSION
mirrorref-bmh-1   Ready    control-plane,master,worker   4d17h   v1.31.6

$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.18.6    True        False         4d17h   Cluster version is 4.18.6

$ oc get co
NAME                                       VERSION   AVAILABLE   PROGRESSING   DEGRADED   SINCE   MESSAGE
authentication                             4.18.6    True        False         False      3d17h
baremetal                                  4.18.6    True        False         False      4d17h
cloud-controller-manager                   4.18.6    True        False         False      4d17h
cloud-credential                           4.18.6    True        False         False      4d17h
cluster-autoscaler                         4.18.6    True        False         False      4d17h
config-operator                            4.18.6    True        False         False      4d17h
console                                    4.18.6    True        False         False      4d17h
control-plane-machine-set                  4.18.6    True        False         False      4d17h
csi-snapshot-controller                    4.18.6    True        False         False      4d17h
dns                                        4.18.6    True        False         False      4d17h
etcd                                       4.18.6    True        False         False      4d17h
image-registry                             4.18.6    True        False         False      4d17h
ingress                                    4.18.6    True        False         False      4d17h
insights                                   4.18.6    True        False         False      4d17h
kube-apiserver                             4.18.6    True        False         False      4d17h
kube-controller-manager                    4.18.6    True        False         False      4d17h
kube-scheduler                             4.18.6    True        False         False      4d17h
kube-storage-version-migrator              4.18.6    True        False         False      4d17h
machine-api                                4.18.6    True        False         False      4d17h
machine-approver                           4.18.6    True        False         False      4d17h
machine-config                             4.18.6    True        False         False      4d17h
marketplace                                4.18.6    True        False         False      4d17h
monitoring                                 4.18.6    True        False         False      4d17h
network                                    4.18.6    True        False         False      4d17h
node-tuning                                4.18.6    True        False         False      4d17h
olm                                        4.18.6    True        False         False      4d17h
openshift-apiserver                        4.18.6    True        False         False      4d17h
openshift-controller-manager               4.18.6    True        False         False      4d17h
openshift-samples                          4.18.6    True        False         False      4d17h
operator-lifecycle-manager                 4.18.6    True        False         False      4d17h
operator-lifecycle-manager-catalog         4.18.6    True        False         False      4d17h
operator-lifecycle-manager-packageserver   4.18.6    True        False         False      4d17h
service-ca                                 4.18.6    True        False         False      4d17h
storage                                    4.18.6    True        False         False      4d17h
```

## Links
* [Saas + on premise registry](https://github.com/openshift/assisted-service/blob/master/docs/user-guide/cloud-with-mirror.md)
