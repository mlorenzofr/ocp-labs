# ocp_quay
This role configures **Machine Config operator** on an Openshift cluster.

## Requirements
None.

## Role Variables
* `ocp_mco_icsp`. _List_. List with ImageContentSourcePolicies to configure.
* `ocp_mco_install`. _Bool_. Set wether the role should apply manifests or simply create them.
* `ocp_mco_path`. _String_. Path where the manifest files are saved.

### Variables for `ocp_mco_icsp` elements
* `name`. _String_. ICSP name.
* `repo_mirrors`. _List_. ICSP mirrors.
  * `source`. _String_. Repository source.
  * `mirrors`. _List_. List with mirror addresses for the source.

## Example Playbook
```yaml
- hosts: servers

  vars:
    ocp_mco_install: true

  roles:
    - ocp_mco
```

## License
MIT / BSD

## Author Information
 - **Manuel Lorenzo** (mlorenzofr@redhat.com) (2024-)
