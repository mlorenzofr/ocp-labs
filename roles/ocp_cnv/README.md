# ocp_cnv
This role installs and configures Openshift Virtualization (**CNV**) on a cluster.

## Requirements
None.

## Role Variables
* `ocp_cnv_install`. _Bool_. Set wether the role should apply manifests or simply create them.
* `ocp_cnv_ns`. _String_. Namespace for the Operator.
* `ocp_cnv_path`. _String_. Path where the manifest files are saved.
* `ocp_cnv_subscription_channel`. _String_. Operator subscription channel.
* `ocp_cnv_version`. _String_. Operator version.

## Example Playbook
```yaml
- hosts: servers

  vars:
    ocp_cnv_install: true
    ocp_cnv_path: '/home/labs/cnv'
    ocp_cnv_version: '4.15.0'

  roles:
    - ocp_cnv
```

## License
MIT / BSD

## Author Information
 - **Manuel Lorenzo** (mlorenzofr@redhat.com) (2024-)
