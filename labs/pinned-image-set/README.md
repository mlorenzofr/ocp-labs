# pinned-image-set lab

## Requirements
This lab uses its own network. Create it with:
```shell
kcli create network -c 192.168.129.0/24 -P dhcp=false -P dns=false --domain local.lab pinnedis-net
```
A local regitry has been configured on a different host.
The configuration of this additional server is explained [here](docs/registry-server.md).

## Steps
1. Execute the playbook `deploy.yaml`:
```shell
ap labs/pinned-image-set/deploy.yaml
```

## Validation
1. Check if the Openshift cluster is running:
```shell
$ export KUBECONFIG=/root/labs/pinnedis/deploy/auth/kubeconfig

$ oc get nodes
NAME              STATUS   ROLES                         AGE     VERSION
pinnedis-node-1   Ready    control-plane,master,worker   7m13s   v1.29.5+87992f4
pinnedis-node-2   Ready    control-plane,master,worker   20m     v1.29.5+87992f4
pinnedis-node-3   Ready    control-plane,master,worker   20m     v1.29.5+87992f4

$ oc get clusterversion
NAME      VERSION                              AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.16.0-0.nightly-2024-06-06-064349   True        False         41s     Cluster version is 4.16.0-0.nightly-2024-06-06-064349

$ oc get co
NAME                                       VERSION                              AVAILABLE   PROGRESSING   DEGRADED   SINCE   MESSAGE
authentication                             4.16.0-0.nightly-2024-06-06-064349   True        False         False      8m16s
baremetal                                  4.16.0-0.nightly-2024-06-06-064349   True        False         False      29m
cloud-controller-manager                   4.16.0-0.nightly-2024-06-06-064349   True        False         False      31m
cloud-credential                           4.16.0-0.nightly-2024-06-06-064349   True        False         False      32m
cluster-autoscaler                         4.16.0-0.nightly-2024-06-06-064349   True        False         False      29m
config-operator                            4.16.0-0.nightly-2024-06-06-064349   True        False         False      30m
console                                    4.16.0-0.nightly-2024-06-06-064349   True        False         False      14m
control-plane-machine-set                  4.16.0-0.nightly-2024-06-06-064349   True        False         False      29m
csi-snapshot-controller                    4.16.0-0.nightly-2024-06-06-064349   True        False         False      30m
dns                                        4.16.0-0.nightly-2024-06-06-064349   True        False         False      29m
etcd                                       4.16.0-0.nightly-2024-06-06-064349   True        False         False      28m
image-registry                             4.16.0-0.nightly-2024-06-06-064349   True        False         False      16m
ingress                                    4.16.0-0.nightly-2024-06-06-064349   True        False         False      22m
insights                                   4.16.0-0.nightly-2024-06-06-064349   True        False         False      23m
kube-apiserver                             4.16.0-0.nightly-2024-06-06-064349   True        False         False      26m
kube-controller-manager                    4.16.0-0.nightly-2024-06-06-064349   True        False         False      27m
kube-scheduler                             4.16.0-0.nightly-2024-06-06-064349   True        False         False      26m
kube-storage-version-migrator              4.16.0-0.nightly-2024-06-06-064349   True        False         False      30m
machine-api                                4.16.0-0.nightly-2024-06-06-064349   True        False         False      25m
machine-approver                           4.16.0-0.nightly-2024-06-06-064349   True        False         False      29m
machine-config                             4.16.0-0.nightly-2024-06-06-064349   True        False         False      29m
marketplace                                4.16.0-0.nightly-2024-06-06-064349   True        False         False      29m
monitoring                                 4.16.0-0.nightly-2024-06-06-064349   True        False         False      15m
network                                    4.16.0-0.nightly-2024-06-06-064349   True        False         False      30m
node-tuning                                4.16.0-0.nightly-2024-06-06-064349   True        False         False      16m
openshift-apiserver                        4.16.0-0.nightly-2024-06-06-064349   True        False         False      23m
openshift-controller-manager               4.16.0-0.nightly-2024-06-06-064349   True        False         False      25m
openshift-samples                          4.16.0-0.nightly-2024-06-06-064349   True        False         False      23m
operator-lifecycle-manager                 4.16.0-0.nightly-2024-06-06-064349   True        False         False      29m
operator-lifecycle-manager-catalog         4.16.0-0.nightly-2024-06-06-064349   True        False         False      29m
operator-lifecycle-manager-packageserver   4.16.0-0.nightly-2024-06-06-064349   True        False         False      24m
service-ca                                 4.16.0-0.nightly-2024-06-06-064349   True        False         False      30m
storage                                    4.16.0-0.nightly-2024-06-06-064349   True        False         False      30m
```

## Links
* [Openshift dev releases](https://quay.io/repository/openshift-release-dev/ocp-release?tab=tags)
* [Openshift 4.16 clients](https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/4.16.0-rc.3)
* [Mirroring images using oc-mirror](https://docs.openshift.com/container-platform/4.15/installing/disconnected_install/installing-mirroring-disconnected.html)
