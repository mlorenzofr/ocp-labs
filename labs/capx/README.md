# CAPX lab
In this lab, an Openshift cluster is deployed on a Nutanix platform using the cluster API (**CAPI**).  
Currently, the platform type used in the deployment is `baremetal`.

## Requirements
There are some manual configuration steps required before we begin the installation.
1. We will need a RHCOS generic disk image uploaded to Nutanix. This image will be used to deplo the Openshift nodes. The RHCOS images are available on their [official mirror](https://mirror.openshift.com/pub/openshift-v4/x86_64/dependencies/rhcos/).
2. The **subnet** to grant network connectivity to the nodes must exist.
3. To avoid network issues, this lab is desigend to run on a VM (let's call it `capi-manager`) within the Nutanix platform where we will deploy our Openshift cluster. This is not mandatory, it should work on any system if it has connectivity, but this simplifies our lab. In our lab we have used **Fedora Linux 41 (server Edition)** as OS for `capi-manager`.
4. We should have a DNS server to resolve the DNS names used by the _assisted-installer_ and cluster services.

From the Nutanix environment, you will need to gather the following information:
* **Nutanix Cluster Name**: The name of the Nutanix cluster where OpenShift will be deployed. (`nutanix_cluster`)
* **Prism Central Endpoint**: The management IP or hostname of the Nutanix Prism Central. (`nutanix_prism_central`)
* **Credentials**: Admin username and password for accessing Prism Central. (`nutanix_user` & `nutanix_password`)
* **Subnet**: The subnet name to be attached to the nodes. (`nutanix_network`)
* **OS Images**: Pre-uploaded RHCOS images in the Nutanix Image Service for creating VMs. (`nutanix_template_name`)

## Steps
1. Run the playbook `deploy.yaml`:
```shell
$ ap labs/capx/deploy.yaml
```
2. Change the subnet network settings on Nutanix and add the `capi-manager` IP address to the DNS server list.
3. Start the workload cluster installation (CAPI):
```shell
$ ap labs/capx/deploy.yaml --tags capi-cluster

# If you want to install Nutanix CSI operator on day-0 using ClusterResourceSet:
$ ap labs/capx/deploy.yaml --tags capi-cluster,csi
```
In a few minutes we should be able to see the VMs created on Nutanix.

4. Once the workload cluster has finished installating, we can install the Nutanix CSI operator with:
```shell
$ ap labs/capx/deploy.yaml --tags csi
```
5. To create the day-2 resources for the Nutanix CSI operator (for validation):
```shell
$ ap labs/capx/deploy.yaml --tags csi-day-2
```

### Scaling up the cluster
To scale up the worker nodes in the workload cluster, you can do so by increasing the number of replicas in the `MachineDeployment` resource.

However, due an issue with the `ControlPlaneIsStable` preflight check, it must be disabled in the `MachineSet` first.
```shell
$ ms=$(kubectl get machineset -l "cluster.x-k8s.io/deployment-name=capi-ntx-1-wmd" -o jsonpath='{.items[*].metadata.name}')
$ kubectl annotate machineset/"${ms}" "machineset.cluster.x-k8s.io/skip-preflight-checks=ControlPlaneIsStable"
```
Once the annotation is ready and the check is disabled, we can scale up the cluster by changing the replicas:
```shell
$ kubectl scale machinedeployment capi-ntx-1-wmd --replicas=1
```

## Validation

### environment
1. The provisioning flow will need DNS resolution for both the assisted-service and assisted-image.  
Check if the names point to the IP address of the `capi-manager` machine.
```shell
$ host assisted-service.assisted-installer.com
assisted-service.assisted-installer.com has address 10.0.0.170

$ host assisted-image.assisted-installer.com
assisted-image.assisted-installer.com has address 10.0.0.170
```
2. The assisted-service must be published on the IP address of the `capi-manager` machine.  
It doesn't matter if it replies with 404, but it must reply. It must work for KIND pods and VMs on Nutanix.
```shell
$ podman exec -it capi-nutanix-provider-control-plane /bin/bash
\- (container):/# curl http://assisted-service.assisted-installer.com/
{"code":404,"message":"path / was not found"}
```

### CAPI
1. Verify if CAPI components are running on the manager cluster:
```shell
$ kubectl get deployment -A
NAMESPACE                        NAME                                        READY   UP-TO-DATE   AVAILABLE   AGE
assisted-installer               agentinstalladmission                       2/2     2            2           3h52m
assisted-installer               assisted-service                            1/1     1            1           3h52m
assisted-installer               infrastructure-operator                     1/1     1            1           3h52m
capi-agent-bootstrap-system      capi-agent-bootstrapcontroller-manager      1/1     1            1           3h50m
capi-agent-controlplane-system   capi-agent-controlplanecontroller-manager   1/1     1            1           3h50m
capi-system                      capi-controller-manager                     1/1     1            1           3h50m
capx-system                      capx-controller-manager                     1/1     1            1           3h50m
cert-manager                     cert-manager                                1/1     1            1           3h54m
cert-manager                     cert-manager-cainjector                     1/1     1            1           3h54m
cert-manager                     cert-manager-webhook                        1/1     1            1           3h54m
kube-system                      coredns                                     2/2     2            2           3h54m
local-path-storage               local-path-provisioner                      1/1     1            1           3h54m
metallb-system                   controller                                  1/1     1            1           3h53m
nginx-ingress                    ingress-nginx-controller                    1/1     1            1           3h52m
```
2. Check if `infraenv` objects were created:
```shell
$ kubectl get infraenv -A

NAMESPACE   NAME                   ISO CREATED AT
default     capi-ntx-1-cd9z6   2025-01-28T17:04:02Z
default     capi-ntx-1-d7q7h   2025-01-28T17:04:02Z
default     capi-ntx-1-v9ch2   2025-01-28T17:04:02Z
```
3. Review the `agent` resources and whether they are _approved_
```shell
$ kubectl get agent -A

NAMESPACE   NAME                                   CLUSTER          APPROVED   ROLE     STAGE
default     3e493fef-da78-4a65-a1fe-9173b0f689ab   capi-ntx-1   true       master
default     c91d62b9-114f-4108-8551-c393be9b1cb9   capi-ntx-1   true       master
default     caee384e-9b68-454a-ae9b-6fceaf396538   capi-ntx-1   true       master
```
4. If we want to follow the installation of the agents we can do so by checking its status:
```shell
$ watch -n5 "kubectl get agent -A -o json | jq -jr '.items[].status.debugInfo | .state,\" \",.stateInfo,\"\n\"'"
```

### Workload Cluster
1. We can extract the workload cluster kubeconfig from the manager cluster:
```shell
kubectl get secret/capi-ntx-1-admin-kubeconfig -o json | jq -r '.data.kubeconfig | @base64d' > /tmp/kubeconfig-capi-ntx-1
```
2. Check the status of Openshift:
```shell
$ export KUBECONFIG=/tmp/kubeconfig-capi-ntx-1

$ kubectl get nodes
NAME                   STATUS   ROLES                         AGE   VERSION
capi-ntx-1-4rj86   Ready    control-plane,master,worker   19m   v1.30.4
capi-ntx-1-pmmdz   Ready    control-plane,master,worker   33m   v1.30.4
capi-ntx-1-xvvrr   Ready    control-plane,master,worker   33m   v1.30.4

$ kubectl get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.17.0    True        False         8m11s   Cluster version is 4.17.0

$ kubectl get co
NAME                                       VERSION   AVAILABLE   PROGRESSING   DEGRADED   SINCE   MESSAGE
authentication                             4.17.0    True        False         False      7m12s
baremetal                                  4.17.0    True        False         False      30m
config-operator                            4.17.0    True        False         False      30m
console                                    4.17.0    True        False         False      12m
csi-snapshot-controller                    4.17.0    True        False         False      30m
dns                                        4.17.0    True        False         False      29m
etcd                                       4.17.0    True        False         False      28m
ingress                                    4.17.0    True        False         False      22m
insights                                   4.17.0    True        False         False      23m
kube-apiserver                             4.17.0    True        False         False      26m
kube-controller-manager                    4.17.0    True        False         False      27m
kube-scheduler                             4.17.0    True        False         False      27m
kube-storage-version-migrator              4.17.0    True        False         False      30m
machine-approver                           4.17.0    True        False         False      30m
machine-config                             4.17.0    True        False         False      29m
marketplace                                4.17.0    True        False         False      30m
monitoring                                 4.17.0    True        False         False      13m
network                                    4.17.0    True        False         False      30m
openshift-apiserver                        4.17.0    True        False         False      23m
openshift-controller-manager               4.17.0    True        False         False      26m
operator-lifecycle-manager                 4.17.0    True        False         False      30m
operator-lifecycle-manager-catalog         4.17.0    True        False         False      30m
operator-lifecycle-manager-packageserver   4.17.0    True        False         False      24m
service-ca                                 4.17.0    True        False         False      30m
```

### Nutanix CSI operator
1. Check if the Nutanix Operator is installed:
```shell
$ kubectl get subscription nutanixcsioperator -n openshift-cluster-csi-drivers -o jsonpath='{.status.state}{"\n"}'

AtLatestKnown
```
2. We should have a `NutanixCsiStorage` resource:
```shell
$ kubectl get nutanixcsistorage -A

NAMESPACE                       NAME                AGE
openshift-cluster-csi-drivers   nutanixcsistorage   54m
```
3. Verify if we have a `StorageClass`:
```shell
$ kubectl get sc
NAME                       PROVISIONER       RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
nutanix-volume (default)   csi.nutanix.com   Delete          Immediate           true                   56m
```
4. If everything is alrigth, then we should have a PVC in **bound** status:
```shell
$ kubectl get pvc -A

NAMESPACE                       NAME       STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS     VOLUMEATTRIBUTESCLASS   AGE
openshift-cluster-csi-drivers   pvc-test   Bound    pvc-bb2b7939-d0e0-4c12-8dc8-bc365ca57e1f   1Gi        RWO            nutanix-volume   <unset>                 2m33s
```

### Scale up
1. In the management cluster, check if we can see a _worker_ node:
```shell
$ kubectl get agent -A

NAMESPACE   NAME                                   CLUSTER          APPROVED   ROLE     STAGE
default     18824350-1f45-4351-ad04-489d7816acfa   capi-ntx-1   true       master   Done
default     65f0f257-fff1-41fe-9e26-65e75bb3b6a9   capi-ntx-1   true       master   Done
default     85c7a306-072b-413e-bd29-987dba532405   capi-ntx-1   true       master   Done
default     db56104e-2aca-4d3a-a23f-f4afbd5cfde4   capi-ntx-1   true       worker   Done
```
2. In the workload cluster, list the nodes and verify the _worker_ node:
```shell
$ kubectl get nodes

NAME                             STATUS   ROLES                         AGE    VERSION
capi-ntx-1-b982n             Ready    control-plane,master,worker   49m    v1.30.4
capi-ntx-1-kx7sq             Ready    control-plane,master,worker   50m    v1.30.4
capi-ntx-1-r26xq             Ready    control-plane,master,worker   38m    v1.30.4
capi-ntx-1-wmd-mzjrp-kk52t   Ready    worker                        3m2s   v1.30.4
```

## Links
* [rhcos images mirror](https://mirror.openshift.com/pub/openshift-v4/x86_64/dependencies/rhcos/)
* [Installing a cluster on Nutanix ](https://docs.openshift.com/container-platform/4.17/installing/installing_nutanix/installing-nutanix-installer-provisioned.html)
* [cluster-api-agent project](https://github.com/openshift-assisted/cluster-api-agent)
* [Assisted-installer - Installing on Nutanix](https://docs.redhat.com/en/documentation/assisted_installer_for_openshift_container_platform/2025/html/installing_openshift_container_platform_with_the_assisted_installer/assembly_installing-on-nutanix#assembly_installing-on-nutanix)
* [Modify Nutanix configuration of OCP cluster that was installed using the Assisted Installer](https://access.redhat.com/solutions/6983944)
* [Nutanix Cluster API Provider (CAPX)](https://opendocs.nutanix.com/capx/v1.5.x/getting_started/)
* [Nutanix CSI Operator](https://opendocs.nutanix.com/openshift/operators/csi/)
* [Nutanix CSI Volume Driver 2.6](https://portal.nutanix.com/page/documents/details?targetId=CSI-Volume-Driver-v2_6:CSI-Volume-Driver-v2_6)
* [Nutanix CSI Volume Driver 3.2](https://portal.nutanix.com/page/documents/details?targetId=CSI-Volume-Driver-v3_2:CSI-Volume-Driver-v3_2)
* [Install the Nutanix CSI Driver with Helm](https://opendocs.nutanix.com/capx/latest/addons/install_csi_driver/)
* [Nutanix CSI Storage Driver Helm chart](https://github.com/nutanix/helm/tree/master/charts/nutanix-csi-storage)

