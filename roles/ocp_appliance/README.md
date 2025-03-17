# ocp_appliance
This role manages the [openshift-appliance](https://github.com/openshift/appliance) tool to create and manage self-container Openshift cluster installations.

## Requirements
None.

## Role Variables
* `ocp_appliance_arch`. _String_. Platform architecture.
* `ocp_appliance_base_cmd`. _String_. openshift-appliance base command.
* `ocp_appliance_cfg_dir`. _String_. Path where the configuration files will be placed.
* `ocp_appliance_cfg_upgrade`. _Bool_. Set wether the configuration file will be use to build an upgrade.
* `ocp_appliance_channel`. _String_. Openshift distribution channel.
* `ocp_appliance_cwd`. _String_. openshift-appliance command working dir.
* `ocp_appliance_disk_size`. _Number_. Virtual size of the appliance disk image (150 GB min).
* `ocp_appliance_image`. _String_. openshift-appliance container image.
* `ocp_appliance_local_registry`. _Bool_. Enable/Disable local registry in Appliance nodes.
* `ocp_manifests`. _List_. List of additional manifests to include in the installation process.
* `ocp_operators`. _List_. List of additional operators to include in appliance build.
* `ocp_appliance_password`. _String_. Password of user 'core' during the bootstrap phase.
* `ocp_appliance_pull_policy`. _String_. Pull policy used in the openshift-appliance command.
* `ocp_appliance_version`. _String_. Openshift version.

## Role variables to execute appliance commands
* `ocp_appliance_cmd_clean`. _Bool_. `openshift-appliance clean`
* `ocp_appliance_cmd_clean_cache`. _Bool_. `openshift-appliance clean --cache`
* `ocp_appliance_cmd_build`. _Bool_. `openshift-appliance build`
* `ocp_appliance_cmd_upgrade_iso`. _Bool_. `openshift-appliance build upgrade-iso`

## Example Playbooks
* Run individual appliance commands:
```yaml
- hosts: servers

  tasks:
    - name: 'Run appliance commands'
      ansible.builtin.include_role:
        name: 'ocp_appliance'
        tasks_from: 'commands.yaml'
      vars:
        ocp_appliance_cwd: '/tmp/appliance/deploy'
        ocp_appliance_cmd_clean: true
        ocp_appliance_cmd_build: true
```

## License
MIT / BSD

## Author Information
 - **Manuel Lorenzo** (mlorenzofr@redhat.com) (2025-)
