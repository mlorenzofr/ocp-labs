# ocp_nmstate
This role installs and configures Kubernetes NMState Operator on a cluster.

## Requirements
None.

## Role Variables
* `ocp_nmstate_apply`. _Bool_. Set wether the role should apply manifests or simply create them.
* `ocp_nmstate_channel`. _String_. Operator subscription channel.
* `ocp_nmstate_ns`. _String_. Namespace for the Operator.
* `ocp_nmstate_path`. _String_. Path where the manifest files are saved.
* `ocp_nmstate_source`. _String_. Operator catalog source.

## Example Playbook
```yaml
- hosts: servers

  vars:
    ocp_nmstate_install: true
    ocp_nmstate_path: '/home/labs/network'

  roles:
    - ocp_nmstate
```

## License
MIT / BSD

## Author Information
 - **Manuel Lorenzo** (mlorenzofr@redhat.com) (2025-)