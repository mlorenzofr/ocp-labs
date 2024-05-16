# hive-okd lab
In this lab the goal is install an Openshift Cluster with an OKD _spoke cluster_ inside.  
The _spoke_ cluster will be a **standalone** cluster, not a `HostedCluster` like the case of HCP (_Hypershift_).  

## Requirements
The image used in the `assisted-service` must be an OKD/SCOS version, otherwise the installation fails.
The following **okd-scos** versions are validated:

| Version | Agent image  | OKD image  | status |
| :---:   | :------:     | :-------:  | :----: |
| 4.15    | [415.92.202402130021-0](https://mirror.openshift.com/pub/openshift-v4/x86_64/dependencies/rhcos/4.15/4.15.0/rhcos-4.15.0-x86_64-live.x86_64.iso) | quay.io/okd/scos-release:4.15.0-0.okd-scos-2024-01-18-223523 | :white_check_mark: |
| 4.14    | [414.92.202310210434-0](https://mirror.openshift.com/pub/openshift-v4/x86_64/dependencies/rhcos/4.14/4.14.0/rhcos-4.14.0-x86_64-live.x86_64.iso) | quay.io/okd/scos-release:4.14.0-0.okd-scos-2024-01-30-032525 | :white_check_mark: |
| 4.13    | [413.92.202308210212-0](https://mirror.openshift.com/pub/openshift-v4/x86_64/dependencies/rhcos/4.13/4.13.10/rhcos-4.13.10-x86_64-live.x86_64.iso) | quay.io/okd/scos-release:4.13.0-0.okd-scos-2023-10-19-111256 | :white_check_mark: |

## Steps
1. Execute the playbook `deploy.yaml`:
```shell
ap labs/hive-okd/deploy.yaml
```

## Validation
1. Check if the _hub cluster_ is running:
```shell
$ export KUBECONFIG=/root/labs/okd/deploy/auth/kubeconfig

$ oc get nodes
NAME           STATUS   ROLES                         AGE    VERSION
okd-master-1   Ready    control-plane,master,worker   151m   v1.28.7+f1b5f6c
okd-master-2   Ready    control-plane,master,worker   151m   v1.28.7+f1b5f6c
okd-master-3   Ready    control-plane,master,worker   151m   v1.28.7+f1b5f6c

$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.15.4    True        False         129m    Cluster version is 4.15.4
```
2. Check if OKD _standalone cluster_ is provisioned:
```shell
$ oc get bmh -n hive-sno
NAME        STATE         CONSUMER   ONLINE   ERROR   AGE
okd-bmh-1   provisioned              true             31m

$ oc get clusterdeployment -n hive-sno
NAME   INFRAID                                PLATFORM          REGION   VERSION                               CLUSTERTYPE   PROVISIONSTATUS   POWERSTATE   AGE
sno    fbc67676-11b7-4f7c-b6d1-ec501fb98b57   agent-baremetal            4.15.0-0.okd-scos-2024-01-18-223523                 Provisioned       Running      39m
```
3. Check if the OKD cluster works:
```shell
$ export KUBECONFIG=/root/labs/okd/sno/auth/kubeconfig

$ oc get nodes
NAME        STATUS   ROLES                         AGE   VERSION
okd-bmh-1   Ready    control-plane,master,worker   10m   v1.28.3+20a5764

$ oc get clusterversion
NAME      VERSION                               AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.15.0-0.okd-scos-2024-01-18-223523   True        False         42s     Cluster version is 4.15.0-0.okd-scos-2024-01-18-223523

$ oc get co
NAME                                       VERSION                               AVAILABLE   PROGRESSING   DEGRADED   SINCE   MESSAGE
authentication                             4.15.0-0.okd-scos-2024-01-18-223523   True        False         False      98s
baremetal                                  4.15.0-0.okd-scos-2024-01-18-223523   True        False         False      10m
cloud-controller-manager                   4.15.0-0.okd-scos-2024-01-18-223523   True        False         False      10m
cloud-credential                           4.15.0-0.okd-scos-2024-01-18-223523   True        False         False      10m
cluster-autoscaler                         4.15.0-0.okd-scos-2024-01-18-223523   True        False         False      10m
config-operator                            4.15.0-0.okd-scos-2024-01-18-223523   True        False         False      12m
console                                    4.15.0-0.okd-scos-2024-01-18-223523   True        False         False      112s
control-plane-machine-set                  4.15.0-0.okd-scos-2024-01-18-223523   True        False         False      10m
csi-snapshot-controller                    4.15.0-0.okd-scos-2024-01-18-223523   True        False         False      11m
dns                                        4.15.0-0.okd-scos-2024-01-18-223523   True        False         False      11m
etcd                                       4.15.0-0.okd-scos-2024-01-18-223523   True        False         False      8m27s
image-registry                             4.15.0-0.okd-scos-2024-01-18-223523   True        False         False      5m57s
ingress                                    4.15.0-0.okd-scos-2024-01-18-223523   True        False         False      11m
insights                                   4.15.0-0.okd-scos-2024-01-18-223523   True        False         False      3m6s
kube-apiserver                             4.15.0-0.okd-scos-2024-01-18-223523   True        False         False      6m25s
kube-controller-manager                    4.15.0-0.okd-scos-2024-01-18-223523   True        False         False      6m7s
kube-scheduler                             4.15.0-0.okd-scos-2024-01-18-223523   True        False         False      6m7s
kube-storage-version-migrator              4.15.0-0.okd-scos-2024-01-18-223523   True        False         False      11m
machine-api                                4.15.0-0.okd-scos-2024-01-18-223523   True        False         False      10m
machine-approver                           4.15.0-0.okd-scos-2024-01-18-223523   True        False         False      10m
machine-config                             4.15.0-0.okd-scos-2024-01-18-223523   True        False         False      10m
marketplace                                4.15.0-0.okd-scos-2024-01-18-223523   True        False         False      10m
monitoring                                 4.15.0-0.okd-scos-2024-01-18-223523   True        False         False      5m4s
network                                    4.15.0-0.okd-scos-2024-01-18-223523   True        False         False      11m
node-tuning                                4.15.0-0.okd-scos-2024-01-18-223523   True        False         False      11m
openshift-apiserver                        4.15.0-0.okd-scos-2024-01-18-223523   True        False         False      2m35s
openshift-controller-manager               4.15.0-0.okd-scos-2024-01-18-223523   True        False         False      4m24s
openshift-samples                          4.15.0-0.okd-scos-2024-01-18-223523   True        False         False      6m45s
operator-lifecycle-manager                 4.15.0-0.okd-scos-2024-01-18-223523   True        False         False      10m
operator-lifecycle-manager-catalog         4.15.0-0.okd-scos-2024-01-18-223523   True        False         False      10m
operator-lifecycle-manager-packageserver   4.15.0-0.okd-scos-2024-01-18-223523   True        False         False      7m5s
service-ca                                 4.15.0-0.okd-scos-2024-01-18-223523   True        False         False      12m
storage                                    4.15.0-0.okd-scos-2024-01-18-223523   True        False         False      10m
```

## Links
* [OKD release images](https://quay.io/repository/openshift/okd?tab=tags)
* [SCOS release images](https://quay.io/repository/okd/scos-release?tab=tags)
* [RHCOS release images](https://mirror.openshift.com/pub/openshift-v4/x86_64/dependencies/rhcos/)
* [Preview OKD/SCOS images](https://origin-release.ci.openshift.org/releasestream/4-scos-next)
* [How do I use ACM and Assisted Service to install OKD-SCOS? ](https://access.redhat.com/solutions/7047028)
* [Building CentOS Stream CoreOS](https://github.com/openshift/os/blob/master/docs/development-scos.md)
