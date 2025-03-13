# appliance-pinned lab
In this lab, we create an environment using the appliance tool.
Within this new cluster:
* Enable the Openshift internal registry
* Add a new deployment using an image stored in the Openshift internal registry.
* Add a `PinnedImageSet` containing Openshift images.
* Upgrade the cluster using the `build upgrade-iso` method.

## Requirements
None.

## Steps
1. Create a new appliance image with:
```shell
ap labs/appliance-pinned/deploy.yaml
```
2. Validate

### Enable Openshift internal registry
We need a storage subsystem to store the images. In this lab, we will use **lvms**.
1. Add additional virtio disks to the worker nodes:
```shell
$ oc get nodes
NAME               STATUS   ROLES                  AGE     VERSION
appliance-node-1   Ready    control-plane,master   4h53m   v1.31.6
appliance-node-2   Ready    control-plane,master   5h11m   v1.31.6
appliance-node-3   Ready    worker                 4h54m   v1.31.6
appliance-node-4   Ready    control-plane,master   5h11m   v1.31.6
appliance-node-5   Ready    worker                 4h54m   v1.31.6

$ for i in 3 5; do \
    qemu-img create -f qcow2 "/home/libvirt-ocp/appliance-node-${i}.qcow2" 20G \
    virsh attach-disk "appliance-node-${i}" "/home/libvirt-ocp/appliance-node-${i}.qcow2" vda --driver qemu --subdriver qcow2 --persistent --live \
done
```

### Configure `PinnedImageSets`
1. Enable Technology Preview features:
> This step requires deploying a new configuration to the nodes. This will take some time. Monitor the cluster operators and wait until the cluster is stable again.
```shell
oc apply -f enable-techpreview.yaml
oc adm wait-for-stable-cluster --minimum-stable-period=300s
```
2. Add the images to the `pinned-image-set.yaml` file. They can be obtained with:
```shell
oc adm release info quay.io/openshift-release-dev/ocp-release:4.18.3-x86_64 --output=json \
  | jq "[.references.spec.tags[] | .from.name]" \
  | grep quay | tr -d '",' \
  | awk '{ print "    - name: "$1 }'
```
Besides that we should add the release image to the list:
```shell
oc adm release info quay.io/openshift-release-dev/ocp-release:4.18.3-x86_64 \
  | awk '/Pull From/ { print "    - name: "$3 }'
```
3. Apply the `PinnedImageSet` and wait for the images to download.
```shell
oc apply -f pinned-image-set.yaml
```

## Validation
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
2. Check if the pinned images are present on the nodes:
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

## Links
* [OpenShift Appliance User Guide](https://github.com/openshift/appliance/blob/master/docs/user-guide.md)
* [Appliance Config](https://github.com/openshift/appliance/blob/master/docs/appliance-config.md)
