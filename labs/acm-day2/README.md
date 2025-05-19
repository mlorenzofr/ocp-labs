# acm-day2 lab
This lab installs a _compact_ Openshift cluster with ACM and a spoke cluster to test day-2 operations.

## Requirements
None.

## Deployment
1. Execute the playbook `deploy.yaml`:
```shell
ap labs/acm-day2/deploy.yaml
```
2. Import the spoke cluster as `ManagedCluster`
3. Save the spoke kubeconfig
```shell
$ export KUBECONFIG=/root/labs/acm-hub-1/deploy/auth/kubeconfig
$ oc get secrets -n managed spoke1-admin-kubeconfig -o yaml > /root/labs/acm-hub-1/config/spoke1-admin-kubeconfig.yaml
```

### Deployment validation
1. Check if the Openshift cluster is running:
```shell
$ export KUBECONFIG=/root/labs/acm-hub-1/deploy/auth/kubeconfig

$ oc get nodes
NAME                 STATUS   ROLES                         AGE    VERSION
acm-hub-1-master-1   Ready    control-plane,master,worker   146m   v1.30.6
acm-hub-1-master-2   Ready    control-plane,master,worker   162m   v1.30.6
acm-hub-1-master-3   Ready    control-plane,master,worker   161m   v1.30.6

$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.17.7    True        False         134m    Cluster version is 4.17.7
```
2. Check if the `MultiClusterHub` resource is present and running:
```shell
$ oc get multiclusterhub -A
NAMESPACE                 NAME              STATUS    AGE   CURRENTVERSION   DESIREDVERSION
open-cluster-management   multiclusterhub   Running   23m   2.13.2           2.13.2
```
3. Check if the _spoke cluster_ is provisioned:
```shell
$ oc get bmh -n managed
NAME              STATE         CONSUMER   ONLINE   ERROR   AGE
acm-hub-1-bmh-1   provisioned              true             16m
acm-hub-1-bmh-2   provisioned              true             16m
acm-hub-1-bmh-3   provisioned              true             16m

$ oc get clusterdeployment -n managed
NAME     INFRAID                                PLATFORM          REGION   VERSION   CLUSTERTYPE   PROVISIONSTATUS   POWERSTATE   AGE
spoke1   73ccf127-e5f0-4135-996f-a8cc176c4d69   agent-baremetal            4.18.6                  Provisioned       Running      48m

$ oc get agentclusterinstall -n managed
NAME     CLUSTER   STATE
spoke1   spoke1    adding-hosts
```
4. Check if the _spoke_ cluster works:
```shell
$ export KUBECONFIG=/root/labs/acm-hub-1/spoke1/auth/kubeconfig

$ oc get nodes
NAME              STATUS   ROLES                         AGE   VERSION
acm-hub-1-bmh-1   Ready    control-plane,master,worker   36m   v1.31.6
acm-hub-1-bmh-2   Ready    control-plane,master,worker   36m   v1.31.6
acm-hub-1-bmh-3   Ready    control-plane,master,worker   20m   v1.31.6

$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.18.6    True        False         8m30s   Cluster version is 4.18.6

$ oc get co
NAME                                       VERSION   AVAILABLE   PROGRESSING   DEGRADED   SINCE   MESSAGE
authentication                             4.18.6    True        False         False      9m13s
baremetal                                  4.18.6    True        False         False      33m
cloud-controller-manager                   4.18.6    True        False         False      36m
cloud-credential                           4.18.6    True        False         False      39m
cluster-autoscaler                         4.18.6    True        False         False      33m
config-operator                            4.18.6    True        False         False      34m
console                                    4.18.6    True        False         False      16m
control-plane-machine-set                  4.18.6    True        False         False      33m
csi-snapshot-controller                    4.18.6    True        False         False      34m
dns                                        4.18.6    True        False         False      33m
etcd                                       4.18.6    True        False         False      32m
image-registry                             4.18.6    True        False         False      18m
ingress                                    4.18.6    True        False         False      21m
insights                                   4.18.6    True        False         False      33m
kube-apiserver                             4.18.6    True        False         False      30m
kube-controller-manager                    4.18.6    True        False         False      30m
kube-scheduler                             4.18.6    True        False         False      30m
kube-storage-version-migrator              4.18.6    True        False         False      33m
machine-api                                4.18.6    True        False         False      29m
machine-approver                           4.18.6    True        False         False      33m
machine-config                             4.18.6    True        False         False      33m
marketplace                                4.18.6    True        False         False      33m
monitoring                                 4.18.6    True        False         False      18m
network                                    4.18.6    True        False         False      34m
node-tuning                                4.18.6    True        False         False      18m
olm                                        4.18.6    True        False         False      18m
openshift-apiserver                        4.18.6    True        False         False      25m
openshift-controller-manager               4.18.6    True        False         False      29m
openshift-samples                          4.18.6    True        False         False      25m
operator-lifecycle-manager                 4.18.6    True        False         False      33m
operator-lifecycle-manager-catalog         4.18.6    True        False         False      33m
operator-lifecycle-manager-packageserver   4.18.6    True        False         False      25m
service-ca                                 4.18.6    True        False         False      34m
storage                                    4.18.6    True        False         False      34m
```
5. Check if the spoke cluster was imported:
```shell
$ oc get managedclusters
NAME            HUB ACCEPTED   MANAGED CLUSTER URLS                   JOINED   AVAILABLE   AGE
local-cluster   true           https://api.acm-hub-1.local.lab:6443   True     True        123m
spoke1          true           https://api.spoke1.local.lab:6443      True     True        64m
```

