# alternative dev-scripts lab
In this lab, the goal is create an environment for **assisted-service** development.  
The work is based in the previous [dev-scripts experience](https://github.com/openshift-metal3/dev-scripts/blob/master/assisted_deployment.sh).  
The idea is to have an Openshift cluster where we will install the assisted-installer and hive operators manually.  
Unfortunately, this lab is not fully functional and we switched to a new solution using `kind`.  

## Requirements

## Steps
1. Execute the playbook `deploy.yaml` with tag `ocp`:
```shell
ap labs/elior/deploy.yaml --tags ocp
```
2. Execute the playbook `deploy.yaml` with `postinst`tag:
```shell
ap labs/elior/deploy.yaml --tags postinst
```
3. Manual steps:
```shell
oc apply -f lvmcluster-mce-data.yaml
oc apply -f hive-operator.yaml
oc apply -f hive-config.yaml
oc apply -f managedcluster-crd.yaml
oc apply -f assisted-service-operator.yaml
oc apply -f agent-service-config.yaml
oc apply -f agentinstalladmission-rbac.yaml
# Here the problems begin
oc apply -f infra/01-env-sno.yaml
```

## Validation
1. Check if the _hub cluster_ is running:
```shell
$ export KUBECONFIG=/root/labs/elior/deploy/auth/kubeconfig

$ oc get nodes
NAME           STATUS   ROLES                         AGE    VERSION
elior-node-1   Ready    control-plane,master,worker   48m   v1.28.7+f1b5f6c
elior-node-2   Ready    control-plane,master,worker   63m   v1.28.7+f1b5f6c
elior-node-3   Ready    control-plane,master,worker   63m   v1.28.7+f1b5f6c

$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.15.4    True        False         129m    Cluster version is 4.15.4
```
2. Check assisted-installer operator:
```shell
oc get pods -n assisted-installer
```
2. Check if OKD _standalone cluster_ is provisioned:
```shell
$ oc get bmh -n hive-sno
NAME        STATE         CONSUMER   ONLINE   ERROR   AGE
elior-bmh-1   provisioned              true             31m

$ oc get clusterdeployment -n hive-sno
NAME   INFRAID                                PLATFORM          REGION   VERSION                               CLUSTERTYPE   PROVISIONSTATUS   POWERSTATE   AGE
sno    fbc67676-11b7-4f7c-b6d1-ec501fb98b57   agent-baremetal            4.15.0-0.okd-scos-2024-01-18-223523                 Provisioned       Running      39m
```
3. Check if the OKD cluster works:
```shell
$ export KUBECONFIG=/root/labs/elior/sno/auth/kubeconfig

$ oc get nodes
NAME        STATUS   ROLES                         AGE   VERSION
elior-bmh-1   Ready    control-plane,master,worker   10m   v1.28.3+20a5764

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

## Known problems
There are problems with `assisted-installer` and `hive` operators.  
RBAC policies are not included or some CRD's are missing from the installation.  
In the case of `hive` some problems were resolved using the version `1.2.4355-e5f809f`.  
Some examples:
```
$ oc logs -n assisted-installer agentinstalladmission-6df69585b5-xxgd2
... ...
E0703 08:56:22.060262       1 reflector.go:147] k8s.io/client-go/informers/factory.go:159: Failed to watch *v1.PriorityLevelConfiguration: failed to list *v1.PriorityLevelConfiguration: the server could not find the requested resource
W0703 08:57:06.850738       1 reflector.go:539] k8s.io/client-go/informers/factory.go:159: failed to list *v1.PriorityLevelConfiguration: the server could not find the requested resource
E0703 08:57:06.850769       1 reflector.go:147] k8s.io/client-go/informers/factory.go:159: Failed to watch *v1.PriorityLevelConfiguration: failed to list *v1.PriorityLevelConfiguration: the server could not find the requested resource
W0703 08:57:08.593504       1 reflector.go:539] k8s.io/client-go/informers/factory.go:159: failed to list *v1.FlowSchema: the server could not find the requested resource
E0703 08:57:08.593533       1 reflector.go:147] k8s.io/client-go/informers/factory.go:159: Failed to watch *v1.FlowSchema: failed to list *v1.FlowSchema: the server could not find the requested resource
```

## Links
* [Feature: Per cluster mirror configuration](https://issues.redhat.com/browse/MGMT-18013)
* [Configuring Additional Image Registries for the Workload Cluster](https://github.com/openshift-assisted/cluster-api-agent/blob/master/docs/image_registry.md)
* [Mirror Registry Configuration](Configuring Additional Image Registries for the Workload Cluster)
* [openshift-metal3/dev-scripts](https://github.com/openshift-metal3/dev-scripts/)
