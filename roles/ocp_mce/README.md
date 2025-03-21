# ocp_mce
This role installs and configures MultiCluster Engine (**MCE**) operator on an Openshift cluster.

## Requirements
This role requires the **ocp_olm** role.

## Role Variables
* `ocp_mce_apply`. _Bool_. Set wether the role should apply the manifests or simply create them.
* `ocp_mce_channel`. _String_. Operator subscription channel.
* `ocp_mce_name`. _String_. Name for the MCE resource.
* `ocp_mce_ns`. _String_. Namespace for the Operator.
* `ocp_mce_path`. _String_. Path where the manifest files are stored.
* `ocp_mce_source`. _String_. Name of the catalog source name for installing the lvms-operator.

## Example Playbook
```yaml
- hosts: servers

  roles:
    - ocp_mce
```

## License
MIT / BSD

## Author Information
 - **Manuel Lorenzo** (mlorenzofr@redhat.com) (2024-)
