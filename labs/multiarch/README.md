# multiarch lab
The goal of this lab is to create an environment with a hub cluster running ACM and a managed cluster.  
In the managed cluster, we have 3 nodes with `x86_64` architecture.  
The final step would be to add a new `aarch64` node to the managed cluster.

## Requirements
None.

## Steps
1. Deploy:
```shell
ap labs/multiarch/deploy.yaml
```

## Validation
1. Check if the _hub cluster_ is running:
```shell
$ export KUBECONFIG=/root/labs/multiarch/deploy/auth/kubeconfig

$ oc get nodes
NAME                 STATUS   ROLES                         AGE   VERSION
multiarch-master-1   Ready    control-plane,master,worker   23m   v1.31.6
multiarch-master-2   Ready    control-plane,master,worker   36m   v1.31.6
multiarch-master-3   Ready    control-plane,master,worker   36m   v1.31.6

$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.18.4    True        False         57m     Cluster version is 4.18.4
```
2. Check if the _spoke cluster_ is provisioned:
```shell
$ oc get bmh -n managed
ME              STATE         CONSUMER   ONLINE   ERROR   AGE
multiarch-bmh-1   provisioned              true             36m
multiarch-bmh-2   provisioned              true             36m
multiarch-bmh-3   provisioned              true             36m

$ oc get clusterdeployment -n managed
NAME              INFRAID                                PLATFORM          REGION   VERSION   CLUSTERTYPE   PROVISIONSTATUS   POWERSTATE   AGE
spoke-multiarch   9e35c484-1f1d-4841-a701-63f28cb7f3f5   agent-baremetal            4.18.6                  Provisioned       Running      36m

$ oc get agent -n managed
NAME                                   CLUSTER           APPROVED   ROLE     STAGE
205c7fa3-c8f8-4974-b4b5-403df107386e   spoke-multiarch   true       master   Done
ba9ffd52-70e2-4538-b43a-914398811171   spoke-multiarch   true       master   Done
f419d363-a128-4924-ab31-96f634fde52a   spoke-multiarch   true       master   Done
```
3. Check if the _spoke_ cluster works:
```shell
$ export KUBECONFIG=/root/labs/multiarch/spoke-multiarch/auth/kubeconfig

$ oc get nodes
NAME              STATUS   ROLES                         AGE   VERSION
multiarch-bmh-1   Ready    control-plane,master,worker   11m   v1.31.6
multiarch-bmh-2   Ready    control-plane,master,worker   27m   v1.31.6
multiarch-bmh-3   Ready    control-plane,master,worker   27m   v1.31.6

$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.18.6    True        False         5m48s   Cluster version is 4.18.6
```
4. Check if the _spoke_ cluster is a `ManagedCluster`:
```shell
$ oc get managedcluster -A
NAME              HUB ACCEPTED   MANAGED CLUSTER URLS                         JOINED   AVAILABLE   AGE
local-cluster     true           https://api.multiarch.local.lab:6443         True     True        79m
spoke-multiarch   true           https://api.spoke-multiarch.local.lab:6443   True     True        18m
```

## Links
* [ACM - Creating a host inventory](https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/2.13/html/clusters/cluster_mce_overview#create-host-inventory-cli-steps)
* [Ironic Agent Image](https://github.com/openshift/assisted-service/tree/master/docs/hive-integration#ironic-agent-image)
* [RFE - Finding the right ironic agent image for mixed cpu architecture spoke cluster deployment from hub cluster](https://issues.redhat.com/browse/MGMT-19999)
