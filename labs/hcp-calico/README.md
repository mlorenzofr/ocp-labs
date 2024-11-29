# hcp-calico lab
In this lab the goal is install an _Hosted cluster_ with Calico as SDN.

## caveats
Currently, this lab is not working.  
Using SDN `OVNKubernetes`, this deployment works fine.  
The _local-cluster_ `ManagedCluster` is not being imported and that blocks the MCE operator.
|  OCP     | MCE     | status             | comment                                                                                        |
|  :---:   | :------:           | :--------:         | :--------------------------------------:                                                       |
|  **4.16.9**   | **2.7.1** | :x: | |
|  **4.14.42**  | **2.6.3** | :x: | |
|  **4.17.7**   | **2.7.1** | :x: | |
```shell
$ oc get managedcluster
NAME            HUB ACCEPTED   MANAGED CLUSTER URLS   JOINED   AVAILABLE   AGE
local-cluster   true                                           Unknown     108m

$ oc get multiclusterengine/engine -o yaml
... ...
  - kind: local-cluster
    lastTransitionTime: "2024-11-29T15:28:04Z"
    message: Registration agent stopped updating its lease.
    name: local-cluster
    reason: ManagedClusterLeaseUpdateStopped
    status: Unknown
    type: ManagedClusterConditionAvailable
```

## Requirements
None.

## Steps
1. Deploy:
```shell
ap labs/hcp-calico/deploy.yaml
```

## Validation
1. Check if the _hub cluster_ is running:
```shell
$ export KUBECONFIG=/root/labs/hcp-calico/deploy/auth/kubeconfig

$ oc get nodes
NAME                STATUS   ROLES                         AGE   VERSION
hcp-calico-node-1   Ready    control-plane,master,worker   12m   v1.29.7+4510e9c
hcp-calico-node-2   Ready    control-plane,master,worker   29m   v1.29.7+4510e9c
hcp-calico-node-3   Ready    control-plane,master,worker   29m   v1.29.7+4510e9c

$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.16.9    True        False         77s     Cluster version is 4.16.9
```
2. Validate in the network configuration if the Network Type is set to Calico:
```shell
$ oc get network.config/cluster -o jsonpath='{.status.networkType}{"\n"}'
Calico
```
3. Check if _spoke cluster_ is running:
```shell
$ oc get managedcluster
NAME            HUB ACCEPTED   MANAGED CLUSTER URLS                    JOINED   AVAILABLE   AGE
hcp1            true           https://192.168.125.204:6443            True     True        27m
local-cluster   true           https://api.hcp-calico.local.lab:6443   True     True        31m

$ oc get hostedcluster -n hcp1
NAME   VERSION   KUBECONFIG              PROGRESS    AVAILABLE   PROGRESSING   MESSAGE
hcp1   4.17.0    hcp1-admin-kubeconfig   Completed   True        False         The hosted control plane is available
```
4. Check if the cluster **hcp1** works:
```shell
$ export KUBECONFIG=/root/labs/hcp-calico/hcp1/auth/kubeconfig

$ oc get nodes
NAME            STATUS   ROLES    AGE   VERSION
hcp1-worker-1   Ready    worker   16m   v1.30.4

$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.17.0    True        False         11m     Cluster version is 4.17.0

$ oc get co
NAME                                       VERSION   AVAILABLE   PROGRESSING   DEGRADED   SINCE   MESSAGE
console                                    4.17.0    True        False         False      13m
csi-snapshot-controller                    4.17.0    True        False         False      26m
dns                                        4.17.0    True        False         False      13m
image-registry                             4.17.0    True        False         False      14m
ingress                                    4.17.0    True        False         False      25m
insights                                   4.17.0    True        False         False      15m
kube-apiserver                             4.17.0    True        False         False      26m
kube-controller-manager                    4.17.0    True        False         False      26m
kube-scheduler                             4.17.0    True        False         False      26m
kube-storage-version-migrator              4.17.0    True        False         False      14m
monitoring                                 4.17.0    True        False         False      11m
network                                    4.17.0    True        False         False      16m
node-tuning                                4.17.0    True        False         False      17m
openshift-apiserver                        4.17.0    True        False         False      26m
openshift-controller-manager               4.17.0    True        False         False      26m
openshift-samples                          4.17.0    True        False         False      12m
operator-lifecycle-manager                 4.17.0    True        False         False      26m
operator-lifecycle-manager-catalog         4.17.0    True        False         False      26m
operator-lifecycle-manager-packageserver   4.17.0    True        False         False      26m
service-ca                                 4.17.0    True        False         False      15m
storage                                    4.17.0    True        False         False      26m
```
5. On the _spoke cluster_, review the Network Type:
```shell
$ oc get network.config/cluster -o jsonpath='{.status.networkType}{"\n"}'
Calico
```

## Links
* [Certified OpenShift CNI Plug-ins](https://access.redhat.com/articles/5436171)
