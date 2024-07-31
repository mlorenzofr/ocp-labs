# ocp_localstorage
This role installs Local Storage Operator on an Openshift cluster and configures the Local Volumes on the nodes.

## Requirements
None.

## Role Variables
* `ocp_localstorage_install`. _Bool_. Set wether the role should apply manifests or simply create them.
* `ocp_localstorage_nodes`. _List_. List of nodes used for Local Storage and their Volume labels.
* `ocp_localstorage_ns`. _String_. Namespace for the Local Storage Operator.
* `ocp_localstorage_path`. _String_. Path where the manifest files are saved.
* `ocp_localstorage_subscription_channel`. _String_. Operator subscription channel.
* `ocp_localstorage_volumes`. _List_. List of Local Volumes.
* `ocp_localstorage_volumesets`. _List_. List of `LocalVolumeSets`.

### Variables for `ocp_localstorage_nodes` elements
* `name`. _String_. Node name.
* `label`. _String_. Label key for the node.

### Variables for `ocp_localstorage_volumes` elements
* `name`. _String_. Local Volume name.
* `node_label`. _String_. Node match label for the volume.
* `storage_classes`. _List_. `StorageClasses` managed by the volume.
    * `name`. _String_. `StorageClass` name.
    * `type`. _String_. `StorageClass` type (`Block` or `Part`).
    * `devices`. _List_. List of block devices to use.

### Variables for `ocp_localstorage_volumesets` elements
* `name`. _String_. `LocalVolumeSet` name.
* `node_label`. _String_. Node match label.
* `sc_default`. _Bool_. Set the `StorageClass` associated as default for the cluster.
* `sc_name`. _String_. `StorageClassName` to use for set of matched devices.
* `mode`. _String_. Determines whether the PV created is Block or Filesystem.
* `fstype`. _String_. Type to create when volumeMode is Filesystem.
* `max_devices`. _Number_. Maximum number of Devices that needs to be detected per node.
* `partitions`. _Bool_. Enable partitions for automatic detection.

## Example Playbook
```yaml
- hosts: servers

  vars:
    ocp_localstorage_install: true
    ocp_localstorage_path: '/home/labs/localstorage'
    ocp_localstorage_nodes:
      - {'name': 'standard-master-1', label: 'cluster.ocs.openshift.io/openshift-storage'}
      - {'name': 'standard-master-2', label: 'cluster.ocs.openshift.io/openshift-storage'}
      - {'name': 'standard-master-3', label: 'cluster.ocs.openshift.io/openshift-storage'}
    ocp_localstorage_volumesets:
      - name: 'local-block'
        node_label: 'cluster.ocs.openshift.io/openshift-storage'
        sc_name: 'localblock'
        max_devices: 1

  roles:
    - ocp_localstorage
```

## License
MIT / BSD

## Author Information
 - **Manuel Lorenzo** (mlorenzofr@redhat.com) (2024-)
