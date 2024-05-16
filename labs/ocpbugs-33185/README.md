# OCPBUGS-33185 lab
This lab is used to triage the issue [OCPBUGS-33185](https://issues.redhat.com/browse/OCPBUGS-33185).  
We will install 2 Openshift clusters:
* A _hub cluster_, with a stable version (**4.15.4**). It will be a _compact cluster_ with 3 nodes.
* A _spoke cluster_, with a nightly build (**4.16.0-nightly**). It will be a _SNO cluster_.

Finally, we will install a non-GA version of ACM (**2.10.3**) and import the _spoke cluster_ into the _hub cluster_.

## Requirements
We will need credentials to use QE resources because the software builds are not yet public.  
To install Openshift we will need the `openshift-install` tool for each installed version.  
```shell
oc adm release extract --command=openshift-install registry.ci.openshift.org/ocp/release:4.16.0-0.nightly-2024-05-15-001800
```

## Steps
### Hub cluster
1. Install a Openshift _compact_ cluster with:
```shell
ap labs/ocpbugs-33185/deploy.yaml --tags ocp
```

### Spoke cluster
2. Switch the `openshift-install` tool to use the version **4.16.0**.
3. Start _spoke cluster_ installation with:
```shell
ap labs/ocpbugs-33185/deploy.yaml --tags sno
```

### Prepare QE environment
There are some manifests and information omitted from this repository to avoid exposing internal information.  
This setup must be done **for each** Openshift cluster (hub & spoke).  
The `klusterlet` pod launched during the cluster import will need the development OCI registry.  

4. Change the **pull-secret** to use credentials with access on the devel registry.
```shell
oc set data secret/pull-secret -n openshift-config --from-file=.dockerconfigjson=pull-secret.json
```
5. Add the Red Hat's CA as trusted.
```shell
oc apply -f trustedca-configmap.yaml
oc patch proxy/cluster --type=merge --patch='{"spec":{"trustedCA":{"name":"redhat-ca"}}}'
oc patch images.config/cluster --type=merge --patch='{"spec":{"additionalTrustedCA":{"name":"redhat-ca"}}}'
```
6. Replace the `CatalogSource` **redhat-operators** with **OSBS**.
```shell
oc apply -f catalog-engineering.yaml
oc patch operatorhubs/cluster --type merge --patch '{"spec":{"sources":[{"disabled": true,"name": "redhat-operators"}]}}'
```
7. Set the registries mirroring to use development registry.
```shell
oc apply -f image-config.yaml
```

### Import the SNO cluster
8. Install and configure ACM with:
```shell
ap labs/ocpbugs-33185/deploy.yaml --tags acm
```
The task will also import the _spoke cluster_.

## Validation
1. Check if the cluster is running:
```shell
$ export KUBECONFIG=/root/labs/dgon/deploy/auth/kubeconfig

$ oc get nodes
NAME            STATUS   ROLES                         AGE   VERSION
dgon-master-1   Ready    control-plane,master,worker   15h   v1.28.7+f1b5f6c
dgon-master-2   Ready    control-plane,master,worker   15h   v1.28.7+f1b5f6c
dgon-master-3   Ready    control-plane,master,worker   15h   v1.28.7+f1b5f6c

$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.15.4    True        False         15h     Cluster version is 4.15.4
```
2. On the _hub cluster_ (**dgon**), check the version of the installed operators:
```shell
$ oc get csv -A | grep -v metallb
NAMESPACE                                          NAME                                    DISPLAY                                      VERSION               REPLACES                              PHASE
multicluster-engine                                multicluster-engine.v2.5.3              multicluster engine for Kubernetes           2.5.3                 multicluster-engine.v2.5.2            Succeeded
openshift-acm                                      advanced-cluster-management.v2.10.3     Advanced Cluster Management for Kubernetes   2.10.3                advanced-cluster-management.v2.10.2   Succeeded
openshift-operator-lifecycle-manager               packageserver                           Package Server                               0.0.1-snapshot                                              Succeeded
openshift-storage                                  lvms-operator.v4.15.3                   LVM Storage                                  4.15.3                lvms-operator.v4.15.2                 Succeeded
```
3. Verify the SNO cluster installation:
```shell
$ export KUBECONFIG=/root/labs/dgonspk/deploy/auth/kubeconfig

$ oc get clusterversion
NAME      VERSION                              AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.16.0-0.nightly-2024-05-15-001800   True        False         3m53s   Cluster version is 4.16.0-0.nightly-2024-05-15-001800

$ oc get co
NAME                                       VERSION                              AVAILABLE   PROGRESSING   DEGRADED   SINCE   MESSAGE
authentication                             4.16.0-0.nightly-2024-05-15-001800   True        False         False      5m53s
baremetal                                  4.16.0-0.nightly-2024-05-15-001800   True        False         False      21m
cloud-controller-manager                   4.16.0-0.nightly-2024-05-15-001800   True        False         False      17m
cloud-credential                           4.16.0-0.nightly-2024-05-15-001800   True        False         False      27m
cluster-autoscaler                         4.16.0-0.nightly-2024-05-15-001800   True        False         False      21m
config-operator                            4.16.0-0.nightly-2024-05-15-001800   True        False         False      22m
console                                    4.16.0-0.nightly-2024-05-15-001800   True        False         False      5m22s
control-plane-machine-set                  4.16.0-0.nightly-2024-05-15-001800   True        False         False      21m
csi-snapshot-controller                    4.16.0-0.nightly-2024-05-15-001800   True        False         False      22m
dns                                        4.16.0-0.nightly-2024-05-15-001800   True        False         False      9m10s
etcd                                       4.16.0-0.nightly-2024-05-15-001800   True        False         False      14m
image-registry                             4.16.0-0.nightly-2024-05-15-001800   True        False         False      5m14s
ingress                                    4.16.0-0.nightly-2024-05-15-001800   True        False         False      21m
insights                                   4.16.0-0.nightly-2024-05-15-001800   True        False         False      12m
kube-apiserver                             4.16.0-0.nightly-2024-05-15-001800   True        False         False      9m13s
kube-controller-manager                    4.16.0-0.nightly-2024-05-15-001800   True        False         False      14m
kube-scheduler                             4.16.0-0.nightly-2024-05-15-001800   True        False         False      12m
kube-storage-version-migrator              4.16.0-0.nightly-2024-05-15-001800   True        False         False      22m
machine-api                                4.16.0-0.nightly-2024-05-15-001800   True        False         False      17m
machine-approver                           4.16.0-0.nightly-2024-05-15-001800   True        False         False      21m
machine-config                             4.16.0-0.nightly-2024-05-15-001800   True        False         False      21m
marketplace                                4.16.0-0.nightly-2024-05-15-001800   True        False         False      21m
monitoring                                 4.16.0-0.nightly-2024-05-15-001800   True        False         False      4m6s
network                                    4.16.0-0.nightly-2024-05-15-001800   True        False         False      22m
node-tuning                                4.16.0-0.nightly-2024-05-15-001800   True        False         False      22m
openshift-apiserver                        4.16.0-0.nightly-2024-05-15-001800   True        False         False      9m7s
openshift-controller-manager               4.16.0-0.nightly-2024-05-15-001800   True        False         False      21m
openshift-samples                          4.16.0-0.nightly-2024-05-15-001800   True        False         False      9m
operator-lifecycle-manager                 4.16.0-0.nightly-2024-05-15-001800   True        False         False      21m
operator-lifecycle-manager-catalog         4.16.0-0.nightly-2024-05-15-001800   True        False         False      21m
operator-lifecycle-manager-packageserver   4.16.0-0.nightly-2024-05-15-001800   True        False         False      9m11s
service-ca                                 4.16.0-0.nightly-2024-05-15-001800   True        False         False      22m
storage                                    4.16.0-0.nightly-2024-05-15-001800   True        False         False      21m
```
4. On the _spoke cluster_ (**dgonspk**), validate if the debug pod in the `assisted-installer` namespace is not present.
```shell
$ oc get pods -n assisted-installer
NAME                                  READY   STATUS    RESTARTS   AGE
assisted-installer-controller-pjlgc   1/1     Running   0          36m
```
5. On the _hub cluster_ (**dgon**), check if the _spoke cluster_ has been imported:
```shell
$ oc get managedcluster
NAME            HUB ACCEPTED   MANAGED CLUSTER URLS                 JOINED   AVAILABLE   AGE
dgonspk         true           https://api.dgonspk.local.lab:6443   True     True        20m
local-cluster   true           https://api.dgon.local.lab:6443      True     True        33m 
```

## Links
* [OCPBUGS-33185](https://issues.redhat.com/browse/OCPBUGS-33185)
* [Interacting With CI Image Registries](https://docs.ci.openshift.org/docs/how-tos/use-registries-in-build-farm/)
* [Openshift Releases](https://openshift-release.apps.ci.l2s4.p1.openshiftapps.com/)
