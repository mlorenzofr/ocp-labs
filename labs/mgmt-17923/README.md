# OCPBUGS-33185 lab
This lab is used to triage the issue [MGMT-17923](https://issues.redhat.com/browse/MGMT-17923).

## Requirements
Software versions required:
* Openshift **4.13.41**
* ACM **2.9

## Steps
### Hub cluster
1. Install a _compact_ Openshift cluster with:
```shell
ap labs/mgmt-17923/deploy.yaml --tags ocp
```
2. Install ACM.
```shell
ap labs/mgmt-17923/deploy.yaml --tags acm
```
3. Modify the definition of BMHs to share the same secret between them
4. Apply the set up manifests:
```shell
oc apply -f lvms-subscription.yaml
oc apply -f lvmcluster-mce-data.yaml
oc apply -f acm-subscription.yaml
oc apply -f acm-multiclusterhub.yaml
oc apply -f agent-service-config.yaml
oc apply -f infra/01-env-infra1.yaml
oc apply -f infra/02-bmh-infra1.yaml
```
5. Delete a host using the **RHACM** web console.
* `Infrastructure`
 * `Host Inventory`
  * Select the host menu and push `Remove Host`
6. Validate
7. Add the missing secret again
```shell
oc apply -f infra/03-secret.yaml
```
8. Validate

## Validation
1. Check if the cluster is running:
```shell
$ export KUBECONFIG=/root/labs/skrenger/deploy/auth/kubeconfig

$ oc get nodes
NAME              STATUS   ROLES                         AGE   VERSION
skrenger-node-1   Ready    control-plane,master,worker   16h   v1.26.15+4818370
skrenger-node-2   Ready    control-plane,master,worker   16h   v1.26.15+4818370
skrenger-node-3   Ready    control-plane,master,worker   16h   v1.26.15+4818370

$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.13.41   True        False         16h     Cluster version is 4.13.41
```
2. Verify the ACM installation:
```shell
$ oc get csv -n open-cluster-management
NAMESPACE                              NAME                                  DISPLAY                                      VERSION   REPLACES                              PHASE
open-cluster-management                advanced-cluster-management.v2.9.4   Advanced Cluster Management for Kubernetes   2.9.4     advanced-cluster-management.v2.9.3   Succeeded
```
3. Check the baremetal hosts, we should have 2 hosts provisioned:
```shell
$ oc get bmh -A
NAMESPACE               NAME                STATE         CONSUMER                  ONLINE   ERROR   AGE
hardware-inventory      skrenger-worker-1   provisioned                             true             2m23s
hardware-inventory      skrenger-worker-2   provisioned                             true             2m23s
openshift-machine-api   skrenger-node-1     unmanaged     skrenger-rc7gk-master-0   true             88m
openshift-machine-api   skrenger-node-2     unmanaged     skrenger-rc7gk-master-1   true             88m
openshift-machine-api   skrenger-node-3     unmanaged     skrenger-rc7gk-master-2   true             88m
```
4. Validate that we have only 1 secret in the inventory namespace:
```shell
$ oc get secrets -n hardware-inventory
NAME                           TYPE                                  DATA   AGE
builder-dockercfg-vnx4p        kubernetes.io/dockercfg               1      10m
builder-token-hpq6k            kubernetes.io/service-account-token   4      10m
default-dockercfg-9kd5c        kubernetes.io/dockercfg               1      10m
default-token-qzm5q            kubernetes.io/service-account-token   4      10m
deployer-dockercfg-5hh9l       kubernetes.io/dockercfg               1      10m
deployer-token-cmxbc           kubernetes.io/service-account-token   4      10m
pull-secret-infra1             kubernetes.io/dockerconfigjson        1      10m
skrenger-worker-1-bmc-secret   Opaque                                2      4m12s
```
5. After the BMH removal step. Check if the shared secret has been removed:
```shell
$ oc get secrets -n hardware-inventory
NAME                       TYPE                                  DATA   AGE
builder-dockercfg-vnx4p    kubernetes.io/dockercfg               1      15m
builder-token-hpq6k        kubernetes.io/service-account-token   4      15m
default-dockercfg-9kd5c    kubernetes.io/dockercfg               1      15m
default-token-qzm5q        kubernetes.io/service-account-token   4      15m
deployer-dockercfg-5hh9l   kubernetes.io/dockercfg               1      15m
deployer-token-cmxbc       kubernetes.io/service-account-token   4      15m
pull-secret-infra1         kubernetes.io/dockerconfigjson        1      15m
```
6. Get the status of BMHs:
```shell
$ oc get bmh -n hardware-inventory skrenger-worker-1
NAME                STATE         CONSUMER   ONLINE   ERROR                AGE
skrenger-worker-1   provisioned              true     registration error   10m
```
7. Check the BMH status:
```shell
$ oc get bmh -n hardware-inventory skrenger-worker-1 -o json | jq -r '.status | .errorCount, .errorMessage, .errorType, .goodCredentials'
48
BMC CredentialsName secret doesn't exist The BMC secret hardware-inventory/skrenger-worker-1-bmc-secret does not exist
registration error
{
  "credentials": {
    "name": "skrenger-worker-1-bmc-secret",
    "namespace": "hardware-inventory"
  },
  "credentialsVersion": "81996"
}
```
8. Repeat steps **6** and **7** after recreating the secret.

## Links
* [BareMetalHost shows "registration error" despite Secret being available](https://issues.redhat.com/browse/MGMT-17923)
* [Openshift Console for this lab](https://console-openshift-console.apps.skrenger.local.lab/)
