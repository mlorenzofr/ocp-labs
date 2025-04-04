# ocp_mcgh
This role installs and configures **MultiCluster Global Hub** (**MCGH**) on an Openshift cluster.

## Requirements
This role requires the following roles (automatically injected):
* **ocp_olm**, to install the mcgh operator.
* **ocp_lvms**, for persistent storage.
* **ocp_baremetal**, for managing baremetal nodes.
* **ocp_assisted_service**, for managing infrastructure resources.
* **ocp_acm**, used as the _assisted-service_ deploy method.

## Role Variables
* `ocp_mcgh_availability`. _String_. HA configuration for app subscriptions (`Basic`|`High`).
* `ocp_mcgh_apply`. _Bool_. Set wether the role should apply manifests or simply create them.
* `ocp_mcgh_channel`. _String_. Operator subscription channel.
* `ocp_mcgh_metrics`. _String_. Enable/Disable metrics colletion.
* `ocp_mcgh_ns`. _String_. Namespace for the Operator.
* `ocp_mcgh_path`. _String_. Path where the manifest files are saved.
* `ocp_mcgh_pullsecret`. _String_. Pull secret credentials for distribution registry.
* `ocp_mcgh_pull_policy`. _String_. Pull policy for MCGH images.
* `ocp_mcgh_retention`. _String_. Duration string, defining how long to keep the data in the database.
* `ocp_mcgh_source`. _String_. Name of the `CatalogSource` to install MCGH.
* `ocp_mcgh_version`. _String_. Operator subscription version.

## Example Playbook
```yaml
- hosts: servers

  roles:
    - ocp_mcgh
```

## License
MIT / BSD

## Author Information
 - **Manuel Lorenzo** (mlorenzofr@redhat.com) (2024-)
