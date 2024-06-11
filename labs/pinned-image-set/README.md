# pinned-image-set lab

## Requirements
This lab uses its own network. Create it with:
```shell
kcli create network -c 192.168.129.0/24 -P dhcp=false -P dns=false --domain local.lab pinnedis-net
```
A local registry has been configured on a different host.
The configuration of this additional server is explained [here](docs/registry-server.md).

## Steps
1. Execute the playbook `deploy.yaml`:
```shell
ap labs/pinned-image-set/deploy.yaml
```
2. Mirror the CI registry. It is explained [here](docs/oc-mirror.md)
3. Disable default operators to avoid noise in the tests. We are not using here.
```shell
oc patch OperatorHub cluster --type json -p '[{"op": "add", "path": "/spec/disableAllDefaultSources", "value": true}]'
```
4. Add the certificate of the internal registry as trusted source:
```shell
oc apply -f registry-ca-configmap.yaml
oc patch images.config/cluster --type=merge --patch='{"spec":{"additionalTrustedCA":{"name":"registry-ca"}}}'
```
5. Change the upstream and channel to use nightly releases:
```shell
oc patch clusterversion/version --patch '{"spec":{"upstream":"https://amd64.ocp.releases.ci.openshift.org/graph"}}' --type=merge
oc patch clusterversion/version --patch '{"spec":{"channel":"nightly"}}' --type merge
```
6. Enable Technology Preview features:
```shell
oc apply -f enable-techpreview.yaml
```
7. Set the registries configuration to use the internal registry:
```shell
oc apply -f imageContentSourcePolicy.yaml
```
8. Block Internet access from the lab network. This way we can be sure that only internal registry is used.
```shell
iptables -I LIBVIRT_FWO 1 -s 192.168.129.0/24 ! -d 192.168.129.0/24 -j REJECT
```
9. Apply the `PinnedImageSet`.
```shell
oc apply -f pinned-image-set.yaml
```
10. Stop the internal registry <------ The upgrade is not possible without registry
```shell
pinnedis-registry:~# podman stop registry
```
11. Disable tech-preview for the upgrade
```shell
oc edit featuregate cluster
```
12. For the cluster upgrade:
```shell
oc adm upgrade --to-image=pinnedis-registry.pinnedis.local.lab/openshift/release-images@sha256:1995202f11dc5a4763cdc44ff30d4d4d6560b3a6e29873b51af2992bd8e33109 --force --allow-not-recommended=true --allow-explicit-upgrade
```

