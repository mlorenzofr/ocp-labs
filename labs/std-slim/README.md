# std-slim lab
This lab installs a compact Openshift cluster with an additional node as BMH.

## Requirements
None.

## Steps
1. Deploy:
```shell
ap labs/std-slim/deploy.yaml
```

## Validation
1. Check if the Openshift cluster is running:
```shell
$ export KUBECONFIG=/root/labs/stdslim/deploy/auth/kubeconfig

$ oc get nodes

$ oc get clusterversion
```

## Links
