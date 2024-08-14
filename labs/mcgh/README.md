# mgh lab
This lab is composed by 3 Openshift clusters:
* 1 node with **MultiCluster Global Hub** (MCGH).
* 2 Single Node Clusters (SNOs), with **Advanced Cluster Management** (ACM) and **Advanced Cluster Security** (ACS).

The SNO clusters (hub clusters) will be imported to the MCGH cluster (global cluster).

## Requirements
The ACM nodes, where ACS is installed, require at least 40 GB of memory and 14 CPUs due to the ACS minimum requirements. Additionally, 100 GiB of local storage will be needed for the **central-db** database.

All ACS requirements and detailed information are available [here](https://docs.openshift.com/acs/4.5/installing/acs-default-requirements.html).

## Steps
1. Deploy the lab with:
```shell
ap labs/mcgh/deploy.yaml
```
2. Validate

## Validation
1. Check if the MCGH cluster is running:
```shell
$ export KUBECONFIG=/root/labs/mcgh/deploy/auth/kubeconfig

$ oc get nodes
NAME          STATUS   ROLES                         AGE   VERSION
mcgh-node-1   Ready    control-plane,master,worker   40m   v1.29.6+aba1e8d
mcgh-node-2   Ready    control-plane,master,worker   63m   v1.29.6+aba1e8d
mcgh-node-3   Ready    control-plane,master,worker   63m   v1.29.6+aba1e8d

$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.16.3    True        False         30m     Cluster version is 4.16.3
```
2. Check if MultiCluster Global Hub pods are running:
```shell
$ oc get pods -n multicluster-global-hub
NAME                                                     READY   STATUS    RESTARTS      AGE
amq-streams-cluster-operator-v2.6.0-2-57d798447b-84rch   1/1     Running   0             20m
kafka-entity-operator-544956fcf5-q2dpx                   3/3     Running   0             5m15s
kafka-kafka-0                                            1/1     Running   0             5m44s
kafka-kafka-1                                            1/1     Running   0             5m43s
kafka-kafka-2                                            1/1     Running   0             5m43s
kafka-zookeeper-0                                        1/1     Running   0             19m
kafka-zookeeper-1                                        1/1     Running   0             19m
kafka-zookeeper-2                                        1/1     Running   0             19m
multicluster-global-hub-grafana-6f898cb887-94bl7         2/2     Running   0             4m39s
multicluster-global-hub-grafana-6f898cb887-g6pvz         2/2     Running   0             4m39s
multicluster-global-hub-manager-754cd8d57c-h2fps         1/1     Running   0             4m41s
multicluster-global-hub-manager-754cd8d57c-jfl8x         1/1     Running   0             4m41s
multicluster-global-hub-operator-9888f8bff-r48vv         1/1     Running   1 (10m ago)   20m
multicluster-global-hub-postgres-0                       2/2     Running   0             20m
```
3. On ACM clusters, check if ACS pods are running:
```shell
$ export KUBECONFIG=/root/labs/acm1/deploy/auth/kubeconfig

$ oc get pods -n rhacs-operator
NAME                                                 READY   STATUS    RESTARTS   AGE
central-855476649d-lfm4z                             1/1     Running   0          8m49s
central-db-75c94f999-nd727                           1/1     Running   0          8m49s
rhacs-operator-controller-manager-566d8848dd-fqjwr   1/1     Running   0          9m41s
scanner-55c8874bdd-4vn8p                             1/1     Running   0          8m49s
scanner-db-5c99759dc7-rsqrg                          1/1     Running   0          8m49s
```

## Links
* [Multicluster Global Hub repository](https://github.com/stolostron/multicluster-global-hub/tree/main)
* [Advanced Cluster Security repository](https://github.com/stackrox/stackrox/tree/master)
* [ACS Support Matrix](https://access.redhat.com/articles/7045053)
* [ACS default requirements](https://docs.openshift.com/acs/4.5/installing/acs-default-requirements.html)
