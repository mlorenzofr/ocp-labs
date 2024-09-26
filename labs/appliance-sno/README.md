# appliance SNO lab
In this lab we create an environment using the appliance tool.

## Requirements
None.

## Steps
1. Create a new appliance image with:
```shell
ap labs/appliance-sno/deploy.yaml
```
2. Validate

## Validation
1. Check if the cluster is running:
```shell
$ export KUBECONFIG=/home/ocp-labs/applianceiso/deploy/auth/kubeconfig

$ oc get nodes
NAME          STATUS   ROLES                         AGE   VERSION
applianceiso-node-1   Ready    control-plane,master,worker   13m   v1.29.6+aba1e8d

$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.16.8    True        False         2m27s   Cluster version is 4.16.3
```

## Links
* [OpenShift Appliance User Guide](https://github.com/openshift/appliance/blob/master/docs/user-guide.md)
* [Appliance Config](https://github.com/openshift/appliance/blob/master/docs/appliance-config.md)
