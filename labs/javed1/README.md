# std-slim lab
This lab installs a compact Openshift cluster with an additional node (BMH) as worker add in day 2.

## Requirements
None.

## Steps
1. Deploy:
```shell
ap labs/javed1/deploy.yaml
```

## Validation
1. Check if the Openshift cluster is running:
```shell
$ export KUBECONFIG=/root/labs/stdslim/deploy/auth/kubeconfig

$ oc get nodes
NAME             STATUS     ROLES                         AGE    VERSION
stdslim-bmh-1    Ready      worker                        3h4m   v1.31.6
stdslim-node-1   Ready      control-plane,master,worker   24h    v1.31.6
stdslim-node-2   Ready      control-plane,master,worker   25h    v1.31.6
stdslim-node-3   Ready      control-plane,master,worker   25h    v1.31.6

$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.18.4    True        False         10m     Cluster version is 4.18.4
```

## Links
