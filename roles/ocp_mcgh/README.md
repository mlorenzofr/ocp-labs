# ocp_mcgh
This role installs and configures **MultiCluster Global Hub** on an Openshift cluster.

## Requirements
This role requires the `ocp_acm` role and `ocp_lvms` role for local storage.  
They will be installed automatically with this role.

## Role Variables
* `ocp_mcgh_availability`. _String_. HA configuration for app subscriptions (`Basic`|`High`).
* `ocp_mcgh_install`. _Bool_. Set wether the role should apply manifests or simply create them.
* `ocp_mcgh_metrics`. _String_. Enable/Disable metrics colletion.
* `ocp_mcgh_ns`. _String_. Namespace for the Operator.
* `ocp_mcgh_path`. _String_. Path where the manifest files are saved.
* `ocp_mcgh_pullsecret`. _String_. Pull secret credentials for distribution registry.
* `ocp_mcgh_pull_policy`. _String_. Pull policy for MCGH images.
* `ocp_mcgh_retention`. _String_. Duration string, defining how long to keep the data in the database.
* `ocp_mcgh_subscription_channel`. _String_. Operator subscription channel.
* `ocp_mcgh_subscription_source`. _String_. Operator subscription source.
* `ocp_mcgh_subscription_version`. _String_. Operator subscription version.

## Example Playbook
```yaml
- hosts: servers

  vars:
    ocp_mcgh_install: true
    ocp_mcgh_path: '/home/labs/mcgh'

  roles:
    - ocp_mcgh
```

## License
MIT / BSD

## Author Information
 - **Manuel Lorenzo** (mlorenzofr@redhat.com) (2024-)
