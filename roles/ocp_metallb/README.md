# ocp_metallb
This role installs and configures the **MetalLB** operator on an Openshift cluster.

## Requirements
This role requires the **ocp_olm** role.

## Role Variables
* `ocp_metallb_apply`. _Bool_. Set wether the role should apply the manifests or simply create them.
* `ocp_metallb_ns`. _String_. Namespace for the Operator.
* `ocp_metallb_path`. _String_. Path where the manifest files are stored.
* `ocp_metallb_pool_ips`. _List_. List of addresses for the `IPAddressPool`.
* `ocp_metallb_pool_name`. _String_. Name of the `IPAddressPool`.
* `ocp_metallb_source`. _String_. Name of the `CatalogSource` to install the metallb-operator.

## Example Playbook
```yaml
- hosts: servers

  vars:
    ocp_metallb_pool_ips: ['192.168.10.100-192.168.10.150']
    ocp_metallb_pool_name: 'example'

  roles:
    - ocp_metallb
```

## License
MIT / BSD

## Author Information
 - **Manuel Lorenzo** (mlorenzofr@redhat.com) (2024-)
