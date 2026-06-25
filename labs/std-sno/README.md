# std-sno lab

This lab creates a Single Node Openshift (**SNO**) environment.

## Requirements

### Resources (per node)

| | nodes | vCPUs | Memory | OS Disk | Data Disk | Total Disk |
| :-: | :-----: | :-----: | :------: | :-------: | :---------: | :----------: |
| **Main cluster** | | | | | | |
| masters | 1 | 12 | 23 GB | 120 GB | 1 GB | 121 GB |
| **Total** | **1** | **12** | **23 GB** | **120 GB** | **1 GB** | **121 GB** |

## Steps

1. Deploy:

```shell
ap labs/std-sno/deploy.yaml
```

## Validation

1. Check if the Openshift cluster is running:

```shell
$ export KUBECONFIG=/root/labs/std-sno/deploy/auth/kubeconfig

$ oc get nodes
NAME             STATUS   ROLES                         AGE   VERSION
std-sno-node-1   Ready    control-plane,master,worker   10m   v1.32.2

$ oc get clusterversion
NAME      VERSION                                      AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.19.0-0.konflux-nightly-2025-03-20-100448   True        False         4m      Cluster version is 4.19.0-0.konflux-nightly-2025-03-20-100448
```

## Links
