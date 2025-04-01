# ocp_registry
This role configures the Openshift Image Registry operator.

## Requirements
This role requires a persistent storage on the cluster to store the images. The LVMS operator is used by default.

## Role Variables
* `ocp_registry_ns`. _String_. Namespace for the Operator.
* `ocp_registry_storage`. _String_. Storage system used. Currently, only `lvms` or `other` is supported.
* `ocp_registry_storage_class`. _String_. StorageClass name used for storage.
* `ocp_registry_storage_size`. _String_. Size of the images storage volume.

## Example Playbook
```yaml
- hosts: servers

  vars:
    ocp_registry_storage_class: 'lvms-vg1'

  roles:
    - ocp_registry
```

## License
MIT / BSD

## Author Information
 - **Manuel Lorenzo** (mlorenzofr@redhat.com) (2025-)
