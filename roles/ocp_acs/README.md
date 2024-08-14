# ocp_acs
This role installs and configures **Advanced Cluster Security** on an Openshift cluster.

## Requirements
This role requires the `ocp_lvms` role for local storage.  
They will be installed automatically with this role.

## Role Variables
* `ocp_acs_install`. _Bool_. Set wether the role should apply manifests or simply create them.
* `ocp_acs_ns`. _String_. Namespace for the Operator.
* `ocp_acs_path`. _String_. Path where the manifest files are saved.
* `ocp_acs_subscription_channel`. _String_. Operator subscription channel.
* `ocp_acs_subscription_source`. _String_. Operator subscription source.
* `ocp_acs_subscription_version`. _String_. Operator subscription version.

## Example Playbook
```yaml
- hosts: servers

  vars:
    ocp_acs_install: true
    ocp_acs_path: '/home/labs/acs'

  roles:
    - ocp_acs
```

## License
MIT / BSD

## Author Information
 - **Manuel Lorenzo** (mlorenzofr@redhat.com) (2024-)
