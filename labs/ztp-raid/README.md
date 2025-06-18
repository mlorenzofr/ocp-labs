# ztp-raid lab
This lab installs a _compact_ Openshift cluster with ACM, Gitops and TALM.  
A SNO cluster deployment is included in the [ztp-example](https://github.com/mlorenzofr/ztp-example/tree/zraid) and can be tested on day-2. This lab uses the **zraid** branch.

>[!WARNING]  
> While this lab can be useful for verifying resources, development and understanding the workflow, the SNO cluster will never be installed because the software RAID provisioning is not supported.  
> We would find this error in the `BaremetalHost`:
```shell
Clean step raid.create_configuration failed on node e0ceb412-b9ac-447c-8ae2-ab2c63381fa8. Failed to create md device /dev/md0 on /dev/vda1 /dev/vdb1: Unexpected error while running command.
Command: mdadm --create /dev/md0 --force --run --metadata=1 --level 1 --name /dev/md0 --raid-devices 2 /dev/vda1 /dev/vdb1
Exit code: 2
Stdout: ''
Stderr: 'mdadm: Value "/dev/md0" cannot be set as name. Reason: Not POSIX compatible.\n'
```

## Requirements
None.

## Steps
1. Execute the playbook `deploy.yaml`:
```shell
ap labs/zraid/deploy.yaml
```
2. Edit the **multiclusterhub-operator** and replace the  `OPERAND_IMAGE_SITECONFIG_OPERATOR` environment variable with the custom image:
```
quay.io/mlorenzofr/siteconfig-manager@sha256:7241f06269801bcb8f01a7d56fae877e95a8df4872fea3dcb1eb0739dc20f45b
```
```shell
$ oc edit deploy -n open-cluster-management multiclusterhub-operator -o yaml
```
3. Configure the ArgoCD applications:
```shell
ap labs/zraid/deploy.yaml --tags argocd
```

## Validation
1. Check if the Openshift cluster is running:
```shell
$ export KUBECONFIG=~/zraid/deploy/auth/kubeconfig

$ oc get nodes
NAME           STATUS   ROLES                         AGE    VERSION
zraid-master-1   Ready    control-plane,master,worker   18h   v1.31.8
zraid-master-2   Ready    control-plane,master,worker   19h   v1.31.8
zraid-master-3   Ready    control-plane,master,worker   19h   v1.31.8

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

### ZTP spoke
This cluster will never be installed, but to review the resources involved:
1. `ClusterInstances`:
```shell
$ oc get clusterinstances.siteconfig.open-cluster-management.io -A
NAMESPACE   NAME      PAUSED   PROVISIONSTATUS   PROVISIONDETAILS       AGE
ztp-sno     ztp-sno            InProgress        Provisioning cluster   3h37m
```
2. `BaremetalHost`:
```shell
$ oc get bmh -A
NAMESPACE               NAME             STATE       CONSUMER               ONLINE   ERROR               AGE
openshift-machine-api   zraid-master-1   unmanaged   zraid-ckf7b-master-0   true                         19h
openshift-machine-api   zraid-master-2   unmanaged   zraid-ckf7b-master-1   true                         19h
openshift-machine-api   zraid-master-3   unmanaged   zraid-ckf7b-master-2   true                         19h
ztp-sno                 zraid-bmh-1      preparing                          true     preparation error   3h30m

$ oc get bmh -n ztp-sno zraid-bmh-1 -o yaml
```
3. `infraenv`:
```shell
$ oc get infraenv -A
NAMESPACE   NAME      ISO CREATED AT
ztp-sno     ztp-sno   2025-06-18T07:40:58Z
```
4. `clusterdeployment`:
```shell
$ oc get clusterdeployment -A
NAMESPACE   NAME      INFRAID   PLATFORM          REGION   VERSION   CLUSTERTYPE   PROVISIONSTATUS   POWERSTATE   AGE
ztp-sno     ztp-sno             agent-baremetal                                    Provisioning                   3h36m
```

## Links
* [siteconfig-controller](https://github.com/mlorenzofr/siteconfig/tree/rfe-5666)
* [ztp-example repository](https://github.com/mlorenzofr/ztp-example/tree/zraid)
* [baremetalhost types.go](https://github.com/metal3-io/baremetal-operator/blob/b6aa2579347fe05b2a7e3f8728f7bbc0498b664d/apis/metal3.io/v1alpha1/baremetalhost_types.go#L308)
