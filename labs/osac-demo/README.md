# osac-demo lab

This lab was created to make an OSAC demo. The environment has 2 OpenShift clusters: a hub and a spoke

This lab has been deployed on machine **b17**.

## Services

* Hub cluster
  * Advanced Cluster Management (ACM)
  * Assisted-Service
  * Open Sovereign AI Cloud (OSAC)
  * Ansible Automation Platform (AAP)

* Spoke cluster
  * KubeVirt
  * Openshift Data Foundation (ODF)

## Requirements

### Resources (per node)

| | nodes | vCPUS | Memory | OS Disk | Data Disk | Total Disk |
| :-: | :-----: | :-----: | :------: | :-------: | :---------: | :----------: |
| Hub cluster | 3 | 12 | 28 GB | 120 GB | 100 GB | 220 GB |
| Spoke cluster (masters) | 3 | 24 | 64 GB | 120 GB | 512 GB | 632 GB |
| Spoke cluster (workers) | 1 | 16 | 24 GB | 120 GB | 1 GB | 121 GB |
| **Total** | **7** | **124** | **300 GB** | 840 GB | 1837 GB | **2677 GB** |

### Software

The machine hosting the lab must have **openvswitch** installed for the `devpr` and `testpr` libvirt networks.

```shell
subscription-manager repos --enable=fast-datapath-for-rhel-9-x86_64-rpms
dnf install -y openvswitch-selinux-extra-policy openvswitch3.6 openvswitch3.6-test
```

The _openvswitch_ and _libvirt_ networks must be configured:

```shell
ovs-vsctl add-br testpr
ovs-vsctl add-br devpr
virsh net-define testpr.xml
virsh net-start testpr && virsh net-autostart testpr
virsh net-define devpr.xml
virsh net-start devpr && virsh net-autostart devpr
kcli create network -c "192.168.111.0/24" --domain local.lab -P dns=false -P dhcp=false -P plan=osac-demo devbm
kcli create network -c "192.168.122.0/24" --domain local.lab -P dns=false -P dhcp=false -P plan=osac-demo default
```

## Steps

1. Deploy the hub cluster

```shell
ap labs/osac-demo/deploy.yaml -l b17 --tags ocp
```

2. Deploy the spoke cluster

```shell
ap labs/osac-demo/deploy.yaml -l b17 --tags spoke-deployment
```

3. Export spoke cluster configuration

```shell
ap labs/osac-demo/deploy.yaml -l b17 --tags spoke-config
```

### Configure the spoke cluster (`vmaas-cluster`)

>[!WARNING]
> The **worker node** in the `vmaas-cluster` must have an additional network interface connected to the "**devpr**" network.
> This step is not automated and must be added manually.

1. Export the variable with the cluster's _kubeconfig_ file

```shell
export KUBECONFIG=/root/labs/osac/vmaas-cluster/auth/kubeconfig
```

2. Label master nodes to use their local storage:

```shell
oc label node/vmaas-master-1 cluster.ocs.openshift.io/openshift-storage=""
oc label node/vmaas-master-2 cluster.ocs.openshift.io/openshift-storage=""
oc label node/vmaas-master-3 cluster.ocs.openshift.io/openshift-storage=""
```

3. Create the topology labels on master nodes:

```shell
oc label node vmaas-master-1 topology.kubernetes.io/zone=rack-1
oc label node vmaas-master-2 topology.kubernetes.io/zone=rack-2
oc label node vmaas-master-3 topology.kubernetes.io/zone=rack-3
```

4. Install the LVMS operator

```shell
oc apply -f /root/labs/osac/vmaas-cluster/config/lvms-subscription.yaml
```

5. Create the `LVMCluster`

```shell
oc apply -f /root/labs/osac/vmaas-cluster/config/lvmcluster-lv-data.yaml
```

6. Install the ODF operator

```shell
oc apply -f /root/labs/osac/vmaas-cluster/config/odf-subscription.yaml
```

7. Create the `StorageCluster`

```shell
oc apply -f /root/labs/osac/vmaas-cluster/config/odf-storagecluster-ocs.yaml
```

### OSAC

1. Import the spoke cluster

```shell
ap labs/osac-demo/deploy.yaml -l b17 --tags import-cluster
```

2. Label the `ManagedCluster`

```shell
oc label managedcluster/test-cluster sovcloud.open-cluster-management.io/vmaas=true
```

3. Install AAP & OSAC Operators

```shell
ap labs/osac-demo/deploy.yaml -l b17 --tags osac
```

## Validation

1. Check if the Openshift hub cluster is running:

```shell
export KUBECONFIG=/root/labs/osac-demo/deploy/auth/kubeconfig

$ oc get nodes
NAME          STATUS   ROLES                         AGE     VERSION
osac-node-1   Ready    control-plane,master,worker   6h12m   v1.33.6
osac-node-2   Ready    control-plane,master,worker   6h27m   v1.33.6
osac-node-3   Ready    control-plane,master,worker   6h27m   v1.33.6
```

2. Check if the Openshift spoke cluster (_vmaas-cluster_) is running:

```shell
$ export KUBECONFIG=/root/labs/osac/vmaas-cluster/auth/kubeconfig

$ oc get nodes
NAME             STATUS   ROLES                         AGE   VERSION
vmaas-master-1   Ready    control-plane,master,worker   32h   v1.33.6
vmaas-master-2   Ready    control-plane,master,worker   31h   v1.33.6
vmaas-master-3   Ready    control-plane,master,worker   32h   v1.33.6
vmaas-worker-1   Ready    worker                        31h   v1.33.6
```

3. Review the `ansible-aap` namespace. We should have:
  * `secret/config-as-code-ig`
  * `secret/config-as-code-manifest-ig`
  * `secret/vmaas-cluster-kubeconfig`
  * `route.route.openshift.io/osac-aap-controller`

```shell
oc get all,secrets -n ansible-aap
```

4. Review the `osac-operator-system` namespace. We should have:
  * `secret/osac-config`
  * `secret/vmaas-cluster-kubeconfig`
  * `pod/osac-operator-controller-manager-585cfcfbd9-8g8n7`

```shell
oc get all,secrets -n osac-operator-system
```

5. Check if volume `vmaas-cluster-kubeconfig` is present in the `deployment.apps/osac-operator-controller-manager`:

```shell
oc get deployment.apps/osac-operator-controller-manager -n osac-operator-system -o yaml
```

6. In the [OpenShift Web UI](https://console-openshift-console.apps.osac.local.lab), in the left menu, go to `Governance`. Verify that the ACM policies have been applied.

## Links

* [OCP ClusterUserDefinedNetwork (C-UDN) with VRF-Lite Lab](https://github.com/eranco74/ocp-cudn-vrflite-lab)
* [Advertising pod IPs from a cluster user-defined network over BGP with VPN](https://docs.redhat.com/en/documentation/openshift_container_platform/4.21/html/advanced_networking/route-advertisements#advertising-pod-ips-from-a-user-defined-network-over-bgp-with-vpn_about-route-advertisements)
* [osac-operator versions](https://github.com/osac-project/osac-operator/pkgs/container/osac-operator/versions)