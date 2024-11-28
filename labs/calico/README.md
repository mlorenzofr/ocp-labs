# calico lab
This lab deploys an Openshift cluster with Calico as SDN.  
The cluster is installed using the **ABI** (agent based installer) method.

## Requirements
None.

## Steps
1. Deploy:
```shell
ap labs/calico/deploy.yaml
```

## Validation
1. Check if the Openshift cluster is running:
```shell
$ export KUBECONFIG=/root/labs/calico/deploy/auth/kubeconfig

$ oc get nodes
NAME            STATUS   ROLES                         AGE   VERSION
calico-node-1   Ready    control-plane,master,worker   11m   v1.29.7+4510e9c
calico-node-2   Ready    control-plane,master,worker   34m   v1.29.7+4510e9c
calico-node-3   Ready    control-plane,master,worker   34m   v1.29.7+4510e9c

$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.16.9    True        False         4m4s    Cluster version is 4.16.9
```
2. Validate in the network configuration if the Network Type is set to Calico:
```shell
$ oc get network.config/cluster -o jsonpath='{.status.networkType}{"\n"}'
Calico
```
3. Get the status of Calico components:
```shell
$ oc get tigerastatuses
NAME        AVAILABLE   PROGRESSING   DEGRADED   SINCE
apiserver   True        False         False      38m
calico      True        False         False      37m
ippools     True        False         False      30m
```

## Links
* [Install an OpenShift 4 cluster with Calico](https://docs.tigera.io/calico/latest/getting-started/kubernetes/openshift/installation)
* [Calico CTL image repository](https://quay.io/repository/calico/ctl)
* [OCP Agent-based Install with extra manifests, Calico](https://cloudcult.dev/ocp-agent-based-install-with-extra-manifests-calico/)
