# acm lab

This lab installs a _compact_ OpenShift cluster with ACM with an extra node or cluster for testing.

## Requirements

### Resources (per node)

| | nodes | vCPUS | Memory | OS Disk | Data Disk | Total Disk |
| :-: | :-----: | :-----: | :------: | :-------: | :---------: | :----------: |
| Hub cluster | 3 | 12 | 28 GB | 120 GB | 60 GB | 180 GB |
| Spoke cluster | 1 | 12 | 24 GB | 120 GB | 1 GB | 121 GB |
| **Total** | **4** | **48** | **108 GB** | 480 GB | 181 GB | **661 GB** |

## Steps

1. Execute the playbook `deploy.yaml`:

```shell
ap labs/acm/deploy.yaml --tags ocp
```

2. If you want to run tests on the Hub cluster, with an additional BMH node of your own, use:

```shell
ap labs/acm/deploy.yaml --tags bmh-node
```

3. If you want to install a _Spoke_ cluster (SNO):

```shell
ap labs/acm/deploy.yaml --tags sno
```

4. To import the _Spoke_ cluster created in the previous step:

```shell
ap labs/acm/deploy.yaml --tags sno-config
ap labs/acm/deploy.yaml --tags sno-import
```

## Validation

1. Check if the Openshift cluster is running:

```shell
$ export KUBECONFIG=/root/labs/acm/deploy/auth/kubeconfig

$ oc get nodes
NAME           STATUS   ROLES                         AGE   VERSION
acm-master-1   Ready    control-plane,master,worker   11m   v1.33.6
acm-master-2   Ready    control-plane,master,worker   26m   v1.33.6
acm-master-3   Ready    control-plane,master,worker   26m   v1.33.6

$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.20.8    True        False         2m5s    Cluster version is 4.20.8
```

2. Check if the `MultiClusterHub` resource is present and running:

```shell
$ oc get multiclusterhub -A
NAMESPACE                 NAME              STATUS    AGE   CURRENTVERSION   DESIREDVERSION
open-cluster-management   multiclusterhub   Running   19m   2.15.1           2.15.1
```

3. If you have created and imported a spoke cluster, check if it exists:

```shell
$ oc get managedclusters
NAME            HUB ACCEPTED   MANAGED CLUSTER URLS                   JOINED   AVAILABLE   AGE
local-cluster   true           https://api.acm.local.lab:6443         True     True        100m
spoke-acm       true           https://api.spoke-acm.local.lab:6443   True     True        17m
```

## Links
