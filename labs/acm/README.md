# ACM lab
In this lab the goal is install an Openshift Cluster with ACM.  
The cluster will be _compact_ (3 nodes, with master/worker roles).

## Requirements
None.

## Steps
1. Execute the playbook `acm.yaml`:
```shell
ap labs/acm/acm.yaml
```

## Validation
1. Check if the Openshift cluster is running:
```shell
$ export KUBECONFIG=/root/labs/acm/deploy/auth/kubeconfig

$ oc get nodes

$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.15.4    True        False         15h     Cluster version is 4.15.4
```

## Links
