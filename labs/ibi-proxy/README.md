# ibi-proxy lab

This lab creates two Single Node OpenShift (**SNO**) clusters to test Image-Based Installation (**IBI**) in environments using proxies.

## Architecture

The lab consists of two separate environments:

1. **Seed Cluster** (`ibi-proxy`)
   * Network: `192.168.132.0/24`
   * SNO IP: `192.168.132.31`
   * Proxy: `http://192.168.132.1:3128`
   * Purpose: Generate the seed image using Lifecycle Agent (LCA)
   * LCA operator installed automatically during deployment

2. **Target Cluster** (`ibi-proxy-target`)
   * Network: `192.168.133.0/24`
   * SNO IP: `192.168.133.31`
   * Proxy: `http://192.168.133.1:3128`
   * Purpose: Pre-provisioned VM to be installed manually using the seed image

## Requirements

* Sufficient disk space for two SNO clusters
* Libvirt networks must be created before deployment (see below)

## Steps

### 1. Create libvirt networks

Create the two isolated networks for the lab:

```shell
# Create seed cluster network (192.168.132.0/24)
virsh net-define labs/ibi-proxy/libvirt/ibi-proxy-net.xml
virsh net-start ibi-proxy-net
virsh net-autostart ibi-proxy-net

# Create target cluster network (192.168.133.0/24)
virsh net-define labs/ibi-proxy/libvirt/ibi-proxy-tgt.xml
virsh net-start ibi-proxy-tgt
virsh net-autostart ibi-proxy-tgt
```

Verify the networks are active:

```shell
virsh net-list
```

### 2. Deploy both clusters

Deploy the seed cluster (including LCA operator) and create the target cluster VM:

```shell
ap labs/ibi-proxy/deploy.yaml
```

This will:
* Deploy the seed cluster
* Install and configure the Lifecycle Agent (LCA) operator
* Install the OpenShift API for Data Protection (OADP) operator
* Create the target cluster VM

To deploy only the seed cluster:

```shell
ap labs/ibi-proxy/deploy.yaml --tags seed
```

To install only the LCA operator on an existing seed cluster:

```shell
ap labs/ibi-proxy/deploy.yaml --tags lca
```

To create only the target cluster VM:

```shell
ap labs/ibi-proxy/deploy.yaml --tags target
```

### 2. Block Internet access (optional)

To ensure that the proxy is being used, you can block direct Internet access from the lab networks:

```shell
# Block seed cluster network
iptables -I LIBVIRT_FWO 1 -s 192.168.132.0/24 ! -d 192.168.132.0/24 -j REJECT

# Block target cluster network
iptables -I LIBVIRT_FWO 1 -s 192.168.133.0/24 ! -d 192.168.133.0/24 -j REJECT
```

### 3. Configure trusted CA for internal registry

To push the seed image to an internal OCI registry, you need to add the registry certificate to the seed cluster as a trusted CA.

#### Extract the registry CA certificate

Use `openssl` to extract the certificate from your registry:

```shell
# Replace registry.example.com:5000 with your registry URL
openssl s_client -showcerts -connect registry.example.com:5000 </dev/null 2>/dev/null | \
  openssl x509 -outform PEM > registry-ca.crt
```

#### Create the ConfigMap with the certificate

Create a ConfigMap in the `openshift-config` namespace with the registry CA:

```shell
oc create configmap registry-ca \
  -n openshift-config \
  --from-file=ca-bundle.crt=registry-ca.crt
```

#### Patch cluster resources

Patch the `proxy/cluster` and `images.config/cluster` resources to use the trusted CA:

```shell
# Patch proxy resource
oc patch proxy/cluster --type=merge --patch='{"spec":{"trustedCA":{"name":"registry-ca"}}}'

# Patch images.config resource
oc patch images.config/cluster --type=merge --patch='{"spec":{"additionalTrustedCA":{"name":"registry-ca"}}}'
```

#### Verify the configuration

Wait for the Machine Config Operator to apply the changes:

```shell
# Watch machine config pool updates
oc get mcp -w

# Verify the proxy configuration
oc get proxy/cluster -o yaml

# Verify the images configuration
oc get images.config/cluster -o yaml
```

The cluster will need to reboot the nodes to apply the trusted CA changes.

### 4. Generate seed image

