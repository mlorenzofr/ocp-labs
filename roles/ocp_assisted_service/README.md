# ocp_assisted_service
This role installs and configures **assisted-service** on an Openshift cluster.

## Requirements
This role uses the **ocp_mce** or **ocp_acm** roles to deploy the _assisted-service_.  
For persistent storage, this role uses the **ocp_lvms** role.  
To create inventory nodes, this role uses the **ocp_baremetal** role.

## Role Variables
* `ocp_assisted_service_apply`. _Bool_. Set wether the role should apply manifests or simply create them.
* `ocp_assisted_service_ca_bundle`. _String_. Trusted CA bundle for custom image registries.
* `ocp_assisted_service_config`. _Dict_. Key-value entries with custom settings for the _assisted-service_.
* `ocp_assisted_service_infra`. _String_. Name of the infrastructure operator used to create infrastructures.
* `ocp_assisted_service_infraenvs`. _List_. List of `InfraEnv` definitions.
* `ocp_assisted_service_lvms`. _Bool_. Enable/Disable LVMS persistent storage.
* `ocp_assisted_service_ns`. _String_. Namespace for the Operator.
* `ocp_assisted_service_op`. _String_. Operator used to install _Assisted Service_ (`acm | mce`).
* `ocp_assisted_service_path`. _String_. Path where the manifest files are saved.
* `ocp_assisted_service_pullsecret`. _String_. Default value for _pull-secret_ on infraenvs.
* `ocp_assisted_service_sc_name`. _String_. _StorageClass_ name for the persistent storage (DB).
* `ocp_assisted_service_ssh_key`. _String_. Default value for _sshAuthorizedKey_ on infraenvs.
* `ocp_assisted_service_storage_db_size`. _Number_. _PersistentVolumeClaim_ size for DB volume.
* `ocp_assisted_service_storage_fs_size`. _Number_. _PersistentVolumeClaim_ size for filesystem volume.
* `ocp_assisted_service_storage_image_size`. _Number_. _PersistentVolumeClaim_ size for image replica volume.
* `ocp_assisted_service_images`. _List_. List of images available for _Assisted_service_.
* `ocp_assisted_service_registries`. _List_. List with image registries and mirrors for agent configuration.
* `ocp_assisted_service_ui`. _Bool_. Set this to `true` to install the assisted-installer-ui.
* `ocp_assisted_service_ui_image`. _String_. Image used to install the assisted-installer-ui.

### Variables for `ocp_assisted_service_images` elements
* `ocp_version`. _String_. Openshift release version.
* `arch`. _String_. Openshift release CPU architecture.
* `version`. _String_. Image version.

### Variables for `ocp_assisted_service_infraenvs` elements
* `cluster_name`. _String_. `ClusterDeployment` name to reference in `InfraEnv`.
* `name`. _String_. `InfraEnv` name.
* `ns`. _String_. `InfraEnv` namespace.
* `hypershift`. _Bool_. Enable/Disable HCP configuration fields.
* `ntp`. _List_. List of NTP servers.
* `pullsecret`. _String_. Personal pull secret.
* `ssh_key`. _String_. Personal SSH public key.
* `redfish`. _String_. Redfish IP address.
* `inventory`. _List_. List of machines and their settings.

### Variables for `ocp_assisted_service_registries` elements
* `location`. _String_. Image registry location.
* `mirror`. _String_. Mirror registry location.

## Example Playbook
```yaml
- hosts: servers

  vars:
    ocp_assisted_service_images:
      - ocp_version: '4.14'
        arch: 'x86_64'
        version: '39.20240322.3.1'
        url: 'https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/39.20240322.3.1/x86_64/fedora-coreos-39.20240322.3.1-live.x86_64.iso'
        rootfs: ''

    ocp_assisted_service_infraenvs:
      - name: 'hosted'
        ns: 'hardware-inventory'
        hypershift: true
        ntp: ['192.168.125.1']
        redfish: '192.168.125.1'
        inventory:
          - {'name': 'example-node-01', 'id': '25'}

  roles:
    - ocp_assisted_service
```

## License
MIT / BSD

## Author Information
 - **Manuel Lorenzo** (mlorenzofr@redhat.com) (2024-)
