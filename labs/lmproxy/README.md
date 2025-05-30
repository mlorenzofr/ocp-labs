# lmproxy lab
In this lab the goal is install an Openshift Cluster in an offline environment with a proxy.

## Requirements

## Steps
1. Block Internet access from the lab network. This way we can be sure that the proxy is used.
```shell
iptables -I LIBVIRT_FWO 1 -s 192.168.129.0/24 ! -d 192.168.129.0/24 -j REJECT
```
2. Execute the playbook `deploy.yaml`:
```shell
ap labs/lmproxy/deploy.yaml --tags ocp
```

## Validation
1. Check if the cluster is running:
```shell
$ export KUBECONFIG=~/labs/lmproxy/deploy/auth/kubeconfig

$ oc get nodes
NAME             STATUS   ROLES                         AGE   VERSION
lmproxy-node-1   Ready    control-plane,master,worker   13m   v1.29.14+7cf4c05
lmproxy-node-2   Ready    control-plane,master,worker   30m   v1.29.14+7cf4c05
lmproxy-node-3   Ready    control-plane,master,worker   30m   v1.29.14+7cf4c05

$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.16.40   True        False         44s     Cluster version is 4.16.40

$ oc get co
NAME                                       VERSION   AVAILABLE   PROGRESSING   DEGRADED   SINCE   MESSAGE
authentication                             4.16.40   True        False         False      100s
baremetal                                  4.16.40   True        False         False      29m
cloud-controller-manager                   4.16.40   True        False         False      30m
cloud-credential                           4.16.40   True        False         False      32m
cluster-autoscaler                         4.16.40   True        False         False      29m
config-operator                            4.16.40   True        False         False      29m
console                                    4.16.40   True        False         False      10m
control-plane-machine-set                  4.16.40   True        False         False      29m
csi-snapshot-controller                    4.16.40   True        False         False      29m
dns                                        4.16.40   True        False         False      28m
etcd                                       4.16.40   True        False         False      27m
image-registry                             4.16.40   True        False         False      11m
ingress                                    4.16.40   True        False         False      14m
insights                                   4.16.40   True        False         False      22m
kube-apiserver                             4.16.40   True        False         False      18m
kube-controller-manager                    4.16.40   True        False         False      26m
kube-scheduler                             4.16.40   True        False         False      25m
kube-storage-version-migrator              4.16.40   True        False         False      29m
machine-api                                4.16.40   True        False         False      25m
machine-approver                           4.16.40   True        False         False      29m
machine-config                             4.16.40   True        False         False      28m
marketplace                                4.16.40   True        False         False      29m
monitoring                                 4.16.40   True        False         False      11m
network                                    4.16.40   True        False         False      29m
node-tuning                                4.16.40   True        False         False      13m
openshift-apiserver                        4.16.40   True        False         False      17m
openshift-controller-manager               4.16.40   True        False         False      24m
openshift-samples                          4.16.40   True        False         False      17m
operator-lifecycle-manager                 4.16.40   True        False         False      28m
operator-lifecycle-manager-catalog         4.16.40   True        False         False      28m
operator-lifecycle-manager-packageserver   4.16.40   True        False         False      21m
service-ca                                 4.16.40   True        False         False      29m
storage                                    4.16.40   True        False         False      29m
```

## Links
