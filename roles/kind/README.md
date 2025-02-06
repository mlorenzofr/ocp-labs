# KIND
Install and configure [KIND](https://kind.sigs.k8s.io/) on a system.

## Requirements
None.

## Role Variables
* `kind_cfg_dir`. _String_. Path to a directory to store the cluster configuration files.
* `kind_clusters`. _List_. List of kind clusters to create.
* `kind_group`. _String_. Group owner of kind files.
* `kind_reinstall`. _Bool_. Set wether the kind binary should be reinstalled or not.
* `kind_user`. _String_. Owner of kind files.
* `kind_version`. _String_. Kind version.

## Example Playbook
```yaml
- hosts: servers

  vars:
    kind_clusters:
      - name: example
        reinstall: True
        address: '10.1.57.1'
        nginx: True

  roles:
    - kind
```

## License
MIT / BSD

## Author Information
 - **Manuel Lorenzo** (mlorenzofr@redhat.com) (2025-)
