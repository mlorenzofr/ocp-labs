# appliance SNO lab
In this lab we create an environment using the appliance tool.

## Requirements
None.

## Steps
1. Create a new appliance image with:
```shell
ap labs/appliance/deploy.yaml
```
2. Validate

## Validation
1. Check if the cluster is running:
```shell
$ export KUBECONFIG=/home/ocp-labs/appliance/deploy/auth/kubeconfig

$ oc get nodes
NAME               STATUS   ROLES                  AGE   VERSION
appliance-node-1   Ready    control-plane,master   27m   v1.31.6
appliance-node-2   Ready    control-plane,master   42m   v1.31.6
appliance-node-3   Ready    control-plane,master   42m   v1.31.6
appliance-node-4   Ready    worker                 27m   v1.31.6
appliance-node-5   Ready    worker                 27m   v1.31.6

$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.18.2    True        False         17m     Cluster version is 4.18.2
```

## Links
* [OpenShift Appliance User Guide](https://github.com/openshift/appliance/blob/master/docs/user-guide.md)
* [Appliance Config](https://github.com/openshift/appliance/blob/master/docs/appliance-config.md)
