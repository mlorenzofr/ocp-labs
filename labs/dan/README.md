# dan lab
Dan's lab

## Requirements
None.

## Steps
1. Deploy:
```shell
ap labs/dan/deploy.yaml --tags ocp
```
2. Create testing manifests:
```shell
ap labs/dan/deploy.yaml --tags baremetal
- or -
ap labs/dan/deploy.yaml --tags hcp
```

## Validation
1. Check if the Openshift cluster is running:
```shell
$ export KUBECONFIG=/root/labs/stdslim/deploy/auth/kubeconfig

$ oc get nodes

$ oc get clusterversion
```

## Links
