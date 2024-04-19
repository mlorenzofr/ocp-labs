# HCP-compact lab
In this lab the goal is install **Hypershift** on a _compact_ Openshift control plane.  
The management control plane and the hosted control planes will share the same nodes.  
Two _spoke clusters_ (`HostedCluster`) will be created.

## Requirements
We need to use big nodes because the resources growth with the number of _spoke clusters_.  
Each _spoke cluster_ uses about 4 Gib of memory each _hub_ node.  

## Steps
1. Execute the playbook `hcp-compact.yaml`:
```shell
ap labs/hcp-compact/hcp-compact.yaml
```

## Validation
1. Check if the _hub cluster_ is running:
```shell
$ export KUBECONFIG=/root/labs/hcp/deploy/auth/kubeconfig

$ oc get nodes
NAME           STATUS   ROLES                         AGE   VERSION
hcp-master-1   Ready    control-plane,master,worker   85m   v1.28.7+f1b5f6c
hcp-master-2   Ready    control-plane,master,worker   85m   v1.28.7+f1b5f6c
hcp-master-3   Ready    control-plane,master,worker   85m   v1.28.7+f1b5f6c

$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.15.4    True        False         69m     Cluster version is 4.15.4
```
2. Check if _spoke clusters_ are running:
```shell
$ oc get managedcluster
NAME            HUB ACCEPTED   MANAGED CLUSTER URLS             JOINED   AVAILABLE   AGE
hcp1            true           https://192.168.125.41:6443      True     True        37m
hcp2            true           https://192.168.125.40:6443      True     True        37m
local-cluster   true           https://api.hcp.local.lab:6443   True     True        75m

$ oc get hostedcluster -n hcp1
NAME   VERSION   KUBECONFIG              PROGRESS    AVAILABLE   PROGRESSING   MESSAGE
hcp1   4.14.8    hcp1-admin-kubeconfig   Completed   True        False         The hosted control plane is available

$ oc get hostedcluster -n hcp2
NAME   VERSION   KUBECONFIG              PROGRESS    AVAILABLE   PROGRESSING   MESSAGE
hcp2   4.14.13   hcp2-admin-kubeconfig   Completed   True        False         The hosted control plane is available

```
3. Check if we have 3 etcd pods, and they are running in different nodes:
```shell
$ oc get pods -n hcp1-hcp1 -o wide | grep etcd
etcd-0                                                3/3     Running   0          39m   10.132.0.125   hcp-master-3   <none>           <none>
etcd-1                                                3/3     Running   0          39m   10.134.0.118   hcp-master-2   <none>           <none>
etcd-2                                                3/3     Running   0          39m   10.133.0.119   hcp-master-1   <none>           <none>

$ oc get pods -n hcp2-hcp2 -o wide | grep etcd
etcd-0                                                3/3     Running   0          40m   10.132.0.124   hcp-master-3   <none>           <none>
etcd-1                                                3/3     Running   0          40m   10.134.0.117   hcp-master-2   <none>           <none>
etcd-2                                                3/3     Running   0          40m   10.133.0.118   hcp-master-1   <none>           <none>
```
4. Check if the cluster **hcp1** works:
```shell
$ export KUBECONFIG=/root/labs/hcp/hcp1/auth/kubeconfig

$ oc get nodes
ME            STATUS   ROLES    AGE   VERSION
hcp1-worker-1   Ready    worker   16m   v1.27.8+4fab27b

$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.14.8    True        False         82s     Cluster version is 4.14.8

$ oc get co
NAME                                       VERSION   AVAILABLE   PROGRESSING   DEGRADED   SINCE   MESSAGE
console                                    4.14.8    True        False         False      12m
csi-snapshot-controller                    4.14.8    True        False         False      40m
dns                                        4.14.8    True        False         False      26m
image-registry                             4.14.8    True        False         False      27m
ingress                                    4.14.8    True        False         False      39m
insights                                   4.14.8    True        False         False      28m
kube-apiserver                             4.14.8    True        False         False      40m
kube-controller-manager                    4.14.8    True        False         False      40m
kube-scheduler                             4.14.8    True        False         False      40m
kube-storage-version-migrator              4.14.8    True        False         False      28m
monitoring                                 4.14.8    True        False         False      26m
network                                    4.14.8    True        False         False      30m
node-tuning                                4.14.8    True        False         False      32m
openshift-apiserver                        4.14.8    True        False         False      40m
openshift-controller-manager               4.14.8    True        False         False      40m
openshift-samples                          4.14.8    True        False         False      26m
operator-lifecycle-manager                 4.14.8    True        False         False      39m
operator-lifecycle-manager-catalog         4.14.8    True        False         False      39m
operator-lifecycle-manager-packageserver   4.14.8    True        False         False      40m
service-ca                                 4.14.8    True        False         False      28m
storage                                    4.14.8    True        False         False      40m
```
5. Check if the cluster **hcp2** works:
```shell
$ export KUBECONFIG=/root/labs/hcp/hcp2/auth/kubeconfig

$ oc get nodes
NAME            STATUS   ROLES    AGE   VERSION
hcp2-worker-1   Ready    worker   22m   v1.27.10+28ed2d7

$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.14.13   True        False         12m     Cluster version is 4.14.13

$ oc get co
NAME                                       VERSION   AVAILABLE   PROGRESSING   DEGRADED   SINCE   MESSAGE
console                                    4.14.13   True        False         False      26m
csi-snapshot-controller                    4.14.13   True        False         False      39m
dns                                        4.14.13   True        False         False      29m
image-registry                             4.14.13   True        False         False      29m
ingress                                    4.14.13   True        False         False      38m
insights                                   4.14.13   True        False         False      30m
kube-apiserver                             4.14.13   True        False         False      39m
kube-controller-manager                    4.14.13   True        False         False      39m
kube-scheduler                             4.14.13   True        False         False      39m
kube-storage-version-migrator              4.14.13   True        False         False      30m
monitoring                                 4.14.13   True        False         False      27m
network                                    4.14.13   True        False         False      30m
node-tuning                                4.14.13   True        False         False      32m
openshift-apiserver                        4.14.13   True        False         False      39m
openshift-controller-manager               4.14.13   True        False         False      39m
openshift-samples                          4.14.13   True        False         False      29m
operator-lifecycle-manager                 4.14.13   True        False         False      39m
operator-lifecycle-manager-catalog         4.14.13   True        False         False      39m
operator-lifecycle-manager-packageserver   4.14.13   True        False         False      39m
service-ca                                 4.14.13   True        False         False      30m
storage                                    4.14.13   True        False         False      39m
```

## Links
