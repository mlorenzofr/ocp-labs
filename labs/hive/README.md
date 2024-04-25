# hive lab
In this lab the goal is install an Openshift Cluster with a **SNO** _spoke cluster_ inside.  
The cluster will be type **standalone** (not _hosted_ like Hypershift).

## Custom Resources (CRs)
The CRs of interest used in this lab are:
* `ClusterImageSet`. It references an OpenShift release image. This will be used by the `ClusterDeployment` to know what version of Openshill install.
* `ClusterDeployment`. It is the object used to define a cluster. Here we set the properties and installation method.
* `AgentClusterInstall`. This object is an hive extension used to install the cluster using the `assisted-service` API.

## Requirements
None.

## Steps
1. Execute the playbook `deploy.yaml`:
```shell
ap labs/hive/deploy.yaml
```

## Validation
1. Check if the _hub cluster_ is running:
```shell
$ export KUBECONFIG=/root/labs/hive/deploy/auth/kubeconfig

$ oc get nodes
NAME            STATUS   ROLES                         AGE   VERSION
hive-master-1   Ready    control-plane,master,worker   31m   v1.28.7+f1b5f6c
hive-master-2   Ready    control-plane,master,worker   30m   v1.28.7+f1b5f6c
hive-master-3   Ready    control-plane,master,worker   31m   v1.28.7+f1b5f6c

$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.15.4    True        False         12m     Cluster version is 4.15.4
```
2. Check if the _spoke cluster_ is provisioned:
```shell
$ oc get bmh -n hive-sno
NAME         STATE         CONSUMER   ONLINE   ERROR   AGE
hive-bmh-1   provisioned              true             37m

$ oc get clusterdeployment -n hive-sno
NAME    INFRAID                                PLATFORM          REGION   VERSION   CLUSTERTYPE   PROVISIONSTATUS   POWERSTATE   AGE
spoke   63414bd9-45af-48f7-9df1-702a8e7e0133   agent-baremetal            4.14.8                  Provisioned       Running      32m
```
3. Check if the _spoke_ cluster works:
```shell
$ export KUBECONFIG=/root/labs/hive/spoke/auth/kubeconfig

$ oc get nodes
NAME         STATUS   ROLES                         AGE   VERSION
hive-bmh-1   Ready    control-plane,master,worker   19m   v1.27.8+4fab27b

$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.14.8    True        False         5m45s   Cluster version is 4.14.8

$ oc get co
NAME                                       VERSION   AVAILABLE   PROGRESSING   DEGRADED   SINCE   MESSAGE
authentication                             4.14.8    True        False         False      7m57s
baremetal                                  4.14.8    True        False         False      15m
cloud-controller-manager                   4.14.8    True        False         False      15m
cloud-credential                           4.14.8    True        False         False      15m
cluster-autoscaler                         4.14.8    True        False         False      15m
config-operator                            4.14.8    True        False         False      20m
console                                    4.14.8    True        False         False      7m49s
control-plane-machine-set                  4.14.8    True        False         False      15m
csi-snapshot-controller                    4.14.8    True        False         False      19m
dns                                        4.14.8    True        False         False      19m
etcd                                       4.14.8    True        False         False      15m
image-registry                             4.14.8    True        False         False      9m58s
ingress                                    4.14.8    True        False         False      19m
insights                                   4.14.8    True        False         False      15m
kube-apiserver                             4.14.8    True        False         False      11m
kube-controller-manager                    4.14.8    True        False         False      6m27s
kube-scheduler                             4.14.8    True        False         False      10m
kube-storage-version-migrator              4.14.8    True        False         False      20m
machine-api                                4.14.8    True        False         False      15m
machine-approver                           4.14.8    True        False         False      15m
machine-config                             4.14.8    True        False         False      13m
marketplace                                4.14.8    True        False         False      19m
monitoring                                 4.14.8    True        False         False      7m8s
network                                    4.14.8    True        False         False      21m
node-tuning                                4.14.8    True        False         False      19m
openshift-apiserver                        4.14.8    True        False         False      6m27s
openshift-controller-manager               4.14.8    True        False         False      9m47s
openshift-samples                          4.14.8    True        False         False      9m40s
operator-lifecycle-manager                 4.14.8    True        False         False      15m
operator-lifecycle-manager-catalog         4.14.8    True        False         False      19m
operator-lifecycle-manager-packageserver   4.14.8    True        False         False      11m
service-ca                                 4.14.8    True        False         False      20m
storage                                    4.14.8    True        False         False      15m
```

## Links
* [Using Hive](https://github.com/openshift/hive/blob/master/docs/using-hive.md)
* [ClusterDeployment Spec](https://github.com/openshift/hive/blob/master/apis/hive/v1/clusterdeployment_types.go)
* [AgentClusterInstall Spec](https://github.com/openshift/assisted-service/blob/master/api/hiveextension/v1beta1/agentclusterinstall_types.go)
