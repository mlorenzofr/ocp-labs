# ztp lab
This lab installs a _compact_ Openshift cluster with ACM, Gitops and TALM.  
In the [ztp-example](https://github.com/mlorenzofr/ztp-example) repository there is a deployment of an SNO cluster that can be tested on day-2.

## Requirements
None.

## Steps
1. Execute the playbook `deploy.yaml`:
```shell
ap labs/ztp/deploy.yaml
```
2. Configure the ArgoCD applications:
```shell
ap labs/ztp/deploy.yaml --tags argocd
```
3. If you are using the ztp-example repository, extract the cluster configuration with:
```shell
ap labs/ztp/deploy.yaml --tags hive-config
```

## Validation
1. Check if the Openshift cluster is running:
```shell
$ export KUBECONFIG=~/ztp/deploy/auth/kubeconfig

$ oc get nodes
NAME           STATUS   ROLES                         AGE    VERSION
ztp-master-1   Ready    control-plane,master,worker   114m   v1.31.8
ztp-master-2   Ready    control-plane,master,worker   126m   v1.31.8
ztp-master-3   Ready    control-plane,master,worker   126m   v1.31.8

$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.18.16   True        False         107m    Cluster version is 4.18.16
```
2. Check if the ACM, GitOps and TALM operators are installed:
```shell
$ oc get csv -n open-cluster-management
NAME                                       DISPLAY                                      VERSION   REPLACES                                           PHASE
advanced-cluster-management.v2.13.3        Advanced Cluster Management for Kubernetes   2.13.3    advanced-cluster-management.v2.13.2                Succeeded
openshift-gitops-operator.v1.16.1          Red Hat OpenShift GitOps                     1.16.1    openshift-gitops-operator.v1.16.0-0.1746014725.p   Succeeded
topology-aware-lifecycle-manager.v4.18.0   Topology Aware Lifecycle Manager             4.18.0                                                       Succeeded
```
3. Review if `assisted-service` is running:
```shell
$ oc get pods -n multicluster-engine -l app=assisted-service
NAME                                READY   STATUS    RESTARTS   AGE
assisted-service-77cf7d777d-7bvsc   2/2     Running   0          53m

$ oc get pods -n multicluster-engine -l app=assisted-image-service
NAME                       READY   STATUS    RESTARTS   AGE
assisted-image-service-0   1/1     Running   0          54m
```

### ZTP spoke cluster validation
To validate the spoke cluster defined on the [repository ztp-example](https://github.com/mlorenzofr/ztp-example):
1. Check the `BaremetalHost` status:
```shell
$ oc get bmh -A
NAMESPACE               NAME           STATE         CONSUMER             ONLINE   ERROR   AGE
openshift-machine-api   ztp-master-1   unmanaged     ztp-mwlqs-master-0   true             94m
openshift-machine-api   ztp-master-2   unmanaged     ztp-mwlqs-master-1   true             94m
openshift-machine-api   ztp-master-3   unmanaged     ztp-mwlqs-master-2   true             94m
ztp-sno                 ztp-bmh-1      provisioned                        true             23m
```
2. Check the `infraenv`:
```shell
$ oc get infraenv -A
NAMESPACE   NAME      ISO CREATED AT
ztp-sno     ztp-sno   2025-06-09T15:57:18Z
```
3. Check the `agent`:
```shell
$ oc get agent -A
NAMESPACE   NAME                                   CLUSTER   APPROVED   ROLE     STAGE
ztp-sno     759451b4-544a-4163-9a9c-08845888b346   ztp-sno   true       master   Done
```
4. Check the `clusterdeployment`:
```shell
$ oc get clusterdeployment -A
NAMESPACE   NAME      INFRAID                                PLATFORM          REGION   VERSION   CLUSTERTYPE   PROVISIONSTATUS   POWERSTATE   AGE
ztp-sno     ztp-sno   039f12a8-d496-4089-a886-166e7a83e54b   agent-baremetal            4.18.16                 Provisioned       Running      46m
```

5. Extract the spoke cluster configuration:
```shell
ap labs/ztp/deploy.yaml --tags hive-config
```
6. Connect you to the _spoke_ cluster using the CLI:
```shell
$ export KUBECONFIG=~/labs/ztp/ztp-sno/auth/kubeconfig

$ oc get nodes
NAME        STATUS   ROLES                         AGE   VERSION
ztp-bmh-1   Ready    control-plane,master,worker   15h   v1.31.8

$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.18.16   True        False         14h     Cluster version is 4.18.16

$ oc get co
NAME                                       VERSION   AVAILABLE   PROGRESSING   DEGRADED   SINCE   MESSAGE
authentication                             4.18.16   True        False         False      14h
baremetal                                  4.18.16   True        False         False      15h
cloud-controller-manager                   4.18.16   True        False         False      14h
cloud-credential                           4.18.16   True        False         False      15h
cluster-autoscaler                         4.18.16   True        False         False      15h
config-operator                            4.18.16   True        False         False      15h
console                                    4.18.16   True        False         False      14h
control-plane-machine-set                  4.18.16   True        False         False      15h
csi-snapshot-controller                    4.18.16   True        False         False      15h
dns                                        4.18.16   True        False         False      15h
etcd                                       4.18.16   True        False         False      14h
image-registry                             4.18.16   True        False         False      14h
ingress                                    4.18.16   True        False         False      15h
insights                                   4.18.16   True        False         False      15h
kube-apiserver                             4.18.16   True        False         False      14h
kube-controller-manager                    4.18.16   True        False         False      14h
kube-scheduler                             4.18.16   True        False         False      14h
kube-storage-version-migrator              4.18.16   True        False         False      15h
machine-api                                4.18.16   True        False         False      15h
machine-approver                           4.18.16   True        False         False      14h
machine-config                             4.18.16   True        False         False      14h
marketplace                                4.18.16   True        False         False      15h
monitoring                                 4.18.16   True        False         False      14h
network                                    4.18.16   True        False         False      15h
node-tuning                                4.18.16   True        False         False      15h
olm                                        4.18.16   True        False         False      14h
openshift-apiserver                        4.18.16   True        False         False      14h
openshift-controller-manager               4.18.16   True        False         False      14h
openshift-samples                          4.18.16   True        False         False      14h
operator-lifecycle-manager                 4.18.16   True        False         False      15h
operator-lifecycle-manager-catalog         4.18.16   True        False         False      15h
operator-lifecycle-manager-packageserver   4.18.16   True        False         False      14h
service-ca                                 4.18.16   True        False         False      15h
storage                                    4.18.16   True        False         False      15h
```

## Links
* [OpenShift GitOps Usage Guide](https://github.com/redhat-developer/gitops-operator/blob/master/docs/OpenShift%20GitOps%20Usage%20Guide.md)
* [Updating managed clusters with the Topology Aware Lifecycle Manager](https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/edge_computing/cnf-talm-for-cluster-updates)
