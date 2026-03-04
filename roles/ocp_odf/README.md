# ocp_odf

This role installs and configures **O**penshift **D**ata **F**oundation (ODF) on OpenShift cluster.

## Requirements

This role requires `ocp_lvms` (preferred) or `ocp_localstorage` roles for local storage on OpenShift nodes.

## Role Variables

* `ocp_odf_apply`. _Bool_. Set wether the role should apply manifests or simply create them.
* `ocp_odf_console_plugins` _Bool_. Enable/Disable ODF Web UI plugins.
* `ocp_odf_ns`. _String_. Namespace for the Local Storage Operator.
* `ocp_odf_noobaa`. _Bool_. Enable Multicloud Object Gateway (_Noobaa_).
* `ocp_odf_noobaa_backingstores`. _List_. List of Noobaa `BackingStores`.
* `ocp_odf_noobaa_cpu`. _String_. CPU limit for NooBaa.
* `ocp_odf_noobaa_dbtype`. _String_. DB type used by NooBaa.
* `ocp_odf_noobaa_memory`. _String_. Memory limit for NooBaa
* `ocp_odf_noobaa_storage`. _String_. Default storage size for NooBaa.
* `ocp_odf_noobaa_storageclass`. _String_. Default StorageClass used by NooBaa, leave it empty to use the default SC.
* `ocp_odf_path`. _String_. Path where the manifest files are saved.
* `ocp_odf_source`. _String_. Name of the catalog source name for installing the odf-operator.
* `ocp_odf_storage`. _String_. Local storage operator to use (`lvms` or `local-storage`).
* `ocp_odf_storage_nodes`. _List_. List with the names of the nodes to be used as storage nodes.
* `ocp_odf_clusters`. _List_. List of `StorageClusters`.

### Variables for `ocp_odf_clusters` elements

* `name`. _String_. `ClusterStorage` name.
* `default_virtualization_sc`. _Bool_. Enable/Disable the default virtualization `StorageClass` (useful for KubeVirt).
* `managed_nodes`. _Bool_. Enable/Disable auto node management.
* `mds_limits`. _Bool_. Enable/Disable MDS limits.
* `mds_cpu`. _Number_. CPU resource request for Ceph metadata daemon.
* `mds_memory`. _String_. Memory resource request for Ceph metadata daemon.
* `mon_data_path`. _String_. Directory on a local file system storing monitor data.
* `resource_profile`. _String_. Sets the resource profile for the `StorageCluster`.
* `devicesets`. _List_. List of `storageDeviceSets`.
  * `name`. _String_. `StorageDeviceSet` name.
  * `count`. _Number_. Counter of 3-disks sets.
  * `storage`. _String_. Storage size provisioned for ODF in each node (100GiB-4TiB).
  * `storageclass`. _String_. Name of the `StorageClass` required by the claim.
  * `replica`. _Number_. Number of StorageClassDeviceSets.
  * `resources`. _Dict_. Dictionary with values for `cpu` and `memory` to set resource requirements.

### Variables to configure the default `StorageCluster`

To simplify configuration, it is possible to create an `Storagecluster` using a predefined template (`ocp_odf_default_storagecluster`) and a few variables.

* `ocp_odf_sc_resourceprofile`. _String_. Sets the resource profile for the `StorageCluster`.
* `ocp_odf_sc_size`. _String_. Defines the storage size used in the ODF nodes.
* `ocp_odf_sc_storageclass`. _String_. Sets the `StorageClass` used by the `storageDeviceSet`.
* `ocp_odf_sc_virtualization`. _Bool_. If `true`, enables the default virtualization `StorageClass` (useful for KubeVirt).

### Variables for `ocp_odf_noobaa_backingstores` elements

* `name`. _String_. `BackingStore` name.
* `storage`. _String_. Storage size.
* `sc`. _String_. `StorageClass` to use.
* `volumes`. _Number_. Number of volumes.

## Example Playbook

```yaml
- hosts: servers

  vars:
    ocp_odf_path: '/home/labs/localstorage'
    ocp_odf_sc_size: '180Gi'
    ocp_odf_clusters: "{{ ocp_odf_default_storagecluster }}"
    ocp_odf_storage_nodes:
      - 'example-node-1'
      - 'example-node-2'
      - 'example-node-3'

  roles:
    - ocp_odf
```

## License

MIT / BSD

## Author Information

- **Manuel Lorenzo** (mlorenzofr@redhat.com) (2024-)
