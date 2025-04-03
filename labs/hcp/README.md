# hcp lab
In this lab the goal is install **Hypershift** on a _compact_ Openshift control plane.  
The management control plane and the hosted control planes will share the same nodes.  

## Requirements
We need to use big nodes because the resources growth with the number of _spoke clusters_.  
Each _spoke cluster_ uses about 4 Gib of memory each _hub_ node.  

## Steps
1. Execute the playbook `deploy.yaml`:
```shell
ap labs/hcp/deploy.yaml
```

## Validation
1. Check if the _hub cluster_ is running:
```shell
$ export KUBECONFIG=/root/labs/hcp/deploy/auth/kubeconfig

$ oc get nodes
NAME         STATUS   ROLES                         AGE   VERSION
hcp-node-1   Ready    control-plane,master,worker   63m   v1.31.6
hcp-node-2   Ready    control-plane,master,worker   79m   v1.31.6
hcp-node-3   Ready    control-plane,master,worker   79m   v1.31.6

$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.18.4    True        False         54m     Cluster version is 4.18.4
```
2. Check if _spoke clusters_ are running:
```shell
$ oc get managedcluster
NAME            HUB ACCEPTED   MANAGED CLUSTER URLS             JOINED   AVAILABLE   AGE
local-cluster   true           https://api.hcp.local.lab:6443   True     True        51m
spoke           true           https://192.168.125.102:6443     True     True        47m

$ oc get hostedcluster -n spoke
NAME    VERSION   KUBECONFIG               PROGRESS    AVAILABLE   PROGRESSING   MESSAGE
spoke   4.18.4    spoke-admin-kubeconfig   Completed   True        False         The hosted control plane is available

$ oc get nodepool -n spoke
NAME               CLUSTER   DESIRED NODES   CURRENT NODES   AUTOSCALING   AUTOREPAIR   VERSION   UPDATINGVERSION   UPDATINGCONFIG   MESSAGE
nodepool-spoke-1   spoke     1               1               False         False        4.18.4    False             False
```
3. Check if the cluster **spoke** works:
```shell
$ export KUBECONFIG=/root/labs/hcp/spoke/auth/kubeconfig

$ oc get nodes
NAME            STATUS   ROLES    AGE   VERSION
hcp1-worker-1   Ready    worker   40m   v1.31.6

$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.18.4    True        False         27m     Cluster version is 4.18.4

$ oc get co
NAME                                       VERSION   AVAILABLE   PROGRESSING   DEGRADED   SINCE   MESSAGE
console                                    4.18.4    True        False         False      31m
csi-snapshot-controller                    4.18.4    True        False         False      48m
dns                                        4.18.4    True        False         False      36m
image-registry                             4.18.4    True        False         False      36m
ingress                                    4.18.4    True        False         False      48m
insights                                   4.18.4    True        False         False      37m
kube-apiserver                             4.18.4    True        False         False      48m
kube-controller-manager                    4.18.4    True        False         False      48m
kube-scheduler                             4.18.4    True        False         False      48m
kube-storage-version-migrator              4.18.4    True        False         False      37m
monitoring                                 4.18.4    True        False         False      35m
network                                    4.18.4    True        False         False      39m
node-tuning                                4.18.4    True        False         False      40m
openshift-apiserver                        4.18.4    True        False         False      48m
openshift-controller-manager               4.18.4    True        False         False      48m
openshift-samples                          4.18.4    True        False         False      36m
operator-lifecycle-manager                 4.18.4    True        False         False      48m
operator-lifecycle-manager-catalog         4.18.4    True        False         False      48m
operator-lifecycle-manager-packageserver   4.18.4    True        False         False      48m
service-ca                                 4.18.4    True        False         False      37m
storage                                    4.18.4    True        False         False      48m
```

## Links