## day-2 operations
### Adding a node
1. Delete the spoke kubeconfig:
```shell
$ export KUBECONFIG=/root/labs/acm-hub-1/deploy/auth/kubeconfig
$ oc delete secret -n managed spoke1-admin-kubeconfig
```
2. Add a worker node to the spoke cluster:
```shell
ap labs/acm-day2/deploy.yaml --tags add-node
```
3. Check if the `baremetalhost` is present:
```shell
$ oc get bmh -n managed
NAME              STATE         CONSUMER   ONLINE   ERROR   AGE
acm-hub-1-bmh-1   provisioned              true             120m
acm-hub-1-bmh-2   provisioned              true             120m
acm-hub-1-bmh-3   provisioned              true             120m
acm-hub-1-bmh-4   provisioned              true             3m20s
```
4. Review if the agent is registered:
```shell
$ oc get agent -n managed
NAME                                   CLUSTER   APPROVED   ROLE     STAGE
2c630662-abf7-43ac-ab2a-f177652d8571   spoke1    true       master   Done
3ad19ad1-6000-4551-acd9-f4ac039d5791   spoke1    true       master   Done
93ec059f-c590-4e82-887d-4c33cd1f297d   spoke1    true       master   Done
c56e9dae-e464-4b56-99ea-4715c24116f7   spoke1    true       worker   Waiting for control plane
```
5. Since the _kubeconfig_ no longer exists, to complete the installation we must manually approve CSR requests on the spoke cluster.
```shell
$ export KUBECONFIG=/root/labs/acm-hub-1/spoke1/auth/kubeconfig

$ oc get csr -o go-template='{{range .items}}{{if not .status}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}' | xargs --no-run-if-empty oc adm certificate approve
```
6. Check the nodes in the spoke cluster:
```shell
$ export KUBECONFIG=/root/labs/acm-hub-1/spoke1/auth/kubeconfig

$ oc get nodes
NAME              STATUS   ROLES                         AGE     VERSION
NAME              STATUS   ROLES                         AGE   VERSION
acm-hub-1-bmh-1   Ready    control-plane,master,worker   15h   v1.31.6
acm-hub-1-bmh-2   Ready    control-plane,master,worker   15h   v1.31.6
acm-hub-1-bmh-3   Ready    control-plane,master,worker   14h   v1.31.6
acm-hub-1-bmh-4   Ready    worker                        12h   v1.31.6
```
7. The installation was not completed on the hub cluster, but the worker is available and the (spoke) scheduler started pods on it:
```shell
$ oc get pods -A -o wide | grep acm-hub-1-bmh-4
openshift-cluster-node-tuning-operator             tuned-qfsmj                                                  1/1     Running     0              12h     192.168.125.77   acm-hub-1-bmh-4   <none>           <none>
openshift-dns                                      dns-default-vjf9m                                            2/2     Running     0              12h     10.131.0.6       acm-hub-1-bmh-4   <none>           <none>
openshift-dns                                      node-resolver-g4bzd                                          1/1     Running     0              12h     192.168.125.77   acm-hub-1-bmh-4   <none>           <none>
openshift-image-registry                           image-pruner-29100960-22wfj                                  0/1     Completed   0              9h      10.131.0.19      acm-hub-1-bmh-4   <none>           <none>
openshift-image-registry                           node-ca-8w66f                                                1/1     Running     0              12h     192.168.125.77   acm-hub-1-bmh-4   <none>           <none>
openshift-ingress-canary                           ingress-canary-5fpps                                         1/1     Running     0              12h     10.131.0.5       acm-hub-1-bmh-4   <none>           <none>
openshift-kni-infra                                coredns-acm-hub-1-bmh-4                                      2/2     Running     0              12h     192.168.125.77   acm-hub-1-bmh-4   <none>           <none>
openshift-kni-infra                                keepalived-acm-hub-1-bmh-4                                   2/2     Running     0              12h     192.168.125.77   acm-hub-1-bmh-4   <none>           <none>
openshift-machine-config-operator                  kube-rbac-proxy-crio-acm-hub-1-bmh-4                         1/1     Running     14 (12h ago)   12h     192.168.125.77   acm-hub-1-bmh-4   <none>           <none>
openshift-machine-config-operator                  machine-config-daemon-56rw8                                  2/2     Running     0              12h     192.168.125.77   acm-hub-1-bmh-4   <none>           <none>
openshift-monitoring                               node-exporter-2t29n                                          2/2     Running     0              12h     192.168.125.77   acm-hub-1-bmh-4   <none>           <none>
openshift-multus                                   multus-additional-cni-plugins-nf4th                          1/1     Running     0              12h     192.168.125.77   acm-hub-1-bmh-4   <none>           <none>
openshift-multus                                   multus-k99n9                                                 1/1     Running     0              12h     192.168.125.77   acm-hub-1-bmh-4   <none>           <none>
openshift-multus                                   network-metrics-daemon-s4wcf                                 2/2     Running     0              12h     10.131.0.3       acm-hub-1-bmh-4   <none>           <none>
openshift-network-diagnostics                      network-check-target-mft7v                                   1/1     Running     0              12h     10.131.0.4       acm-hub-1-bmh-4   <none>           <none>
openshift-network-operator                         iptables-alerter-4952f                                       1/1     Running     0              12h     192.168.125.77   acm-hub-1-bmh-4   <none>           <none>
openshift-operator-lifecycle-manager               collect-profiles-29101485-gnfsl                              0/1     Completed   0              39m     10.131.0.55      acm-hub-1-bmh-4   <none>           <none>
openshift-operator-lifecycle-manager               collect-profiles-29101500-b424g                              0/1     Completed   0              24m     10.131.0.56      acm-hub-1-bmh-4   <none>           <none>
openshift-operator-lifecycle-manager               collect-profiles-29101515-z52d7                              0/1     Completed   0              9m16s   10.131.0.57      acm-hub-1-bmh-4   <none>           <none>
openshift-ovn-kubernetes                           ovnkube-node-pfrzq                                           8/8     Running     0              12h     192.168.125.77   acm-hub-1-bmh-4   <none>           <none>
```
8. Check the progress of teh installation on the hub cluster. We can see that it's stuck at 44%.
```shell
$ oc get agent -n managed c56e9dae-e464-4b56-99ea-4715c24116f7 -o json | jq '.status.progress'
{
  "currentStage": "Waiting for control plane",
  "installationPercentage": 44,
}
```
9. Add the kubeconfig secret again:
```shell
$ oc apply -f labs/acm-hub-1/config/spoke1-admin-kubeconfig.yaml
```
10. The installation will now continue and be marked as _done_.
```shell
$ oc get agent -n managed c56e9dae-e464-4b56-99ea-4715c24116f7 -o json | jq '.status.progress'
{
  "currentStage": "Done",
  "installationPercentage": 100,
}
```

