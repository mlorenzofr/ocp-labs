# ocp_quay
This role installs and configures **Quay** registry on an Openshift cluster.

## Requirements
None.

## Role Variables
* `ocp_quay_install`. _Bool_. Set wether the role should apply manifests or simply create them.
* `ocp_quay_ns`. _String_. Namespace for the Operator.
* `ocp_quay_path`. _String_. Path where the manifest files are saved.
* `ocp_quay_subscription_source`. _String_. Operator subscription source.
* `ocp_quay_subscription_channel`. _String_. Operator subscription channel.
* `ocp_quay_subscription_version`. _String_. Operator subscription version.
* `ocp_quay_registries`. _List_. List with the Quay registries to create.

### Variables for `ocp_quay_registries` elements
* `name`. _String_. Registry name.
* `ns`. _String_. Registry namespace.

## Example Playbook
```yaml
- hosts: servers

  vars:
    ocp_quay_install: true
    ocp_quay_path: '/home/labs/quay'

  roles:
    - ocp_quay
```

## License
MIT / BSD

## Author Information
 - **Manuel Lorenzo** (mlorenzofr@redhat.com) (2024-)
