# ocp_hive
This role installs (optional) and configures **Hive** operator.  
Hive is usually installed with **MCE**/**ACM** and the main task in this role is to configure it.  
If we want, it is also possible to install the operator using this role.  

## Requirements
This role requires the following roles:
* **ocp_olm**, to install the hive operator.
* **ocp_baremetal**, for managing infrastructure resources.
* **dnsmasq**, to create DNS records for the Hive clusters.

## Role Variables
* `ocp_hive_apply`. _Bool_. Set wether the role should apply manifests or simply create them.
* `ocp_hive_channel`. _String_. Operator subscription channel.
* `ocp_hive_clusters`. _List_. List of hive clusters.
* `ocp_hive_clusterimagesets`. _List_. List of `ClusterImageSet` resources to add.
* `ocp_hive_lab_name`. _String_. Lab name.
* `ocp_hive_ns`. _String_. Namespace for the Operator.
* `ocp_hive_operator`. _Bool_. Set to `True` to install the Hive operator.
* `ocp_hive_path`. _String_. Path where the manifest files are saved.
* `ocp_hive_source`. _String_. `CatalogSource` name to get the operator.

### Variables for `ocp_hive_clusters` elements
* `name`. _String_. Cluster name.
* `ns`. _String_. Cluster namespace.
* `pullsecret`. _String_. Personal pull secret to access registries.
* `image`. _String_. Image used to deploy the cluster.
* `network_type`. _String_. Network type used (`OVNKubernetes|Calico|Other`)
* `cluster_network`. _String_. CIDR for cluster network.
* `service_network`. _String_. CIDR for service network.
* `host_network`. _String_. CIDR of node host network.
* `masters`. _Number_. Number of master nodes on the cluster.
* `workers`. _Number_. Number of worker nodes on the cluster.
* `sshkey`. _String_. Personal SSH public key.
* `domain`. _String_. Base domain for the cluster.

### Variables for `ocp_hive_clusterimagesets` elements
* `name`. _String_. `ClusterImageSet` name.
* `image`. _String_. Registry address to pull the image.
* `visible`. _Bool_. Set whether the image should be visible or not.
* `channel`. _String_. 

## Example Playbook
```yaml
- hosts: servers

  vars:
    ocp_hive_apply: true
    ocp_hive_path: '/home/labs/hive'

  roles:
    - ocp_hive
```

## License
MIT / BSD

## Author Information
 - **Manuel Lorenzo** (mlorenzofr@redhat.com) (2024-)
