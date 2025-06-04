# ocp_talm
This role installs and configures the Topology Aware Lifecycle Manager (TALM) operator on an Openshift cluster.

## Requirements

## Role Variables
* `ocp_talm_apply`. _Bool_. Set wether the role should apply the manifests or simply create them.
* `ocp_talm_channel`. _String_. Operator subscription channel.
* `ocp_talm_ns`. _String_. Namespace for the Operator.
* `ocp_talm_operatorgroup`. _String_. OperatorGroup for the operator.
* `ocp_talm_path`. _String_. Path where the manifest files are stored.
* `ocp_talm_source`. _String_. Name of the catalog source name for installing the talm-operator.

## Example Playbook
```yaml
- hosts: servers

  roles:
    - ocp_talm
```

## License
MIT / BSD

## Author Information
 - **Manuel Lorenzo** (mlorenzofr@redhat.com) (2025-)
