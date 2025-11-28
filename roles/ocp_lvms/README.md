# ocp_lvms

This role installs and configures LVMS operator on an Openshift cluster.

## Requirements

This role requires the **ocp_olm** role.

## Role Variables

* `ocp_lvms_apply`. _Bool_. Set wether the role should apply the manifests or simply create them.
* `ocp_lvms_ns`. _String_. Namespace for the Operator.
* `ocp_lvms_path`. _String_. Path where the manifest files are stored.
* `ocp_lvms_source`. _String_. Name of the catalog source name for installing the lvms-operator.
* `ocp_lvms_cluster_default_device`. _String_. If the default lvms cluster definition is used, the device where the `lvmcluster` will create LVM resources.
* `ocp_lvms_cluster_default_role`. _String_. If the default lvms cluster definition is used, the node role where the `lvmcluster` will start.
* `ocp_lvms_subscription_channel`. _String_. Operator subscription channel.
* `ocp_lvms_clusters`. _List_. Definition of `lvmcluster` resources.

### Variables for `ocp_lvms_clusters` elements

* `name`. _String_. Cluster name.
* `ns`. _String_. Cluster namespace.
* `classes`. _List_. List of device classes

### Variables for device class elements

* `name`. _String_. Name of the device class.
* `default`. _Bool_. Set wether the device class should be the default `StorageClass`.
* `devices`. _List_. List of the devices where the LVM resources will be created.
* `devices_opt`. _List_. List of optional paths for the `deviceSelector`.
* `node_role`. _String_. Role of the node where the `lvmcluster` will be started.
* `overprovision_ratio`. _Number_. Percentage of overprovisioning relative to the total pool size.
* `size_percent`. _Number_. Maximum pool size percentage (storage) reserved for volumes.

## Example Playbook

```yaml
- hosts: servers

  vars:
    ocp_lvms_cluster_default_device: 'vda'

  roles:
    - ocp_lvms
```

## License

MIT / BSD

## Author Information

 - **Manuel Lorenzo** (mlorenzofr@redhat.com) (2024-)
