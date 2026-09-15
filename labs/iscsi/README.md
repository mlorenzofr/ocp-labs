# iscsi lab

This lab deploys a **Single Node OpenShift (SNO)** hub cluster with **Multicluster Engine (MCE)** and
**assisted-service**. The assisted service is then used to provision a **SNO spoke cluster** on a VM that uses an **iSCSI LUN** as its unique storage target for the OpenShift installation.

The hub cluster runs assisted-service. The spoke cluster
installs on an iSCSI disk exposed by the lab iSCSI target (`192.168.125.150`).

See [docs/iscsi-setup.md](docs/iscsi-setup.md) for iSCSI target and initiator configuration.

## Requirements

### Resources (per node)

| | nodes | vCPUS | Memory | OS Disk | Data Disk | Total Disk |
| :-: | :-----: | :-----: | :------: | :-------: | :---------: | :----------: |
| Hub cluster (SNO) | 1 | 12 | 32 GB | 120 GB | 60 GB | 180 GB |
| Spoke cluster (SNO) | 1 | 12 | 24 GB | 120 GB (iscsi) | 0 GB | 120 GB |
| **Total** | **2** | **24** | **56 GB** | 240 GB | 60 GB | **300 GB** |

The spoke cluster also requires an iSCSI LUN on the target server (size: 120 GB or
larger). This storage is provided by the iSCSI target at `192.168.125.150`, not by the spoke VM disks.

## Steps

1. Deploy the SNO hub cluster:

```shell
ap labs/iscsi/deploy.yaml --tags hub
```

2. Install MCE and assisted-service on the hub:

```shell
ap labs/iscsi/deploy.yaml --tags mce
```

3. Configure the iSCSI target, iPXE, and iBFT initiator on the spoke VM as described in
   [docs/iscsi-setup.md](docs/iscsi-setup.md). The spoke VM must boot through iPXE and establish
   the iSCSI session before the discovery ISO is attached.

## Validation

1. Check if the hub cluster is running:

```shell
$ export KUBECONFIG=/root/labs/iscsi/deploy/auth/kubeconfig

$ oc get nodes
NAME           STATUS   ROLES                         AGE   VERSION
iscsi-node-1   Ready    control-plane,master,worker   30m   v1.33.6

$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.20.8    True        False         10m     Cluster version is 4.20.8
```

2. Check if MCE and assisted-service are running:

```shell
$ oc get multiclusterengine -n multicluster-engine
NAME                  AGE   STATE
multiclusterengine    15m   Running

$ oc get pods -n multicluster-engine -l app=assisted-service
NAME                               READY   STATUS    RESTARTS   AGE
assisted-service-xxxxxxxxxx-xxxxx   2/2     Running   0          10m
```

## Links

* [Lab iSCSI setup guide](docs/iscsi-setup.md)
