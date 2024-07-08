# neat lab
In this lab we want to test if the `assisted-service`, deployed with ACM, works correctly using the REST API instead of kubeapi.  
Additionally we must run the REST API without authentication, allowing the integration of external clients without problems.

## Requirements
Software versions required:
* Openshift **4.15/4.16**
* ACM **2.10/2.11**

## Steps
### Hub cluster
1. Install a _compact_ Openshift cluster with:
```shell
ap labs/neat/deploy.yaml --tags ocp
```
2. Install ACM.
```shell
ap labs/neat/deploy.yaml --tags acm
```
3. Validate

## Validation
1. Check if the cluster is running:
```shell
$ export KUBECONFIG=/root/labs/neat/deploy/auth/kubeconfig

$ oc get nodes
NAME           STATUS   ROLES                         AGE    VERSION
neat-node-1    Ready    control-plane,master,worker   114m   v1.28.7+f1b5f6c
neat-node-2    Ready    control-plane,master,worker   127m   v1.28.7+f1b5f6c
neat-node-3    Ready    control-plane,master,worker   127m   v1.28.7+f1b5f6c

$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.15.4    True        False         14m     Cluster version is 4.15.4
```
2. Verify the ACM installation:
```shell
$ oc get csv -n open-cluster-management
NAMESPACE                              NAME                                  DISPLAY                                      VERSION   REPLACES                              PHASE
open-cluster-management                advanced-cluster-management.v2.10.3   Advanced Cluster Management for Kubernetes   2.10.3    advanced-cluster-management.v2.10.2   Succeeded
```
3. Check if the `infraenv` called **infra1** exists:
```shell
$ oc get infraenv -A
NAMESPACE            NAME     ISO CREATED AT
hardware-inventory   infra1
```
4. Test the `assisted-service` REST API:
* Create a new `infra-env`
```shell
$ curl -k -X POST -H "Content-Type: application/json" \
    -d @infraenv.json \
    https://assisted-service-multicluster-engine.apps.neat.local.lab/api/assisted-install/v2/infra-envs

{
  "cpu_architecture": "x86_64",
  "created_at": "2024-07-05T09:01:29.034046Z",
  "download_url": "https://assisted-image-service-multicluster-engine.apps.neat.local.lab/byid/fc0bae51-4f54-4a90-a194-21884918a735/4.14/x86_64/minimal.iso",
  "email_domain": "Unknown",
  "expires_at": "0001-01-01T00:00:00.000Z",
  "href": "/api/assisted-install/v2/infra-envs/fc0bae51-4f54-4a90-a194-21884918a735",
  "id": "fc0bae51-4f54-4a90-a194-21884918a735",
  "kind": "InfraEnv",
  "name": "infra2",
  "openshift_version": "4.14",
  "proxy": {},
  "pull_secret_set": true,
  "type": "minimal-iso",
  "updated_at": "2024-07-05T09:01:29.044031Z",
  "user_name": "admin"
}
```
* Check if the new `infra-env` is present, and _infra1_ (kubeapi) is not present:
```shell
$ curl -k https://assisted-service-multicluster-engine.apps.neat.local.lab/api/assisted-install/v2/infra-envs

[
  {
    "cpu_architecture": "x86_64",
    "created_at": "2024-07-05T09:01:29.034046Z",
    "download_url": "https://assisted-image-service-multicluster-engine.apps.neat.local.lab/byid/fc0bae51-4f54-4a90-a194-21884918a735/4.14/x86_64/minimal.iso",
    "email_domain": "Unknown",
    "expires_at": "0001-01-01T00:00:00.000Z",
    "href": "/api/assisted-install/v2/infra-envs/fc0bae51-4f54-4a90-a194-21884918a735",
    "id": "fc0bae51-4f54-4a90-a194-21884918a735",
    "kind": "InfraEnv",
    "name": "infra2",
    "openshift_version": "4.14",
    "proxy": {},
    "pull_secret_set": true,
    "type": "minimal-iso",
    "updated_at": "2024-07-05T09:01:29.044031Z",
    "user_name": "admin"
  }
]
```
* Request the image URL:
```shell
$ curl -k https://assisted-service-multicluster-engine.apps.neat.local.lab/api/assisted-install/v2/infra-envs/fc0bae51-4f54-4a90-a194-21884918a735/downloads/image-url

{
  "expires_at": "0001-01-01T00:00:00.000Z",
  "url": "https://assisted-image-service-multicluster-engine.apps.neat.local.lab/byid/fc0bae51-4f54-4a90-a194-21884918a735/4.14/x86_64/minimal.iso"
}
```
* Download the ISO image:
```shell
$ curl -skO https://assisted-image-service-multicluster-engine.apps.neat.local.lab/byid/fc0bae51-4f54-4a90-a194-21884918a735/4.14/x86_64/minimal.iso

$ file minimal.iso
minimal.iso: ISO 9660 CD-ROM filesystem data 'rhcos-414.92.202310170514-0' (bootable)

$ ls -lh minimal.iso
-rw-r--r--. 1 root root 106M Jul  5 05:35 minimal.iso
```
5. Test the REST API form an internal pod:
* Start a pod within the cluster:
```shell
$ oc run -n default --image=registry.access.redhat.com/ubi8/ubi:latest ubi8 -it --restart=Never
```
* Check if the `infra-env` is present:
```shell
[root@ubi8 /]# curl -sk https://assisted-service.multicluster-engine.svc.cluster.local:8090/api/assisted-install/v2/infr-envs | jq
[
  {
    "cpu_architecture": "x86_64",
    "created_at": "2024-07-05T12:42:31.170077Z",
    "download_url": "https://assisted-image-service-multicluster-engine.apps.neat.local.lab/byid/2873fc5b-ef62-4f5f-81b7-c5ba67e0102a/4.14/x86_64/minimal.iso",
    "email_domain": "Unknown",
    "expires_at": "0001-01-01T00:00:00.000Z",
    "href": "/api/assisted-install/v2/infra-envs/2873fc5b-ef62-4f5f-81b7-c5ba67e0102a",
    "id": "2873fc5b-ef62-4f5f-81b7-c5ba67e0102a",
    "kind": "InfraEnv",
    "name": "infra2",
    "openshift_version": "4.14",
    "proxy": {},
    "pull_secret_set": true,
    "type": "minimal-iso",
    "updated_at": "2024-07-05T12:43:25.227591Z",
    "user_name": "admin"
  }
]
```
* Request the image URL:
```shell
[root@ubi8 /]# curl -sk https://assisted-service.multicluster-engine.svc.cluster.local:8090/api/assisted-install/v2/infa-envs/2873fc5b-ef62-4f5f-81b7-c5ba67e0102a/downloads/image-url | jq
{
  "expires_at": "0001-01-01T00:00:00.000Z",
  "url": "https://assisted-image-service-multicluster-engine.apps.neat.local.lab/byid/2873fc5b-ef62-4f5f-81b7-c5ba67e0102a/4.14/x86_64/minimal.iso"
}
```
* Download the ISO image using internal and external names:
```shell
[root@ubi8 /]# curl -skO https://assisted-image-service-multicluster-engine.apps.neat.local.lab/byid/2873fc5b-ef62-4f5f81b7-c5ba67e0102a/4.14/x86_64/minimal.iso
[root@ubi8 /]# ls -lh minimal.iso
-rw-r--r--. 1 root root 106M Jul  8 08:40 minimal.iso

[root@ubi8 /]# curl -skO https://assisted-image-service.multicluster-engine.svc.cluster.local:8080/byid/2873fc5b-ef62-4ff-81b7-c5ba67e0102a/4.14/x86_64/minimal.iso
[root@ubi8 /]# ls -lh minimal.iso
-rw-r--r--. 1 root root 106M Jul  8 08:49 minimal.iso
[root@ubi8 /]# rm -f minimal.iso
```

## Links
* [Assisted-Install Service API](https://developers.redhat.com/api-catalog/api/assisted-install-service)
* [REST-API V2 - Getting Started Guide](https://github.com/openshift/assisted-service/blob/master/docs/user-guide/rest-api-getting-started.md)
* [REST-API V2 - Day2](https://github.com/openshift/assisted-service/blob/master/docs/user-guide/rest-api-day2.md)
* [Specifying Environmental Variables via ConfigMap](https://github.com/openshift/assisted-service/blob/master/docs/operator.md#specifying-environmental-variables-via-configmap)
* [AgentServiceConfig options](https://github.com/openshift/assisted-service/blob/b7116f3a023014bbc5290a071aeb2326c00711e1/internal/controller/controllers/agentserviceconfig_controller.go#L1189)
* [Assisted service operator doc](https://github.com/openshift/assisted-service/blob/master/docs/operator.md#operator-build-and-deployment)
* [assisted-test-infra](https://github.com/openshift/assisted-test-infra?tab=readme-ov-file#deployment-parameters)
