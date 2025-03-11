# ocp_olm
This role manages Operator Lifecycle Manager (**OLM**) tasks in an Openshift Cluster.

## Requirements
None.

## Role Variables
* `ocp_olm_kubectl`. _String_. Path to the `kubectl` binary.
* `ocp_olm_path`. _String_. Path where manifest files are saved.

## Example Playbook
```yaml
- hosts: servers

  roles:
    - ocp_olm
```

## License
MIT / BSD

## Author Information
 - **Manuel Lorenzo** (mlorenzofr@redhat.com) (2025-)
