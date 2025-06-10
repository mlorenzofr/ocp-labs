# ocp_vpo
This role installs the Validated Patterns Operator (VPO) on an Openshift cluster.

## Requirements

## Role Variables
* `ocp_vpo_apply`. _Bool_. Set wether the role should apply the manifests or simply create them.
* `ocp_vpo_channel`. _String_. Operator subscription channel.
* `ocp_vpo_ns`. _String_. Namespace for the operator.
* `ocp_vpo_operatorgroup`. _String_. OperatorGroup for the operator.
* `ocp_vpo_path`. _String_. Path where the manifest files are stored.
* `ocp_vpo_source`. _String_. Name of the catalog source name for installing the operator.
* `ocp_vpo_version`. _String_. Install the specific version set in this variable.

## Example Playbook
```yaml
- hosts: servers

  roles:
    - ocp_vpo
```

## License
MIT / BSD

## Author Information
 - **Manuel Lorenzo** (mlorenzofr@redhat.com) (2025-)
