# acm lab

This lab prepares an ACM environment for educational purposes.

The environment provides:
- An Openshift _compact_ cluster with 3 nodes for ACM (_hub cluster_)
- 3 virtual machines for the 1st _spoke cluster_. (Hive cluster)
- An SNO cluster as 2nd _spoke cluster_, to be imported by the _hub cluster_.

This deployment does not apply the manifests, it only creates them.

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
NAME           STATUS   ROLES                         AGE   VERSION
acm-master-1   Ready    control-plane,master,worker   24h   v1.32.7
acm-master-2   Ready    control-plane,master,worker   24h   v1.32.7
acm-master-3   Ready    control-plane,master,worker   24h   v1.32.7

$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.19.10   True        False         24h     Cluster version is 4.19.10
```

## Usage guide

The guide with the steps to follow to install ACM in this environment can be found [in this document](./GUIDE.md).

## Links

- [MCH & MCE components](https://github.com/stolostron/multiclusterhub-operator/blob/9fc8a6d08afab5c36417809d36d21b88b24730f2/api/v1/multiclusterhub_methods.go#L19)