# OKD lab
In this lab the goal is install an Openshift Cluster with an OKD _spoke cluster_ (`HostedCluster`) inside.  
We will use **Hypershift** to do it.

## Requirements
This lab has been tested with these software versions:
* Openshift Container Platform **4.15.4**
* Fedora CoreOS **37** (20221225.3.0)
* OKD **4.12.0** (2023-03-18-084815)
Other versions may not work. For example, Fedora Core OS 39 supports OKD version 4.14.0, but 4.15.0 does not.

## Steps
1. Execute the playbook `okd.yaml`:
```shell
ap labs/okd/okd.yaml
```

## Validation
1. Check if the _hub cluster_ is running:
```shell
$ export KUBECONFIG=/root/labs/okd/deploy/auth/kubeconfig

$ oc get nodes
NAME           STATUS   ROLES                  AGE   VERSION
okd-master-1   Ready    control-plane,master   16h   v1.28.7+f1b5f6c
okd-master-2   Ready    control-plane,master   16h   v1.28.7+f1b5f6c
okd-master-3   Ready    control-plane,master   16h   v1.28.7+f1b5f6c
okd-worker-4   Ready    worker                 15h   v1.28.7+f1b5f6c

$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.15.4    True        False         15h     Cluster version is 4.15.4
```
2. Check if OKD _spoke cluster_ is running:
```shell
$ oc get hostedcluster -n spoke
NAME    VERSION   KUBECONFIG               PROGRESS   AVAILABLE   PROGRESSING   MESSAGE
spoke             spoke-admin-kubeconfig   Partial    True        False         The hosted control plane is available

$ oc get managedcluster -n spoke
NAME            HUB ACCEPTED   MANAGED CLUSTER URLS             JOINED   AVAILABLE   AGE
local-cluster   true           https://api.okd.local.lab:6443   True     True        15h
spoke           true           https://192.168.125.40:6443      True     True        89m

$ oc get pods -n spoke-spoke
NAME                                                  READY   STATUS    RESTARTS   AGE
capi-provider-6569878556-x7wcc                        1/1     Running   0          90m
catalog-operator-6f55fc9ff9-wfpvl                     2/2     Running   0          74m
certified-operators-catalog-75c66bfd5b-b9c5m          1/1     Running   0          74m
cluster-api-6b64d4dfb-bbwk9                           1/1     Running   0          90m
cluster-autoscaler-6cb867b776-jf7dk                   1/1     Running   0          89m
cluster-image-registry-operator-7ff67d4958-6s5vz      2/2     Running   0          74m
cluster-network-operator-ccb7c8f-fmx72                1/1     Running   0          74m
cluster-node-tuning-operator-778448c9c8-zhqpc         1/1     Running   0          74m
cluster-policy-controller-7d46b9bf84-9d7x7            1/1     Running   0          74m
cluster-storage-operator-589748fcc7-29l54             1/1     Running   0          74m
cluster-version-operator-74854958cd-dhhnc             1/1     Running   0          74m
community-operators-catalog-5f896d7677-45f9w          1/1     Running   0          74m
control-plane-operator-8455fc9c66-w8b2g               1/1     Running   0          90m
csi-snapshot-controller-76455c5655-jxwpn              1/1     Running   0          73m
csi-snapshot-controller-operator-757cfbbf77-4xnzk     1/1     Running   0          74m
csi-snapshot-webhook-864b845f8c-q9dq4                 1/1     Running   0          73m
dns-operator-b79c6cbb8-tp2fq                          1/1     Running   0          74m
etcd-0                                                2/2     Running   0          89m
hosted-cluster-config-operator-77d588d5df-cn7td       1/1     Running   0          74m
ignition-server-6ddb7fb6d7-sgj6h                      1/1     Running   0          89m
ingress-operator-66dff4498f-z5jd6                     2/2     Running   0          74m
konnectivity-agent-668fbc8498-dmv6c                   1/1     Running   0          89m
konnectivity-server-6556467958-tb8q2                  1/1     Running   0          89m
kube-apiserver-579d86fc97-6tps2                       3/3     Running   0          89m
kube-controller-manager-85bbc95bb6-wrzmv              1/1     Running   0          64m
kube-scheduler-647565bfcd-gz987                       1/1     Running   0          75m
machine-approver-d8cd95b98-8w5kp                      1/1     Running   0          89m
multus-admission-controller-698ddbbf-zwqtw            2/2     Running   0          67m
oauth-openshift-68cf8cf4cb-vwhnz                      2/2     Running   0          73m
olm-operator-6579cd88cb-kh94x                         2/2     Running   0          74m
openshift-apiserver-7c6c46f6c-wq9bm                   2/2     Running   0          64m
openshift-controller-manager-58cd5ccb74-rzgw9         1/1     Running   0          74m
openshift-oauth-apiserver-68ff5db78b-2kmcs            1/1     Running   0          74m
openshift-route-controller-manager-6568b84956-77gvt   1/1     Running   0          74m
ovnkube-master-0                                      7/7     Running   0          66m
packageserver-6f685747-vdjqs                          2/2     Running   0          74m
redhat-marketplace-catalog-7b87d5749f-5n6r4           1/1     Running   0          74m
redhat-operators-catalog-5b4c9cfd9f-wlbvj             1/1     Running   0          74m
```
3. Check if the OKD cluster works:
```shell
$ export KUBECONFIG=/root/labs/okd/spoke/auth/kubeconfig

$ oc get nodes
NAME        STATUS   ROLES    AGE   VERSION
okd-bmh-1   Ready    worker   59m   v1.25.7+eab9cc9

$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.12.0    False       True          77m     Cluster version is 4.12.0-0.okd-2023-03-18-084815

$ oc get co
NAME                                       VERSION                          AVAILABLE   PROGRESSING   DEGRADED   SINCE   MESSAGE
console                                    4.12.0-0.okd-2023-03-18-084815   True        False         False      3m12s
csi-snapshot-controller                    4.12.0-0.okd-2023-03-18-084815   True        False         False      66m
dns                                        4.12.0-0.okd-2023-03-18-084815   True        False         False      56m
image-registry                             4.12.0-0.okd-2023-03-18-084815   True        False         False      56m
ingress                                    4.12.0-0.okd-2023-03-18-084815   True        False         False      65m
insights                                   4.12.0-0.okd-2023-03-18-084815   True        False         False      56m
kube-apiserver                             4.12.0-0.okd-2023-03-18-084815   True        False         False      66m
kube-controller-manager                    4.12.0-0.okd-2023-03-18-084815   True        False         False      66m
kube-scheduler                             4.12.0-0.okd-2023-03-18-084815   True        False         False      66m
kube-storage-version-migrator              4.12.0-0.okd-2023-03-18-084815   True        False         False      56m
monitoring                                 4.12.0-0.okd-2023-03-18-084815   True        False         False      54m
network                                    4.12.0-0.okd-2023-03-18-084815   True        False         False      57m
node-tuning                                4.12.0-0.okd-2023-03-18-084815   True        False         False      59m
openshift-apiserver                        4.12.0-0.okd-2023-03-18-084815   True        False         False      66m
openshift-controller-manager               4.12.0-0.okd-2023-03-18-084815   True        False         False      66m
openshift-samples                          4.12.0-0.okd-2023-03-18-084815   True        False         False      55m
operator-lifecycle-manager                 4.12.0-0.okd-2023-03-18-084815   True        False         False      65m
operator-lifecycle-manager-catalog         4.12.0-0.okd-2023-03-18-084815   True        False         False      65m
operator-lifecycle-manager-packageserver   4.12.0-0.okd-2023-03-18-084815   True        False         False      66m
service-ca                                 4.12.0-0.okd-2023-03-18-084815   True        False         False      56m
storage                                    4.12.0-0.okd-2023-03-18-084815   True        False         False      66m
```

## Links
* [OKD release images](https://quay.io/repository/openshift/okd?tab=tags)
* [CoreOS Fedora builds](https://builds.coreos.fedoraproject.org/browser?stream=stable&arch=x86_64)
