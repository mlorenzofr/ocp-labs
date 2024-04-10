# lab
This role is used to configure a Beaker machine and get it ready to deploy Openshift labs using libvirt.

## Requirements
None.

## Role Variables

## Dependencies
None.

## Example Playbook
```yaml
- hosts: servers

  vars:

  roles:
    - lab_host
```

## License
MIT / BSD

## Versioning
The version number takes the form X.Y.Z where:
* **X** is the major version. It changes with the Ansible major version.
* **Y** is the minor version. It changes with new functionalities.
* **Z** is the patch version. It changes with fixes or cosmetic changes.

## Author Information
 - **Manuel Lorenzo** (mlorenzofr@redhat.com) (2024-)
