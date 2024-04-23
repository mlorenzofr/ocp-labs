# okd lab
In this lab the goal is install an OKD Cluster.

## Requirements
We need the `openshift-install` binaries downloaded and ready in the installation host.
```shell
$ oc adm release extract --registry-config /tmp/pull-secret.txt --command=openshift-baremetal-install --to /usr/local/bin quay.io/openshift/okd:4.12.0-0.okd-2023-04-16-041331
$ oc adm release extract --registry-config /tmp/pull-secret.txt --command=openshift-install --to /usr/local/bin quay.io/openshift/okd:4.12.0-0.okd-2023-04-16-041331
$ oc adm release extract --registry-config /tmp/pull-secret.txt --command=oc --to /usr/local/bin quay.io/openshift/okd:4.12.0-0.okd-2023-04-16-041331
```

## Steps
1. Execute the playbook `deploy.yaml`:
```shell
ap labs/okd/deploy.yaml
```

## Validation
1. Check if the _hub cluster_ is running:
```shell
$ export KUBECONFIG=/root/labs/okdb/deploy/auth/kubeconfig

$ oc get nodes
NAME            STATUS   ROLES                         AGE   VERSION
okdb-master-1   Ready    control-plane,master,worker   59m   v1.25.8+27e744f
okdb-master-2   Ready    control-plane,master,worker   59m   v1.25.8+27e744f
okdb-master-3   Ready    control-plane,master,worker   59m   v1.25.8+27e744f

$ oc get clusterversion
NAME      VERSION                          AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.12.0-0.okd-2023-04-16-041331   True        False         41m     Cluster version is 4.12.0-0.okd-2023-04-16-041331

$ oc get co
NAME                                       VERSION                          AVAILABLE   PROGRESSING   DEGRADED   SINCE   MESSAGE
authentication                             4.12.0-0.okd-2023-04-16-041331   True        False         False      33m
baremetal                                  4.12.0-0.okd-2023-04-16-041331   True        False         False      47m
cloud-controller-manager                   4.12.0-0.okd-2023-04-16-041331   True        False         False      50m
cloud-credential                           4.12.0-0.okd-2023-04-16-041331   True        False         False      59m
cluster-autoscaler                         4.12.0-0.okd-2023-04-16-041331   True        False         False      46m
config-operator                            4.12.0-0.okd-2023-04-16-041331   True        False         False      48m
console                                    4.12.0-0.okd-2023-04-16-041331   True        False         False      37m
control-plane-machine-set                  4.12.0-0.okd-2023-04-16-041331   True        False         False      46m
csi-snapshot-controller                    4.12.0-0.okd-2023-04-16-041331   True        False         False      47m
dns                                        4.12.0-0.okd-2023-04-16-041331   True        False         False      46m
etcd                                       4.12.0-0.okd-2023-04-16-041331   True        False         False      45m
image-registry                             4.12.0-0.okd-2023-04-16-041331   True        False         False      37m
ingress                                    4.12.0-0.okd-2023-04-16-041331   True        False         False      40m
insights                                   4.12.0-0.okd-2023-04-16-041331   True        False         False      40m
kube-apiserver                             4.12.0-0.okd-2023-04-16-041331   True        False         False      42m
kube-controller-manager                    4.12.0-0.okd-2023-04-16-041331   True        False         False      44m
kube-scheduler                             4.12.0-0.okd-2023-04-16-041331   True        False         False      44m
kube-storage-version-migrator              4.12.0-0.okd-2023-04-16-041331   True        False         False      47m
machine-api                                4.12.0-0.okd-2023-04-16-041331   True        False         False      43m
machine-approver                           4.12.0-0.okd-2023-04-16-041331   True        False         False      47m
machine-config                             4.12.0-0.okd-2023-04-16-041331   True        False         False      45m
marketplace                                4.12.0-0.okd-2023-04-16-041331   True        False         False      46m
monitoring                                 4.12.0-0.okd-2023-04-16-041331   True        False         False      39m
network                                    4.12.0-0.okd-2023-04-16-041331   True        False         False      47m
node-tuning                                4.12.0-0.okd-2023-04-16-041331   True        False         False      46m
openshift-apiserver                        4.12.0-0.okd-2023-04-16-041331   True        False         False      41m
openshift-controller-manager               4.12.0-0.okd-2023-04-16-041331   True        False         False      41m
openshift-samples                          4.12.0-0.okd-2023-04-16-041331   True        False         False      39m
operator-lifecycle-manager                 4.12.0-0.okd-2023-04-16-041331   True        False         False      47m
operator-lifecycle-manager-catalog         4.12.0-0.okd-2023-04-16-041331   True        False         False      47m
operator-lifecycle-manager-packageserver   4.12.0-0.okd-2023-04-16-041331   True        False         False      41m
service-ca                                 4.12.0-0.okd-2023-04-16-041331   True        False         False      47m
storage                                    4.12.0-0.okd-2023-04-16-041331   True        False         False      48m
```

## Links
* [OKD release images](https://quay.io/repository/openshift/okd?tab=tags)
