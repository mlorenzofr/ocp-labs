# std-slim lab

This lab installs a compact OpenShift cluster with an additional node as BMH.

## Requirements

### Resources (per node)

| | nodes | vCPUS | Memory | OS Disk | Data Disk | Total Disk |
| :-: | :-----: | :-----: | :------: | :-------: | :---------: | :----------: |
| Hub cluster (masters) | 3 | 12 | 22 GB | 120 GB | 60 GB | 180 GB |
| Hub cluster (workers) | 1 | 12 | 24 GB | 120 GB | 1 GB | 121 GB |
| **Total** | **4** | **48** | **90 GB** | 480 GB | 181 GB | **661 GB** |

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