Use LCA to generate the seed image on the seed cluster.

### 5. Install target cluster manually

1. Extract the seed image from the seed cluster
2. Boot the target cluster VM (`ibi-proxy-target-node-1`) using the seed image
3. The installation should use the proxy at `http://192.168.133.1:3128`

## Validation

### Seed Cluster

Check if the seed cluster is running:

```shell
export KUBECONFIG=~/labs/ibi-proxy/deploy/auth/kubeconfig

oc get nodes
# Expected output:
# NAME               STATUS   ROLES                         AGE     VERSION
# ibi-proxy-node-1   Ready    control-plane,master,worker   3h57m   v1.34.6

oc get clusterversion
# Expected output
# NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
# version   4.21.13   True        False         3h36m   Cluster version is 4.21.13
```

Check proxy configuration:

```shell
oc get proxy cluster -o yaml
# Expected output
# apiVersion: config.openshift.io/v1
# kind: Proxy
# metadata:
#   name: cluster
# spec:
#   httpProxy: http://192.168.132.1:3128
#   httpsProxy: http://192.168.132.1:3128
#   noProxy: ibi-proxy.local.lab,api-int.ibi-proxy.local.lab,192.168.132.0/24,10.132.0.0/14,172.30.0.0/16,.ibi-proxy.local.lab,10.132.0.0/14,172.30.0.0/16,192.168.132.0/24
#   trustedCA:
#     name: pinnedis-ca
# status:
#   httpProxy: http://192.168.132.1:3128
#   httpsProxy: http://192.168.132.1:3128
#   noProxy: .cluster.local,.ibi-proxy.local.lab,.svc,10.132.0.0/14,127.0.0.1,172.30.0.0/16,192.168.132.0/24,api-int.ibi-proxy.local.lab,ibi-proxy.local.lab,localhost
```

Check if the seed image was generated:

```shell
oc get seedgenerator -A
# NAME        AGE   STATE              DETAILS
# seedimage   93s   SeedGenCompleted   Seed Generation completed
```

### Target Cluster

After manual installation using the seed image:

```shell
export KUBECONFIG=~/labs/ibi-proxy-target/deploy/auth/kubeconfig

oc get nodes
# Expected output:
# NAME                       STATUS   ROLES                         AGE   VERSION
# ibi-proxy-target-node-1    Ready    control-plane,master,worker   10m   v1.32.x

oc get clusterversion
```

## Cleanup

To clean both clusters:

```shell
ap labs/ibi-proxy/deploy.yaml --tags clean
```

To clean individual clusters:

```shell
# Clean seed cluster
ap playbooks/jobs/clean-lab.yml -e lab_name=ibi-proxy

# Clean target cluster
ap playbooks/jobs/clean-lab.yml -e lab_name=ibi-proxy-target
```

To remove iptables rules:

```shell
# Remove seed cluster network block
iptables -D LIBVIRT_FWO -s 192.168.132.0/24 ! -d 192.168.132.0/24 -j REJECT

# Remove target cluster network block
iptables -D LIBVIRT_FWO -s 192.168.133.0/24 ! -d 192.168.133.0/24 -j REJECT
```

To remove libvirt networks (optional):

```shell
# Stop and undefine seed cluster network
virsh net-destroy ibi-proxy-net
virsh net-undefine ibi-proxy-net

# Stop and undefine target cluster network
virsh net-destroy ibi-proxy-tgt
virsh net-undefine ibi-proxy-tgt
```

## Troubleshooting

### Seed image generation issues

If you encounter problems during seed image generation, you can check the logs of the image builder container directly on the seed cluster node.

1. SSH into the seed cluster node:

```shell
ssh core@192.168.132.31
```

2. Switch to root and follow the image builder logs:

```shell
sudo -i
podman logs -f lca_image_builder
```

This will show real-time logs from the Lifecycle Agent image builder container, which can help identify issues during the seed image creation process.

## Links

* [Image-based installation for single-node OpenShift](https://docs.redhat.com/en/documentation/openshift_container_platform/4.17/html/edge_computing/image-based-installation-for-single-node-openshift)
* [Image-based installation is easier and faster](https://developers.redhat.com/articles/2025/02/14/image-based-installation-easier-and-faster)
* [Lifecycle Agent Operator](https://github.com/openshift-kni/lifecycle-agent)
