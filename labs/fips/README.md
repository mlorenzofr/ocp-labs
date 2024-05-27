# FIPS lab
In this lab the goal is install an Openshift Cluster with FIPS mode enabled.  

## Requirements
SSH key type ssh-ed25519 unavailable when FIPS is enabled. Please use rsa or ecdsa.

## Steps
1. Execute the playbook `deploy.yaml`:
```shell
ap labs/fips/deploy.yaml
```

## Validation
1. Check if the _hub cluster_ is running:
```shell
$ export KUBECONFIG=/root/labs/fips/deploy/auth/kubeconfig

$ oc get nodes
fips-master-1   Ready    control-plane,master,worker   75m   v1.28.7+f1b5f6c
fips-master-2   Ready    control-plane,master,worker   74m   v1.28.7+f1b5f6c
fips-master-3   Ready    control-plane,master,worker   74m   v1.28.7+f1b5f6c

$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.15.4    True        False         55m     Cluster version is 4.15.4
```
2. On OCP nodes, check if `/proc/sys/crypto/fips_enabled` is set to **1**.  
The FIPS version must match version **kernel-5.14.0-284.57.1.el9_2** too.
```shell
$ grep . /proc/sys/crypto/fips_*
/proc/sys/crypto/fips_enabled:1
/proc/sys/crypto/fips_name:Red Hat Enterprise Linux 9 - Kernel Cryptographic API
/proc/sys/crypto/fips_version:5.14.0-284.57.1.el9_2.x86_64
```
3. On OCP nodes, check wether the version of these packages matches the FIPS certified versions:
```shell
$ rpm -qa --queryformat "%{NAME} %{VERSION}-%{RELEASE}\n" openssl libgcrypt gnutls libkcapi libkcapi-hmaccalc nss nettle kernel
openssl 3.0.7-18.el9_2
libgcrypt 1.10.0-10.el9_2
kernel 5.14.0-284.57.1.el9_2
libkcapi 1.3.1-3.el9
libkcapi-hmaccalc 1.3.1-3.el9
gnutls 3.7.6-21.el9_2.2
nettle 3.8-3.el9_0
```
4. Check if `MachineConfig` templates have the **Fips** enabled:
```shell
$ oc get mcp
NAME     CONFIG                                             UPDATED   UPDATING   DEGRADED   MACHINECOUNT   READYMACHINECOUNT   UPDATEDMACHINECOUNT   DEGRADEDMACHINECOUNT   AGE
master   rendered-master-1f71f198d2a4be7c117fd6247a9498e7   True      False      False      3              3                   3                     0                      116m
worker   rendered-worker-381cbeaef988898e1226447e971a5ca6   True      False      False      0              0                   0                     0                      116m

$ oc describe mc rendered-master-1f71f198d2a4be7c117fd6247a9498e7 | grep Fips
  Fips:  true

$ oc describe mc rendered-worker-381cbeaef988898e1226447e971a5ca6 | grep Fips
  Fips:  true
```
5. Check if `ClusterDeployments` are provisioned. The spoke cluster **4.15** should work, the version **4.16** should not.
The Agent-Installer for version 4.16 is not yet FIPS compliant.
```shell
$ oc get ClusterDeployment -A
NAMESPACE   NAME     INFRAID                                PLATFORM          REGION   VERSION   CLUSTERTYPE   PROVISIONSTATUS   POWERSTATE   AGE
spoke1      spoke1                                          agent-baremetal                                    Provisioning                   3d14h
spoke2      spoke2   112b1ef5-8d6d-4ff9-ac0a-6b3155e906ef   agent-baremetal            4.15.14                 Provisioned       Running      3d18h
```

## Optional tasks
Encrypt `etcd` data:
```shell
$ oc patch apiserver cluster --type merge --patch '{"spec":{"encryption":{"type": "aesgcm"}}}'
```

## Links
* [Support for FIPS cryptography](https://docs.openshift.com/container-platform/4.15/installing/installing-fips.html)
* [Red Hat Compliance Activities and Government Standards](https://access.redhat.com/articles/compliance_activities_and_gov_standards#fips-140-2-and-fips-140-3-2)
* [Encrypting etcd data](https://docs.openshift.com/container-platform/4.15/security/encrypting-etcd.html)
