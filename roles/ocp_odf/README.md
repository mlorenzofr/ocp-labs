# ocp_odf
This role installs and configures **O**penshift **D**ata **F**oundation (ODF) on Openshift cluster.

## Requirements
This role requires `ocp_localstorage` or `ocp_lvms` roles for local storage.

## Role Variables
* `ocp_odf_apply`. _Bool_. Set wether the role should apply manifests or simply create them.
* `ocp_odf_ns`. _String_. Namespace for the Local Storage Operator.
* `ocp_odf_noobaa`. _Bool_. Enable Multicloud Object Gateway (_Noobaa_).
* `ocp_odf_noobaa_backingstores`. _List_. List of Noobaa `BackingStores`.
* `ocp_odf_noobaa_cpu`. _String_. CPU limit for NooBaa.
* `ocp_odf_noobaa_dbtype`. _String_. DB type used by NooBaa.
* `ocp_odf_noobaa_memory`. _String_. Memory limit for NooBaa
* `ocp_odf_noobaa_storage`. _String_. Default storage size for NooBaa.
* `ocp_odf_noobaa_storageclass`. _String_. Default StorageClass used by NooBaa, leave it empty to use the default SC.
* `ocp_odf_on_masters`. _Bool_. Enable the use of master nodes as storage nodes.
* `ocp_odf_path`. _String_. Path where the manifest files are saved.
* `ocp_odf_source`. _String_. Name of the catalog source name for installing the odf-operator.
* `ocp_odf_storage`. _String_. Local storage operator to use (`lvms` or `local-storage`).
* `ocp_odf_storage_nodes`. _List_. List with the names iof the nodes to be used as storage nodes.
* `ocp_odf_clusters`. _List_. List of `StorageClusters`.

### Variables for `ocp_odf_clusters` elements
* `name`. _String_. `ClusterStorage` name.
* `mds_cpu`. _Number_. CPU resource request for Ceph metadata daemon.
* `mds_memory`. _String_. Memory resource request for Ceph metadata daemon.
* `mon_data_path`. _String_. Directory on a local file system storing monitor data.
* `devicesets`. _List_. List of `storageDeviceSets`.
    * `name`. _String_. `StorageDeviceSet` name.
    * `count`. _Number_. Counter of 3-disks sets.
    * `storage`. _String_. Storage size provisioned for ODF in each node (100GiB-4TiB).
    * `storageclass`. _String_. Name of the `StorageClass` required by the claim.
    * `replica`. _Number_. Number of StorageClassDeviceSets.
    * `resources`. _Dict_. Dictionary with values for `cpu` and `memory` to set resource requirements.

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
    ocp_odf_clusters:
      - name: 'ocs-storagecluster'
        devicesets:
          - name: 'ocs-deviceset'
            count: 1
            storage: '150Gi'
            storageclass: 'localblock'
            replica: 3

  roles:
    - ocp_odf
```

## License
MIT / BSD

## Author Information
 - **Manuel Lorenzo** (mlorenzofr@redhat.com) (2024-)
