# Cluster autoscaler
This document explains how to setup a cluster-autoscaler to run on a workload cluster deployed on Nutanix using CAPX.  
We need to use the Kubernetes cluster autoscaler because, due to some conflicts between CAPI and MAPI, the Openshift cluster autoscaler is not working yet.  
In this approach, we will use the autoscaler deployed on the management cluster, but other deployments may also be possible.

## Management Cluster
1. Add these annotations to the `MachineDeployment`:
```shell
$ kubectl annotate machinedeployment capi-ntx-2-wmd capacity.cluster-autoscaler.kubernetes.io/cpu="24"
$ kubectl annotate machinedeployment capi-ntx-2-wmd capacity.cluster-autoscaler.kubernetes.io/ephemeral-disk="120Gi"
$ kubectl annotate machinedeployment capi-ntx-2-wmd capacity.cluster-autoscaler.kubernetes.io/memory="16G"
$ kubectl annotate machinedeployment capi-ntx-2-wmd cluster.x-k8s.io/cluster-api-autoscaler-node-group-min-size="0"
$ kubectl annotate machinedeployment capi-ntx-2-wmd cluster.x-k8s.io/cluster-api-autoscaler-node-group-max-size="3"
```
The first three annotations, the capacity ones, are necessary because we are using a [zero-sized node group](https://cluster-api.sigs.k8s.io/tasks/automated-machine-management/autoscaling#scale-from-zero-support) in our lab.

2. Disable the `ControlPlaneIsStable` preflight check:
```shell
$ ms=$(kubectl get machineset -l "cluster.x-k8s.io/deployment-name=capi-ntx-1-wmd" -o jsonpath='{.items[*].metadata.name}')
$ kubectl annotate machineset/"${ms}" "machineset.cluster.x-k8s.io/skip-preflight-checks=ControlPlaneIsStable"
```
3. Copy the secret with the workload cluster's kubeconfig to the `kube-system` namespace:
```shell
$ kubectl get secret capi-ntx-2-admin-kubeconfig -o yaml | sed 's/namespace: .*/namespace: kube-system/' | kubectl apply -f -
```
4. Install the cluster autoscaler using [this example](../manifest/autoscaler/cluster-autoscaler-deploy.yaml).

## Validation
1. On the workload cluster, apply the [stress-test](../manifest/autoscaler/stress-test.yaml) manifest. This will create a _deployment_ with replica factor of 100, which should be enough to stress the cluster.
```shell
$ kubectl get secret/capi-ntx-2-admin-kubeconfig -o json | jq -r '.data.kubeconfig | @base64d' > /tmp/kubeconfig-capi-ntx-2
$ export KUBECONFIG=/tmp/kubeconfig-capi-ntx-2

$ kubectl apply -f stress-test.yaml
```
2. On the workload cluster, check if you have any replicas in _pending_ status:
```shell
$ kubectl get pods
NAME                          READY   STATUS                   RESTARTS   AGE
stress-test-d8bf88685-2ljt7   0/1     Pending                  0          16m
stress-test-d8bf88685-2mb2l   0/1     Pending                  0          16m
stress-test-d8bf88685-4h5dh   0/1     Pending                  0          16m
stress-test-d8bf88685-5jq5q   1/1     Running                  0          60m
```
If you don't have any, scale up replicas until some pod becomes in _pending_ state due to insufficient resources:
```shell
$ kubectl scale deployment/stress-test --replicas=200

$ kubectl get event --field-selector involvedObject.name=stress-test-d8bf88685-2mb2l -o json | jq -r '.items[] | select(.type == "Warning") | "\(.reason) :: \(.message)"'
FailedScheduling :: 0/3 nodes are available: 3 Insufficient cpu. preemption: 0/3 nodes are available: 3 No preemption victims found for incoming pod.
```
3. On the management cluster, look for a scale-up message in the `cluster-autoscaler` logs and check if the `MachineDeployment` is in **ScalingUp** phase.
```shell
$ kubectl logs cluster-autoscaler-76c76ff5c9-9w2d6 -n kube-system | grep orchestrator
I0218 13:43:35.810409       1 orchestrator.go:582] Scale-up: setting group MachineDeployment/default/capi-ntx-2-wmd size to 1

$ kubectl get machinedeployment
NAMESPACE   NAME                 CLUSTER          REPLICAS   READY   UPDATED   UNAVAILABLE   PHASE       AGE    VERSION
default     capi-ntx-2-wmd       capi-ntx-2                                    1             ScalingUp   144m   v4.17.0
```
4. If the scale-up process has started, we should see a new VM in the Nutanix Prism Console, and after a few minutes the new node should be available on the workload cluster:
```shell
$ kubectl get nodes
NAME                             STATUS   ROLES                         AGE    VERSION
capi-ntx-2-9xgbm                 Ready    control-plane,master,worker   151m   v1.30.4
capi-ntx-2-gwrr7                 Ready    control-plane,master,worker   151m   v1.30.4
capi-ntx-2-s74vw                 Ready    control-plane,master,worker   132m   v1.30.4
capi-ntx-2-wmd-d5c5g-4s4fh       Ready    worker                        5m5s   v1.30.4
```

## Links
* [Using the Cluster Autoscaler](https://cluster-api.sigs.k8s.io/tasks/automated-machine-management/autoscaling)
* [Using Autoscaler in combination with CAPX](https://opendocs.nutanix.com/capx/latest/experimental/autoscaler/)
* [Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler)
* [Managing machines with the Cluster API](https://docs.redhat.com/en/documentation/openshift_container_platform/4.17/html-single/machine_management/index#managing-machines-with-the-cluster-api)
* [Openshift cluster-autoscaler-operator](https://github.com/openshift/cluster-autoscaler-operator)
