# ocp_assisted_service
This role installs and configures Assisted Service on an Openshift cluster.  
This workload is usually deployed as part of the ACM or MCE operators.

## Requirements
This role requires the `ocp_mce` or `ocp_acm` roles for deployment.  
Additionally, the `ocp_lvms` role will be required for persistent storage.

## Role Variables
* `ocp_assisted_service_install`. _Bool_. Set wether the role should apply manifests or simply create them.
* `ocp_assisted_service_ca_bundle`. _String_. Trusted CA bundle for custom image registries.
* `ocp_assisted_service_lvms`. _Bool_. Enable/Disable LVMS persistent storage.
* `ocp_assisted_service_ns`. _String_. Namespace for the Operator.
* `ocp_assisted_service_op`. _String_. Operator used to install _Assisted Service_ (`acm | mce`).
* `ocp_assisted_service_path`. _String_. Path where the manifest files are saved.
* `ocp_assisted_service_sc_name`. _String_. _StorageClass_ name for the persistent storage (DB).
* `ocp_assisted_service_storage_db_size`. _Number_. _PersistentVolumeClaim_ size for DB volume.
* `ocp_assisted_service_storage_fs_size`. _Number_. _PersistentVolumeClaim_ size for filesystem volume.
* `ocp_assisted_service_storage_image_size`. _Number_. _PersistentVolumeClaim_ size for image replica volume.
* `ocp_assisted_service_images`. _List_. List of images available for _Assisted_service_.
* `ocp_assisted_service_registries`. _List_. List with image registries and mirrors for agent configuration.
* `ocp_assisted_service_ui`. _Bool_. Set this tu `true` to install the assisted-installer-ui.
* `ocp_assisted_service_ui_image`. _String_. Image used to install the assisted-installer-ui.

### Variables for `ocp_assisted_service_images` elements
* `ocp_version`. _String_. Openshift release version.
* `arch`. _String_. Openshift release CPU architecture.
* `version`. _String_. Image version.

### Variables for `ocp_assisted_service_registries` elements
* `location`. _String_. Image registry location.
* `mirror`. _String_. Mirror registry location.

## Example Playbook
```yaml
- hosts: servers

  vars:
    ocp_assisted_service_install: true
    ocp_assisted_service_path: '/home/labs/standard'

  roles:
    - ocp_assisted_service
```

## License
MIT / BSD

## Author Information
 - **Manuel Lorenzo** (mlorenzofr@redhat.com) (2024-)