### Removing a node
1. Remove the kubeconfig secret:
```shell
$ oc delete secret -n managed spoke1-admin-kubeconfig
```

To delete the node, we must delete the `baremetalhost` and `agent` objects. The triggers for deleting the node in the spoke cluster are managed by the `agent` resource.

#### Remove the agent
2. Delete the `agent` resource associated with the worker node:
```shell
$ oc get agent -n managed
NAME                                   CLUSTER   APPROVED   ROLE     STAGE
2c630662-abf7-43ac-ab2a-f177652d8571   spoke1    true       master   Done
3ad19ad1-6000-4551-acd9-f4ac039d5791   spoke1    true       master   Done
93ec059f-c590-4e82-887d-4c33cd1f297d   spoke1    true       master   Done
e46fa692-c0f0-46cb-9d8e-8ebbab8b52f5   spoke1    true       worker   Done

$ oc delete agent e46fa692-c0f0-46cb-9d8e-8ebbab8b52f5 -n managed

$ export KUBECONFIG=/root/labs/acm-hub-1/spoke1/auth/kubeconfig
$ oc get nodes
NAME              STATUS   ROLES                         AGE   VERSION
acm-hub-1-bmh-1   Ready    control-plane,master,worker   38h   v1.31.6
acm-hub-1-bmh-2   Ready    control-plane,master,worker   38h   v1.31.6
acm-hub-1-bmh-3   Ready    control-plane,master,worker   38h   v1.31.6
acm-hub-1-bmh-4   Ready    worker                        21h   v1.31.6
```
The delete will remain stuck in the finalizer because the _kubeconfig_ doesn't exist.  
The worker node is not removed from the spoke cluster at this point, it remains running.
Let's recover the _kubeconfig_.
```shell
$ oc apply -f labs/acm-hub-1/config/spoke1-admin-kubeconfig.yaml
```
Now, the `agent` finalizer can continue and  will remove the worker node:
```shell
$ export KUBECONFIG=/root/labs/acm-hub-1/spoke1/auth/kubeconfig
$ oc get nodes
NAME              STATUS   ROLES                         AGE   VERSION
acm-hub-1-bmh-1   Ready    control-plane,master,worker   38h   v1.31.6
acm-hub-1-bmh-2   Ready    control-plane,master,worker   38h   v1.31.6
acm-hub-1-bmh-3   Ready    control-plane,master,worker   38h   v1.31.6
```

