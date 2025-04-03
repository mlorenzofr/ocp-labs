# acm lab
This lab installs a _compact_ Openshift cluster with ACM with an extra node for testing.  

## Requirements
None.

## Steps
1. Execute the playbook `deploy.yaml`:
```shell
ap labs/acm/deploy.yaml
```

## Validation
1. Check if the Openshift cluster is running:
```shell
$ export KUBECONFIG=/root/labs/acm/deploy/auth/kubeconfig

$ oc get nodes
NAME         STATUS   ROLES                         AGE   VERSION
acm-node-1   Ready    control-plane,master,worker   15m   v1.31.6
acm-node-2   Ready    control-plane,master,worker   28m   v1.31.6
acm-node-3   Ready    control-plane,master,worker   28m   v1.31.6

$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.18.4    True        False         6m15s   Cluster version is 4.18.4
```
2. Check if the `MultiClusterHub` resource is present and running:
```shell
$ oc get multiclusterhub -A
NAMESPACE                 NAME              STATUS    AGE     CURRENTVERSION   DESIREDVERSION
open-cluster-management   multiclusterhub   Running   9m20s   2.13.1           2.13.1
```

## Links
