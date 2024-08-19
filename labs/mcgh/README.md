# mcgh lab
This lab is composed by 3 Openshift clusters:
* 1 node with **MultiCluster Global Hub** (MCGH).
* 2 Single Node Clusters (SNOs), with **Advanced Cluster Management** (ACM) and **Advanced Cluster Security** (ACS).
* 2+ Single Node Clusters (SNOs), with **Advanced Cluster Security** (ACS) as secured clusters.

The SNO clusters with ACM (hub clusters) will be imported to the MCGH cluster (global cluster).  
The SNO clusters with ACS only (spoke clusters) will be imported to the hub clusters.

## Requirements
The ACM nodes, where ACS is installed, require at least 40 GB of memory and 14 CPUs due to the ACS minimum requirements. Additionally, 100 GiB of local storage will be needed for the **central-db** database.

All ACS requirements and detailed information are available [here](https://docs.openshift.com/acs/4.5/installing/acs-default-requirements.html).

## Steps
1. Deploy the lab with:
```shell
ap labs/mcgh/deploy.yaml
```
2. Create a new ACS init bundle for earch Hub cluster in the `central` web console:  
	* [Cluster init bundles Hub cluster #1](https://central-rhacs-operator.apps.acm1.local.lab/main/clusters/init-bundles)
 	* [Cluster init bundles Hub cluster #2](https://central-rhacs-operator.apps.acm2.local.lab/main/clusters/init-bundles)
3. Copy the ACS init bundles to the `config` directory of the spoke clusters.
4. Create the ACS secrets on the spoke clusters:
```shell
$ export KUBECONFIG=/root/labs/spoke1/deploy/auth/kubeconfig

$ oc create -f /root/labs/spoke1/config/acm1-Operator-secrets-cluster-init-bundle.yaml -n rhacs-operator
```
5. Validate

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
4. On the MultiCluster Global Hub, check if the ACM (hub) clusters have been imported:
```shell
$ export KUBECONFIG=/root/labs/mcgh/deploy/auth/kubeconfig

$ oc get managedcluster
NAME            HUB ACCEPTED   MANAGED CLUSTER URLS              JOINED   AVAILABLE   AGE
acm1            true           https://api.acm1.local.lab:6443   True     True        11m
acm2            true           https://api.acm2.local.lab:6443   True     True        7m3s
local-cluster   true           https://api.mcgh.local.lab:6443   True     True        5d19h
```
5. On the MultiCluster Global Hub, check the global hub agent status to ensure that the agent is running:
```shell
$ oc get managedclusteraddon multicluster-global-hub-controller -n acm1
NAME                                 AVAILABLE   DEGRADED   PROGRESSING
multicluster-global-hub-controller   True                   False

$ oc get managedclusteraddon multicluster-global-hub-controller -n acm2
NAME                                 AVAILABLE   DEGRADED   PROGRESSING
multicluster-global-hub-controller   True                   False
```
6. On ACM clusters, check if the **MultiCluster Global Hub Agent** is present:
```shell
$ export KUBECONFIG=/root/labs/acm1/deploy/auth/kubeconfig

$ oc get all -n multicluster-global-hub-agent
Warning: apps.openshift.io/v1 DeploymentConfig is deprecated in v4.14+, unavailable in v4.10000+
NAME                                                READY   STATUS    RESTARTS   AGE
pod/multicluster-global-hub-agent-9ccb8bf8c-c5mhl   1/1     Running   0          99m

NAME                                            READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/multicluster-global-hub-agent   1/1     1            1           99m

NAME                                                      DESIRED   CURRENT   READY   AGE
replicaset.apps/multicluster-global-hub-agent-9ccb8bf8c   1         1         1       99m
```
7. The Grafana dashboards are available in the [URL](https://multicluster-global-hub-grafana-multicluster-global-hub.apps.mcgh.local.lab):
```shell
$ export KUBECONFIG=/root/labs/mcgh/deploy/auth/kubeconfig

$ oc get route multicluster-global-hub-grafana -n multicluster-global-hub
NAME                              HOST/PORT                                                                     PATH   SERVICES                          PORT          TERMINATION          WILDCARD
multicluster-global-hub-grafana   multicluster-global-hub-grafana-multicluster-global-hub.apps.mcgh.local.lab          multicluster-global-hub-grafana   oauth-proxy   reencrypt/Redirect   None
```

## ACS
To get the password for the `admin` user and log in to the [ACS Central Web console](https://central-rhacs-operator.apps.acm1.local.lab), you can use:
```shell
oc get secret -n rhacs-operator central-htpasswd -o json | jq -r '.data.password | @base64d'
```

## Links
* [Multicluster Global Hub repository](https://github.com/stolostron/multicluster-global-hub/tree/main)
* [Advanced Cluster Security repository](https://github.com/stackrox/stackrox/tree/master)
* [ACS Support Matrix](https://access.redhat.com/articles/7045053)
* [ACS default requirements](https://docs.openshift.com/acs/4.5/installing/acs-default-requirements.html)