#### Remove the baremetalhost

2. Delete the worker node attached on the spoke cluster
```shell
$ oc delete bmh -n managed acm-hub-1-bmh-4
$ oc get bmh -n managed
NAME              STATE         CONSUMER   ONLINE   ERROR   AGE
acm-hub-1-bmh-1   provisioned              true             15h
acm-hub-1-bmh-2   provisioned              true             15h
acm-hub-1-bmh-3   provisioned              true             15h
```
3. The node remains on the spoke cluster, the BMO doesn't shutdown the VM:
```shell
$ oc get nodes
NAME              STATUS   ROLES                         AGE   VERSION
acm-hub-1-bmh-1   Ready    control-plane,master,worker   15h   v1.31.6
acm-hub-1-bmh-2   Ready    control-plane,master,worker   15h   v1.31.6
acm-hub-1-bmh-3   Ready    control-plane,master,worker   15h   v1.31.6
acm-hub-1-bmh-4   Ready    worker                        12h   v1.31.6
```
4. BMO logs:
```shell
{"level":"info","ts":1746090001.2240667,"logger":"controllers.BareMetalHost","msg":"Initiating host deletion","baremetalhost":{"name":"acm-hub-1-bmh-4","namespace":"managed"},"provisioningState":"provisioned"}
{"level":"info","ts":1746090001.2241015,"logger":"controllers.BareMetalHost","msg":"changing provisioning state","baremetalhost":{"name":"acm-hub-1-bmh-4","namespace":"managed"},"provisioningState":"provisioned","old":"provisioned","new":"deleting"}
{"level":"info","ts":1746090001.224133,"logger":"controllers.BareMetalHost","msg":"saving host status","baremetalhost":{"name":"acm-hub-1-bmh-4","namespace":"managed"},"provisioningState":"provisioned","operational status":"detached","provisioning state":"deleting"}
{"level":"info","ts":1746090001.238658,"logger":"controllers.BMCEventSubscription","msg":"start","bmceventsubscription":{"name":"acm-hub-1-bmh-4","namespace":"managed"}}
{"level":"info","ts":1746090001.2387044,"logger":"controllers.BMCEventSubscription","msg":"done","bmceventsubscription":{"name":"acm-hub-1-bmh-4","namespace":"managed"}}
{"level":"info","ts":1746090001.2417269,"logger":"controllers.BareMetalHost","msg":"done","baremetalhost":{"name":"acm-hub-1-bmh-4","namespace":"managed"},"provisioningState":"provisioned","requeue":true,"after":0}
{"level":"info","ts":1746090001.241841,"logger":"controllers.BareMetalHost","msg":"start","baremetalhost":{"name":"acm-hub-1-bmh-4","namespace":"managed"}}
{"level":"info","ts":1746090001.241894,"logger":"controllers.BareMetalHost","msg":"hardwareData is ready to be deleted","baremetalhost":{"name":"acm-hub-1-bmh-4","namespace":"managed"}}
{"level":"info","ts":1746090001.2701404,"logger":"controllers.BareMetalHost","msg":"removed detached status","baremetalhost":{"name":"acm-hub-1-bmh-4","namespace":"managed"},"provisioningState":"deleting"}
{"level":"info","ts":1746090001.2701764,"logger":"controllers.BareMetalHost","msg":"saving host status","baremetalhost":{"name":"acm-hub-1-bmh-4","namespace":"managed"},"provisioningState":"deleting","operational status":"OK","provisioning state":"deleting"}
{"level":"info","ts":1746090001.2862873,"logger":"controllers.BareMetalHost","msg":"done","baremetalhost":{"name":"acm-hub-1-bmh-4","namespace":"managed"},"provisioningState":"deleting","requeue":true,"after":0}
{"level":"info","ts":1746090001.2863913,"logger":"controllers.BareMetalHost","msg":"start","baremetalhost":{"name":"acm-hub-1-bmh-4","namespace":"managed"}}
{"level":"info","ts":1746090001.2863078,"logger":"controllers.BMCEventSubscription","msg":"start","bmceventsubscription":{"name":"acm-hub-1-bmh-4","namespace":"managed"}}
{"level":"info","ts":1746090001.2865014,"logger":"controllers.BMCEventSubscription","msg":"done","bmceventsubscription":{"name":"acm-hub-1-bmh-4","namespace":"managed"}}
{"level":"info","ts":1746090001.286457,"logger":"controllers.BareMetalHost","msg":"hardwareData is ready to be deleted","baremetalhost":{"name":"acm-hub-1-bmh-4","namespace":"managed"}}
{"level":"info","ts":1746090001.3097646,"logger":"controllers.BareMetalHost","msg":"marked to be deleted","baremetalhost":{"name":"acm-hub-1-bmh-4","namespace":"managed"},"provisioningState":"deleting","timestamp":"2025-05-01 09:00:01 +0000 UTC"}
{"level":"info","ts":1746090001.322605,"logger":"provisioner.ironic","msg":"no node found, already deleted","host":"managed~acm-hub-1-bmh-4"}
{"level":"info","ts":1746090001.3292828,"logger":"controllers.BareMetalHost.secret_manager","msg":"removed secret finalizer","baremetalhost":{"name":"acm-hub-1-bmh-4","namespace":"managed"},"provisioningState":"deleting","remaining":[]}
{"level":"info","ts":1746090001.3293207,"logger":"controllers.BareMetalHost","msg":"cleanup is complete, removed finalizer","baremetalhost":{"name":"acm-hub-1-bmh-4","namespace":"managed"},"provisioningState":"deleting","remaining":[]}
{"level":"info","ts":1746090001.3411353,"logger":"webhooks.BareMetalHost","msg":"validate update","namespace":"managed","name":"acm-hub-1-bmh-4"}
{"level":"info","ts":1746090001.3535266,"logger":"controllers.BareMetalHost","msg":"done","baremetalhost":{"name":"acm-hub-1-bmh-4","namespace":"managed"},"provisioningState":"deleting","requeue":false,"after":0}
{"level":"info","ts":1746090001.353765,"logger":"controllers.BareMetalHost","msg":"start","baremetalhost":{"name":"acm-hub-1-bmh-4","namespace":"managed"}}
{"level":"info","ts":1746090001.3544724,"logger":"controllers.BareMetalHost","msg":"start","baremetalhost":{"name":"acm-hub-1-bmh-4","namespace":"managed"}}
{"level":"info","ts":1746090001.3538072,"logger":"controllers.BMCEventSubscription","msg":"start","bmceventsubscription":{"name":"acm-hub-1-bmh-4","namespace":"managed"}}
{"level":"info","ts":1746090001.3545783,"logger":"controllers.BMCEventSubscription","msg":"done","bmceventsubscription":{"name":"acm-hub-1-bmh-4","namespace":"managed"}}
{"level":"info","ts":1746090001.3880656,"logger":"controllers.BareMetalHost","msg":"start","baremetalhost":{"name":"acm-hub-1-bmh-4","namespace":"managed"}}
{"level":"info","ts":1746090001.388636,"logger":"controllers.HostFirmwareComponents","msg":"start","hostfirmwarecomponents":{"name":"acm-hub-1-bmh-4","namespace":"managed"}}
{"level":"info","ts":1746090001.3898287,"logger":"controllers.HostFirmwareSettings","msg":"start","hostfirmwaresettings":{"name":"acm-hub-1-bmh-4","namespace":"managed"}}
{"level":"info","ts":1746090001.3899698,"logger":"controllers.HostFirmwareSettings","msg":"could not get baremetalhost, not running reconciler","hostfirmwaresettings":{"name":"acm-hub-1-bmh-4","namespace":"managed"}}
{"level":"info","ts":1746090001.390441,"logger":"controllers.BareMetalHost","msg":"start","baremetalhost":{"name":"acm-hub-1-bmh-4","namespace":"managed"}}
{"level":"info","ts":1746090335.462247,"logger":"controllers.HostFirmwareComponents","msg":"start","hostfirmwarecomponents":{"name":"acm-hub-1-bmh-4","namespace":"managed"}}
{"level":"info","ts":1746090335.6320572,"logger":"controllers.HostFirmwareSettings","msg":"start","hostfirmwaresettings":{"name":"acm-hub-1-bmh-4","namespace":"managed"}}
{"level":"info","ts":1746090335.632106,"logger":"controllers.HostFirmwareSettings","msg":"could not get baremetalhost, not running reconciler","hostfirmwaresettings":{"name":"acm-hub-1-bmh-4","namespace":"managed"}}
```
5. There are no changes on the spoke cluster, but the BMH doesn't exist on the hub cluster. Inconsistent state.
```shell
[root@rdu-infra-edge-09 ~]# oc get managedclusters -o wide
NAME            HUB ACCEPTED   MANAGED CLUSTER URLS                   JOINED   AVAILABLE   AGE
local-cluster   true           https://api.acm-hub-1.local.lab:6443   True     True        16h
spoke1          true           https://api.spoke1.local.lab:6443      True     True        15h
```
6. Add the kubeconfig secret again:
```shell
$ oc apply -f labs/acm-hub-1/config/spoke1-admin-kubeconfig.yaml
```
7. Recreate the `bmh`. We can see that the worker node reboots, but there are no other issues:
```shell
$ oc debug node/acm-hub-1-bmh-4
Starting pod/acm-hub-1-bmh-4-debug-9hbwx ...
To use host binaries, run `chroot /host`
Pod IP: 192.168.125.77
If you don't see a command prompt, try pressing enter.
sh-5.1# chroot /host
sh-5.1# uptime
 09:36:50 up 4 min,  0 users,  load average: 0.40, 0.29, 0.13
```
8. Delete `bmh` and `agent` on the hub cluster will cause the node to disappear on the spoke cluster:
```shell
$ oc delete bmh -n managed acm-hub-1-bmh-4
$ oc delete agent -n managed c56e9dae-e464-4b56-99ea-4715c24116f7

$ export KUBECONFIG=/root/labs/acm-hub-1/spoke1/auth/kubeconfig
$ oc get nodes
NAME              STATUS   ROLES                         AGE   VERSION
acm-hub-1-bmh-1   Ready    control-plane,master,worker   15h   v1.31.6
acm-hub-1-bmh-2   Ready    control-plane,master,worker   15h   v1.31.6
acm-hub-1-bmh-3   Ready    control-plane,master,worker   15h   v1.31.6
```
9. Add the node again. It has now joined the cluster, but the agent has not been created on the hub cluster:
```shell
$ oc get bmh -n managed
NAME              STATE         CONSUMER   ONLINE   ERROR   AGE
acm-hub-1-bmh-1   provisioned              true             16h
acm-hub-1-bmh-2   provisioned              true             16h
acm-hub-1-bmh-3   provisioned              true             16h
acm-hub-1-bmh-4   provisioned              true             88s
$ oc get agent -n managed
NAME                                   CLUSTER   APPROVED   ROLE     STAGE
2c630662-abf7-43ac-ab2a-f177652d8571   spoke1    true       master   Done
3ad19ad1-6000-4551-acd9-f4ac039d5791   spoke1    true       master   Done
93ec059f-c590-4e82-887d-4c33cd1f297d   spoke1    true       master   Done

$ export KUBECONFIG=/root/labs/acm-hub-1/spoke1/auth/kubeconfig
$ oc get nodes
NAME              STATUS   ROLES                         AGE     VERSION
acm-hub-1-bmh-1   Ready    control-plane,master,worker   16h     v1.31.6
acm-hub-1-bmh-2   Ready    control-plane,master,worker   16h     v1.31.6
acm-hub-1-bmh-3   Ready    control-plane,master,worker   15h     v1.31.6
acm-hub-1-bmh-4   Ready    worker                        2m14s   v1.31.6
$ oc get pods -A -o wide | grep acm-hub-1-bmh-4
openshift-cluster-node-tuning-operator             tuned-znqcp                                                  1/1     Running     0             2m20s   192.168.125.77   acm-hub-1-bmh-4   <none>           <none>
openshift-dns                                      dns-default-4dzpn                                            2/2     Running     0             2m20s   10.128.2.3       acm-hub-1-bmh-4   <none>           <none>
openshift-dns                                      node-resolver-wx6hc                                          1/1     Running     0             2m20s   192.168.125.77   acm-hub-1-bmh-4   <none>           <none>
openshift-image-registry                           node-ca-gclr8                                                1/1     Running     0             2m20s   192.168.125.77   acm-hub-1-bmh-4   <none>           <none>
openshift-ingress-canary                           ingress-canary-tp7cj                                         1/1     Running     0             2m20s   10.128.2.4       acm-hub-1-bmh-4   <none>           <none>
openshift-kni-infra                                coredns-acm-hub-1-bmh-4                                      2/2     Running     4             2m20s   192.168.125.77   acm-hub-1-bmh-4   <none>           <none>
openshift-kni-infra                                keepalived-acm-hub-1-bmh-4                                   2/2     Running     4             2m20s   192.168.125.77   acm-hub-1-bmh-4   <none>           <none>
openshift-machine-config-operator                  kube-rbac-proxy-crio-acm-hub-1-bmh-4                         1/1     Running     16            2m20s   192.168.125.77   acm-hub-1-bmh-4   <none>           <none>
openshift-machine-config-operator                  machine-config-daemon-rvfnf                                  2/2     Running     0             2m20s   192.168.125.77   acm-hub-1-bmh-4   <none>           <none>
openshift-monitoring                               node-exporter-964tp                                          2/2     Running     0             2m20s   192.168.125.77   acm-hub-1-bmh-4   <none>           <none>
openshift-multus                                   multus-additional-cni-plugins-mtwtt                          1/1     Running     0             2m20s   192.168.125.77   acm-hub-1-bmh-4   <none>           <none>
openshift-multus                                   multus-fwnfz                                                 1/1     Running     0             2m20s   192.168.125.77   acm-hub-1-bmh-4   <none>           <none>
openshift-multus                                   network-metrics-daemon-bsrk7                                 2/2     Running     0             2m20s   10.128.2.5       acm-hub-1-bmh-4   <none>           <none>
openshift-network-diagnostics                      network-check-target-bp999                                   1/1     Running     0             2m20s   10.128.2.6       acm-hub-1-bmh-4   <none>           <none>
openshift-network-operator                         iptables-alerter-rd8zp                                       1/1     Running     0             2m19s   192.168.125.77   acm-hub-1-bmh-4   <none>           <none>
openshift-ovn-kubernetes                           ovnkube-node-pg48h                                           8/8     Running     0             2m20s   192.168.125.77   acm-hub-1-bmh-4   <none>           <none>
```
10. Delete the kubeconfig secret
```shell
$ oc delete secret -n managed spoke1-admin-kubeconfig
```
11. The BMO shuts down the VM, but the node is still present on the spoke cluster:
```shell
$ oc get bmh -n managed
NAME              STATE         CONSUMER   ONLINE   ERROR   AGE
acm-hub-1-bmh-1   provisioned              true             16h
acm-hub-1-bmh-2   provisioned              true             16h
acm-hub-1-bmh-3   provisioned              true             16h

$ export KUBECONFIG=/root/labs/acm-hub-1/spoke1/auth/kubeconfig
$ oc get nodes
NAME              STATUS     ROLES                         AGE    VERSION
acm-hub-1-bmh-1   Ready      control-plane,master,worker   16h    v1.31.6
acm-hub-1-bmh-2   Ready      control-plane,master,worker   16h    v1.31.6
acm-hub-1-bmh-3   Ready      control-plane,master,worker   15h    v1.31.6
acm-hub-1-bmh-4   NotReady   worker                        8m8s   v1.31.6
```
12. Recovering the kubeconfig doesn't solve the problem.
13. We can add the `bmh` again and this will recover the node:
```shell
$ oc get bmh -n managed
NAME              STATE         CONSUMER   ONLINE   ERROR   AGE
acm-hub-1-bmh-1   provisioned              true             16h
acm-hub-1-bmh-2   provisioned              true             16h
acm-hub-1-bmh-3   provisioned              true             16h
acm-hub-1-bmh-4   provisioned              true             7m25s

$ oc get nodes
NAME              STATUS   ROLES                         AGE    VERSION
acm-hub-1-bmh-1   Ready    control-plane,master,worker   16h    v1.31.6
acm-hub-1-bmh-2   Ready    control-plane,master,worker   16h    v1.31.6
acm-hub-1-bmh-3   Ready    control-plane,master,worker   15h    v1.31.6
acm-hub-1-bmh-4   Ready    worker                        23m    v1.31.6
```


## Links
