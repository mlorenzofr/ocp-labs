# ACM session guide

We have the environment pre-installed, with the cluster hub deployed.

We begin by exporting the `KUBECONFIG` variable and verifying that we have access to the cluster:
```shell
$ export KUBECONFIG=~/labs/acm/deploy/auth/kubeconfig

$ oc get nodes
NAME           STATUS   ROLES                         AGE   VERSION
acm-master-1   Ready    control-plane,master,worker   19h   v1.33.5
acm-master-2   Ready    control-plane,master,worker   19h   v1.33.5
acm-master-3   Ready    control-plane,master,worker   19h   v1.33.5
```

The manifests we will use to deploy ACM-related resources are available in the directory `~/labs/acm/config`.
```shell
cd ~/labs/acm/config
```

The Web UI for our OpenShift cluster is available [here](https://console-openshift-console.apps.acm.local.lab/)  
It is also possible to work using `oc` or `kubectl` from your computer using the OpenShift API.  
For it to function correctly, these DNS addresses must be resolved:
- `console-openshift-console.apps.acm.local.lab`
- `oauth-openshift.apps.acm.local.lab`
- `api.acm.local.lab`

## ACM installation

The first step is to install the ACM operator. We can do this via the Web UI or by applying the subscription manifest.
```shell
$ oc create -f acm-subscription.yaml
```
We can see if the operator installation has finished by checking its status:
```shell
$ oc get subscriptions acm -n open-cluster-management -o jsonpath='{.status.state}{"\n"}'
AtLatestKnown

$ oc get pods -n open-cluster-management
NAME                                        READY   STATUS    RESTARTS   AGE
multiclusterhub-operator-666c97996f-799zt   1/1     Running   0          6m38s
multiclusterhub-operator-666c97996f-wrmpb   1/1     Running   0          6m38s
```

Now that the operator is installed, we can create the `MulticlusterHub` resource, which will deploy all the ACM components.
```shell
oc create -f acm.yaml
```

We will see that this creates new pods and operators, including the `MultiClusterEngine`, which in turn includes **assisted-service**.
```shell
$ oc get pods -n multicluster-engine
NAME                                                   READY   STATUS    RESTARTS   AGE
cluster-curator-controller-7c88dfc86d-7hnjn            1/1     Running   0          69s
cluster-curator-controller-7c88dfc86d-nzq84            1/1     Running   0          69s
cluster-image-set-controller-7749b9fc46-qh4xx          1/1     Running   0          69s
cluster-manager-5df95894d-ld7wg                        1/1     Running   0          69s
cluster-manager-5df95894d-lq25w                        1/1     Running   0          68s
cluster-manager-5df95894d-rvkp2                        1/1     Running   0          68s
cluster-proxy-5995d9bfd-mhms8                          1/1     Running   0          37s
cluster-proxy-5995d9bfd-x6ndl                          1/1     Running   0          37s
cluster-proxy-addon-manager-c98b5c748-hv6d7            1/1     Running   0          47s
cluster-proxy-addon-manager-c98b5c748-kv255            1/1     Running   0          47s
cluster-proxy-addon-user-7dcf88fcd9-594b6              2/2     Running   0          47s
cluster-proxy-addon-user-7dcf88fcd9-blpbn              2/2     Running   0          47s
clusterclaims-controller-875989c85-59bws               2/2     Running   0          69s
clusterclaims-controller-875989c85-dj57g               2/2     Running   0          69s
clusterlifecycle-state-metrics-v2-6d57bd9bf-8sm8z      1/1     Running   0          69s
console-mce-console-8f49d5dd8-g52p2                    1/1     Running   0          70s
console-mce-console-8f49d5dd8-sldfr                    1/1     Running   0          70s
discovery-operator-687664dd96-kpv4s                    1/1     Running   0          70s
hcp-cli-download-6648987cd4-fjfz6                      1/1     Running   0          18s
hive-operator-7bc6f6b5b6-4gj2n                         1/1     Running   0          69s
hypershift-addon-manager-59bbb86847-ccpxp              1/1     Running   0          51s
infrastructure-operator-559fb899-2vlng                 1/1     Running   0          69s
managedcluster-import-controller-v2-774bcc59cb-fl9s7   1/1     Running   0          68s
managedcluster-import-controller-v2-774bcc59cb-q69h8   1/1     Running   0          68s
multicluster-engine-operator-f75994cdc-69jtk           1/1     Running   0          103s
multicluster-engine-operator-f75994cdc-kqb75           1/1     Running   0          103s
ocm-controller-6d8c65dccf-7f2bs                        1/1     Running   0          68s
ocm-controller-6d8c65dccf-mptsr                        1/1     Running   0          68s
ocm-proxyserver-5fc9f8445b-hb6w6                       1/1     Running   0          68s
ocm-proxyserver-5fc9f8445b-qcgrp                       1/1     Running   0          68s
ocm-webhook-f49945dbb-blw4w                            1/1     Running   0          68s
ocm-webhook-f49945dbb-ktnzw                            1/1     Running   0          68s
provider-credential-controller-558779d5c4-czlp9        2/2     Running   0          69s

$ oc get pods -n open-cluster-management
NAME                                                              READY   STATUS    RESTARTS       AGE
multicluster-integrations-98cf6fc84-glm5g                         3/3     Running   1 (101s ago)   3m10s
multicluster-operators-application-c6dc84799-fc5hn                3/3     Running   2 (101s ago)   3m10s
multicluster-operators-channel-5f9546c7d6-fmz7k                   1/1     Running   1 (96s ago)    3m10s
multicluster-operators-hub-subscription-597f6c787b-gkv5k          1/1     Running   1 (100s ago)   3m10s
multicluster-operators-standalone-subscription-58d8998fcf-qbl62   1/1     Running   0              3m11s
multicluster-operators-subscription-report-78d46dbcf-247r8        1/1     Running   0              3m10s
multiclusterhub-operator-666c97996f-799zt                         1/1     Running   0              12m
multiclusterhub-operator-666c97996f-wrmpb                         1/1     Running   0              12m
```

## assisted service

We've finished installing ACM, but the assisted service isn't working yet. This is because it needs some initial configuration before it can start.

Let's review the `agent-service-config.yaml` file.  
In this file we can see 3 storage definitions:
- **databaseStorage**. This will be the storage for the PostgreSQL database that uses `assisted-service`.
- **filesystemStorage**. This space will store logs and other user data from the `assisted-service`.
- **imageStorage**. This will be the storage that the `assisted-image-service` will use to save CoreOS images.

With this configuration we can see that we will need some storage in our OpenShift cluster, but right now we don't have any.
```shell
$ oc get sc
No resources found
```

### lvms operator installation

To add storage to our cluster, we will use local resources. The operator we will use for this purpose is the **LVMS operator**.

First we will install the operator:
```shell
$ oc create -f lvms-subscription.yaml

$ oc get subscriptions lvms -n openshift-storage -o jsonpath='{.status.state}{"\n"}'
AtLatestKnown

$ oc get pods -n openshift-storage
NAME                             READY   STATUS    RESTARTS   AGE
lvms-operator-78b5486445-8fjwq   1/1     Running   0          13s
```

Okay, with the operator ready, we'll now create the `LVMCluster` object. The nodes in our Openshift cluster have an additional disk ready to be used as local storage by the LVMS operator.
```shell
$ oc create -f lvmcluster-lv-data.yaml
```

Now we can see a StorageClass in our cluster ready to be used.
```shell
$ oc get sc
NAME                 PROVISIONER   RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
lvms-vg1 (default)   topolvm.io    Delete          WaitForFirstConsumer   true                   26s
```

### Initiating assisted service

Now that we have the storage, we can configure and start the **assisted service**:
```shell
oc create -f agent-service-config.yaml
```

If we check the multicluster-engine namespace, we can see the `assisted-service` pods running.
```shell
$ oc get pods -n multicluster-engine -l app=assisted-service
NAME                                READY   STATUS    RESTARTS   AGE
assisted-service-7c9757cc87-6j7sk   2/2     Running   0          2m30s

$ oc get pods -n multicluster-engine -l app=assisted-image-service
NAME                       READY   STATUS    RESTARTS   AGE
assisted-image-service-0   1/1     Running   0          2m45s
```

## Customize the assisted-service image

For development purposes, we may be interested in replacing the `assisted-service` image with an image that we have built ourselves.

Images can be configured as environment variables of the `infrastructure-operator`. However, this operator is managed by the `multicluster-engine-operator` (**MCE**), which in turn is managed by the `cluster-version-operator` (**CVO**). If we want to change the images, we must stop these two operators:
```shell
$ oc scale -n openshift-cluster-version deployment/cluster-version-operator --replicas=0
$ oc scale deployment/multicluster-engine-operator -n multicluster-engine --replicas=0
```

Finally, we edited the `infrastructure-operator` deployment and replace the `assisted-installer` image with our own version:
```shell
$ oc edit deployment -n multicluster-engine infrastructure-operator
```
```yaml
env:
- name: SERVICE_IMAGE
  value: quay.io/mlorenzofr/assisted-service@sha256:09be37e70f8a83e8ecdcbd55f1fb9cb04acd2535a65e005c776f76cbecb76aa0
```

This change will restart the deployment and cause the `assisted-service` pod to use this new image.
```shell
$ oc get pods -n multicluster-engine -l app=assisted-service
NAME                                READY   STATUS    RESTARTS   AGE
assisted-service-57cd779b7f-z47sp   2/2     Running   0          2m39s

$ oc get pods -n multicluster-engine -l app=assisted-service -o jsonpath='{.items[0].spec.containers[0].image }{"\n"}'
quay.io/mlorenzofr/assisted-service@sha256:09be37e70f8a83e8ecdcbd55f1fb9cb04acd2535a65e005c776f76cbecb76aa0
```

## Deployment of a spoke cluster

With `assisted-service` up and running, it's time to create a spoke cluster from our hub.

In terms of resources, we already have 4 VMs created in our lab. The VMs are currently powered off. When we create the resources in our OpenShift cluster, the VMs will automatically power on and be provisioned to install a new cluster.

To create this cluster we will use the following kinds of resources:
- `BareMetalHost`. It is the logical representation of a physical machine. It is related to an _Infraenv_.
- `InfraEnv`. Defines an infrastructure and its properties. Contains references to a _ClusterDeployment_ and its _AgentClusterInstall_.
- `AgentClusterInstall`. This contains the _ClusterDeployment_ installation properties.
- `ClusterDeployment`. It is the resource that defines the OpenShift Cluster and triggers the installation process.

> [!WARNING]
> These objects use secrets to store personal credentials. These secrets have been provisioned beforehand in our cluster.

> [!WARNING]
> By default, the Openshift only searches for `BareMetalHosts` in the `openshift-machine-api` namespace. This is already configured in our environment, but if setting up this scenario from scratch, the cluster provisioning configuration would need to be patched.
> `oc patch provisioning/provisioning-configuration -p '{"spec":{"watchAllNamespaces":true}}' --type merge`

The image we'll use to install our cluster exists, but it's not visible. We need to change this label in the `ClusterImageSet` resource.
```shell
$ oc label ClusterImageSet img4.20.3-x86-64-appsub --overwrite visible=true
```

We create the objects to begin the installation:
```shell
$ oc create -f infraenv-spoke-acm.yaml
infraenv.agent-install.openshift.io/spoke-acm created

$ oc create -f bmh-spoke-acm.yaml
baremetalhost.metal3.io/acm-bmh-1 created
baremetalhost.metal3.io/acm-bmh-2 created
baremetalhost.metal3.io/acm-bmh-3 created
baremetalhost.metal3.io/acm-bmh-4 created

$ oc create -f hive/spoke-acm.yaml
configmap/extra-manifests created
agentclusterinstall.extensions.hive.openshift.io/spoke-acm created
clusterdeployment.hive.openshift.io/spoke-acm created
```

The VMs will power on and provisioning will begin.
```shell
$ virsh list | grep acm
 493   acm-master-1          running
 494   acm-master-2          running
 495   acm-master-3          running
 496   acm-bmh-3             running
 497   acm-bmh-1             running
 498   acm-bmh-4             running
 499   acm-bmh-2             running

$ oc get bmh -n spoke
NAME        STATE         CONSUMER   ONLINE   ERROR   AGE
acm-bmh-1   provisioned              true             2m8s
acm-bmh-2   provisioned              true             2m8s
acm-bmh-3   provisioned              true             2m8s
acm-bmh-4   provisioned              true             2m8s
```

We can monitor the installation process by checking cluster events and agent status.
```shell
$ watch -n5 oc get agent -A
NAMESPACE   NAME                                   CLUSTER     APPROVED   ROLE     STAGE
spoke       1bfd7178-e402-4a00-886d-961d410ae089   spoke-acm   true       master   Writing image to disk
spoke       2887375f-41b8-453a-b33a-7b8631a87f74   spoke-acm   true       master   Writing image to disk
spoke       73161c13-ac16-451c-bade-b5b191323ed0   spoke-acm   true       master   Rebooting

$ curl -sk "$(oc get agentclusterinstall spoke-acm -n spoke -o jsonpath='{.status.debugInfo.eventsURL}')" | jq
... ...
  {
    "cluster_id": "30bda52c-d558-49be-aaa7-113c2bce23ed",
    "event_time": "2025-11-15T18:30:23.695Z",
    "host_id": "2887375f-41b8-453a-b33a-7b8631a87f74",
    "infra_env_id": "cc379302-26f4-4fb2-903b-85e4f1fe8bce",
    "message": "Host acm-bmh-1: updated status from known to preparing-for-installation (Host finished successfully to prepare for installation)",
    "name": "host_status_updated",
    "severity": "info"
  },
  {
    "cluster_id": "30bda52c-d558-49be-aaa7-113c2bce23ed",
    "event_time": "2025-11-15T18:30:50.061Z",
    "message": "Cluster starting to prepare for installation",
    "name": "cluster_prepare_installation_started",
    "severity": "info"
  }
]
```

When the installation process is complete, we can see this result:
```shell
$ oc get agent -A
NAMESPACE   NAME                                   CLUSTER     APPROVED   ROLE     STAGE
spoke       1bfd7178-e402-4a00-886d-961d410ae089   spoke-acm   true       master   Done
spoke       2887375f-41b8-453a-b33a-7b8631a87f74   spoke-acm   true       master   Done
spoke       73161c13-ac16-451c-bade-b5b191323ed0   spoke-acm   true       master   Done

$ oc get clusterdeployment -A
NAMESPACE   NAME        INFRAID                                PLATFORM          REGION   VERSION   CLUSTERTYPE   PROVISIONSTATUS   POWERSTATE   AGE
spoke       spoke-acm   30bda52c-d558-49be-aaa7-113c2bce23ed   agent-baremetal            4.20.3                  Provisioned       Running      57m
```

We can extract the kubeconfig from the spoke cluster by extracting the secret:
```shell
$ mkdir ~/labs/acm/spoke-1
$ oc extract -n spoke secret/spoke-acm-admin-kubeconfig --to=~/labs/acm/spoke-1 --confirm
```

## Importing an existing cluster

In our environment we have an active SNO cluster that we can import into our hub cluster.

The steps to follow are the following:
1. Create a namespace with the same name as the cluster we are going to import.
```shell
oc create ns acm-spoke-2
```
2. Create a secret called `auto-import-secret` using the kubeconfig of the cluster to be imported.
```yaml
apiVersion: v1
kind: Secret
metadata:
 name: auto-import-secret
 namespace: acm-spoke-2
stringData:
 autoImportRetry: 10
 kubeconfig: |-
   <acm-spoke-2-kubeconfig>
   ...
type: Opaque
```
3. Apply the `ManagedCluster` manifest.
```shell
oc apply -f managedcluster-acm-spoke-2.yaml
```