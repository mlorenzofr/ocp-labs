# appliance-pinned lab
In this lab, we create an environment using the appliance tool.

The environment consists of 5 nodes (3 Control plane nodes, 2 worker nodes).  
Each node has an appliance disk (`sda`) attached and the _agent-config_ disk as a USB drive (`sdb`).  
The worker machines have an additional disk (`vda`) used to provide storage for the Openshift image registry using the **lvms** operator.  
Upon completion of step #1, we will have an environment with the appliance and Openshift Image registry ready.

In this new cluster, we will:
* Add a new deployment using the images stored in the Openshift image registry.
* Add a `PinnedImageSet` containing Openshift release images.
* Upgrade the cluster using the `build upgrade-iso` method.

## Requirements
To simulate a disconnected environment, we should block all outgoing traffic on the libvirt network where the VMs have their NICs attached.
```shell
iptables -I LIBVIRT_FWO 1 -s 192.168.127.0/24 ! -d 192.168.127.0/24 -j REJECT
```

## Steps
1. Deploy the appliance installation and environment configuration with:
```shell
ap labs/appliance-pinned/deploy.yaml --tags ocp,day2
```
2. Validate the installation
3. Log in to the cluster and registry:
```shell
$ oc login -u kubeadmin --insecure-skip-tls-verify=true -p 'xxxxx-xxxxx-xxxxx-xxxxx' https://api.appliance.lab:6443
$ podman login -u kubeadmin -p $(oc whoami -t) --tls-verify=false default-route-openshift-image-registry.apps.appliance.lab
```
4. Now, we can push the images used in our test deployment to the registry:
```shell
$ podman images | grep -E 'nginx|stress'
docker.io/library/nginx                                           latest          b52e0b094bc0  5 weeks ago    196 MB
docker.io/polinux/stress                                          latest          df58d15b053d  5 years ago    12 MB

$ podman tag b52e0b094bc0 default-route-openshift-image-registry.apps.appliance.lab/workload/nginx
$ podman push --tls-verify=false default-route-openshift-image-registry.apps.appliance.lab/workload/nginx

$ podman tag df58d15b053d default-route-openshift-image-registry.apps.appliance.lab/workload/stress
$ podman push --tls-verify=false default-route-openshift-image-registry.apps.appliance.lab/workload/stress
```
5. Deploy the dummy _workload_:
```shell
ap labs/appliance-pinned/deploy.yaml --tags workload
```

### Configure `PinnedImageSets`
1. Enable Technology Preview features:
> This step requires deploying a new configuration to the nodes. This will take some time. Monitor the cluster operators and wait until the cluster is stable again.
```shell
oc apply -f enable-techpreview.yaml
oc adm wait-for-stable-cluster --minimum-stable-period=300s
```
2. Apply the `PinnedImageSet` and wait for the images to download.
```shell
oc apply -f pinned-image-set.yaml
```

## Validation

### Installation
1. Check if the cluster is running:
```shell
$ export KUBECONFIG=/home/ocp-labs/appliance/deploy/auth/kubeconfig

$ oc get nodes
NAME               STATUS   ROLES                  AGE   VERSION
appliance-node-1   Ready    control-plane,master   27m   v1.31.6
appliance-node-2   Ready    control-plane,master   42m   v1.31.6
appliance-node-3   Ready    control-plane,master   42m   v1.31.6
appliance-node-4   Ready    worker                 27m   v1.31.6
appliance-node-5   Ready    worker                 27m   v1.31.6

$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.18.2    True        False         17m     Cluster version is 4.18.2
```
2. Check if the PVC required for the `openshift-image-registry` is bound:
```shell
$ oc get pvc -n openshift-image-registry
NAME                     STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
image-registry-storage   Bound    pvc-d211049b-d6c2-4fa8-93ed-628d195d8312   15Gi       RWO            lvms-vg1       <unset>                 15m
```
3. Check if in the namespace `openshift-image-registry` the pod **image-registry** is _Running_:
```shell
$ oc get pods -n openshift-image-registry
NAME                                               READY   STATUS    RESTARTS      AGE
cluster-image-registry-operator-7648b6bb9b-brqwz   1/1     Running   1 (16m ago)   27m
image-registry-5897b5b49d-clbhq                    1/1     Running   0             89s
node-ca-5lclf                                      1/1     Running   0             12m
node-ca-dgq27                                      1/1     Running   0             12m
node-ca-fs9zs                                      1/1     Running   0             12m
node-ca-stb2x                                      1/1     Running   0             12m
node-ca-wzgtb                                      1/1     Running   0             12m
```

### workload
1. Review if the `ImageStreams` used by the deployment exist:
```shell
$ oc get imagestream -n workload
NAME     IMAGE REPOSITORY                                                            TAGS     UPDATED
nginx    default-route-openshift-image-registry.apps.appliance.lab/workload/nginx    latest   19 minutes ago
stress   default-route-openshift-image-registry.apps.appliance.lab/workload/stress   latest   38 seconds ago
```
2. Check if the _workload_ pods are **running**:
```shell
$ oc get pods -n workload
NAME                                   READY   STATUS    RESTARTS   AGE
workload-deployment-68fcdd56df-4tcbc   2/2     Running   0          5m46s
workload-deployment-68fcdd56df-wngvm   2/2     Running   0          7m31s
workload-deployment-68fcdd56df-wntbr   2/2     Running   0          6m31s
workload-deployment-68fcdd56df-xlnfp   2/2     Running   0          7m31s
```

### PinnedImageSet
1. Check if the pinned images are present on the nodes:
```shell
$ for i in {1..5}; do scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no /home/ocp-labs/appliance/pinned-images.sh core@appliance-node-${i}:/tmp/; done

$ for i in {1..5}; do ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no core@appliance-node-${i} "sudo /tmp/pinned-images.sh 4.18.3-x86_64" | wc -l; done
Warning: Permanently added 'appliance-node-1,192.168.127.11' (ECDSA) to the list of known hosts.
0
Warning: Permanently added 'appliance-node-2,192.168.127.12' (ECDSA) to the list of known hosts.
0
Warning: Permanently added 'appliance-node-3,192.168.127.13' (ECDSA) to the list of known hosts.
0
Warning: Permanently added 'appliance-node-4,192.168.127.14' (ECDSA) to the list of known hosts.
0
Warning: Permanently added 'appliance-node-5,192.168.127.15' (ECDSA) to the list of known hosts.
0
```
2. Power off all cluster nodes. Switch them on, wait a few minutes and check the pods in the **workload** namespace. They should have restarts, but be in _running_ state:
```shell
$ oc get pods -n workload
NAME                                   READY   STATUS    RESTARTS   AGE
workload-deployment-5449f7588f-6nnb8   2/2     Running   2          19m
workload-deployment-5449f7588f-8zb4l   2/2     Running   2          21m
workload-deployment-5449f7588f-k6mgw   2/2     Running   2          21m
workload-deployment-5449f7588f-szxxb   2/2     Running   2          19m
```

## Links
* [OpenShift Appliance User Guide](https://github.com/openshift/appliance/blob/master/docs/user-guide.md)
* [Appliance Config](https://github.com/openshift/appliance/blob/master/docs/appliance-config.md)