## Validation
1. Check if the Openshift cluster is running:
```shell
$ export KUBECONFIG=/root/labs/pinnedis/deploy/auth/kubeconfig

$ oc get nodes
NAME              STATUS   ROLES                         AGE     VERSION
pinnedis-node-1   Ready    control-plane,master,worker   7m13s   v1.29.5+87992f4
pinnedis-node-2   Ready    control-plane,master,worker   20m     v1.29.5+87992f4
pinnedis-node-3   Ready    control-plane,master,worker   20m     v1.29.5+87992f4

$ oc get clusterversion
NAME      VERSION                              AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.16.0-0.nightly-2024-06-06-064349   True        False         41s     Cluster version is 4.16.0-0.nightly-2024-06-06-064349

$ oc get co
NAME                                       VERSION                              AVAILABLE   PROGRESSING   DEGRADED   SINCE   MESSAGE
authentication                             4.16.0-0.nightly-2024-06-06-064349   True        False         False      8m16s
baremetal                                  4.16.0-0.nightly-2024-06-06-064349   True        False         False      29m
cloud-controller-manager                   4.16.0-0.nightly-2024-06-06-064349   True        False         False      31m
cloud-credential                           4.16.0-0.nightly-2024-06-06-064349   True        False         False      32m
cluster-autoscaler                         4.16.0-0.nightly-2024-06-06-064349   True        False         False      29m
config-operator                            4.16.0-0.nightly-2024-06-06-064349   True        False         False      30m
console                                    4.16.0-0.nightly-2024-06-06-064349   True        False         False      14m
control-plane-machine-set                  4.16.0-0.nightly-2024-06-06-064349   True        False         False      29m
csi-snapshot-controller                    4.16.0-0.nightly-2024-06-06-064349   True        False         False      30m
dns                                        4.16.0-0.nightly-2024-06-06-064349   True        False         False      29m
etcd                                       4.16.0-0.nightly-2024-06-06-064349   True        False         False      28m
image-registry                             4.16.0-0.nightly-2024-06-06-064349   True        False         False      16m
ingress                                    4.16.0-0.nightly-2024-06-06-064349   True        False         False      22m
insights                                   4.16.0-0.nightly-2024-06-06-064349   True        False         False      23m
kube-apiserver                             4.16.0-0.nightly-2024-06-06-064349   True        False         False      26m
kube-controller-manager                    4.16.0-0.nightly-2024-06-06-064349   True        False         False      27m
kube-scheduler                             4.16.0-0.nightly-2024-06-06-064349   True        False         False      26m
kube-storage-version-migrator              4.16.0-0.nightly-2024-06-06-064349   True        False         False      30m
machine-api                                4.16.0-0.nightly-2024-06-06-064349   True        False         False      25m
machine-approver                           4.16.0-0.nightly-2024-06-06-064349   True        False         False      29m
machine-config                             4.16.0-0.nightly-2024-06-06-064349   True        False         False      29m
marketplace                                4.16.0-0.nightly-2024-06-06-064349   True        False         False      29m
monitoring                                 4.16.0-0.nightly-2024-06-06-064349   True        False         False      15m
network                                    4.16.0-0.nightly-2024-06-06-064349   True        False         False      30m
node-tuning                                4.16.0-0.nightly-2024-06-06-064349   True        False         False      16m
openshift-apiserver                        4.16.0-0.nightly-2024-06-06-064349   True        False         False      23m
openshift-controller-manager               4.16.0-0.nightly-2024-06-06-064349   True        False         False      25m
openshift-samples                          4.16.0-0.nightly-2024-06-06-064349   True        False         False      23m
operator-lifecycle-manager                 4.16.0-0.nightly-2024-06-06-064349   True        False         False      29m
operator-lifecycle-manager-catalog         4.16.0-0.nightly-2024-06-06-064349   True        False         False      29m
operator-lifecycle-manager-packageserver   4.16.0-0.nightly-2024-06-06-064349   True        False         False      24m
service-ca                                 4.16.0-0.nightly-2024-06-06-064349   True        False         False      30m
storage                                    4.16.0-0.nightly-2024-06-06-064349   True        False         False      30m
```
2. Check if the CR `PinnedImageSet` is available in the API:
```shell
$ oc api-resources | grep PinnedImageSet
pinnedimagesets          machineconfiguration.openshift.io/v1alpha1    false        PinnedImageSet
```
3. After registry mirroring, check if the target release is available in the internal registry:
```shell
$ skopeo inspect docker://pinnedis-registry.pinnedis.local.lab/openshift/release-images:4.17.0-0.nightly-2024-06-06-110324-x86_64
{
    "Name": "pinnedis-registry.pinnedis.local.lab/openshift/release-images",
    "Digest": "sha256:2aaae0f0129e2ed2237d56fd7c3e90ec54cac46da7c70a66671868262e88f3a6",
    "RepoTags": [
        "4.17.0-0.nightly-2024-06-06-110324-x86_64"
    ],
    "Created": "2024-06-06T11:05:03Z",
    "DockerVersion": "",
    "Labels": {
        "io.openshift.release": "4.17.0-0.nightly-2024-06-06-110324",
        "io.openshift.release.base-image-digest": "sha256:fe030fca53607957229a81175d8b168e0248b55655cfcd0d8d3ccddbcf024242"
    },
    "Architecture": "amd64",
    "Os": "linux",
    "Layers": [
        "sha256:ca1636478fe5b8e2a56600e24d6759147feb15020824334f4a798c1cb6ed58e2",
        "sha256:08a44bf7d471c25a3130e6b8c82aee2885de514eeab816d8f3c53dd3299dd834",
        "sha256:facf52e6246015804756166c513f6dea01e286aaa1a910c5e9ea11704fe55152",
        "sha256:eb8e59e9822f046e934e8e8fe74160f092a4c9f5aaf6ab919cfcb801b9612b5a",
        "sha256:f51cf7fb505b7e358c53a387320dbcb3dcd43682683117ccb1924bb748d95b50"
    ],

... omitted ...
```
4. Without Internet access, start a ubi8 container to test if the local registry works fine:
```shell
$ oc run -n default --image=registry.access.redhat.com/ubi8/ubi@sha256:143123d85045df426c5bbafc6863659880ebe276eb02c77ee868b88d08dbd05d ubi8 -it --restart=Never
If you don't see a command prompt, try pressing enter.
[root@ubi8 /]# exit

$ oc delete pod ubi8
```
5. Once the pinned images are downloaded, we test on the nodes if we have it in the CRI-O cache:
```shell
pinnedis-node-1 $ crictl images --digests --no-trunc | grep sha256:001c49f4fbcc2122066fd53f7f2abb6822ebd1f89cbfcb55a9e58548f33c7289
quay.io/openshift-release-dev/ocp-v4.0-art-dev   <none>              sha256:001c49f4fbcc2122066fd53f7f2abb6822ebd1f89cbfcb55a9e58548f33c7289   ff6151f6a07831a8bbd32e406a5f302f1bba0e1c39dfcdb772b98c3f15100027   495MB
```
6. Check if all images present in the release are in the CRI-O cache:
```shell
[root@pinnedis-node-1 ~]# /var/home/core/pinned-images.sh pinnedis-registry.pinnedis.local.lab 4.17.0-ec.0-x86_64 | wc -l
0
```

## Links
* [Openshift dev releases](https://quay.io/repository/openshift-release-dev/ocp-release?tab=tags)
* [Openshift 4.16 clients](https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/4.16.0-rc.3)
* [Mirroring images using oc-mirror](https://docs.openshift.com/container-platform/4.15/installing/disconnected_install/installing-mirroring-disconnected.html)
