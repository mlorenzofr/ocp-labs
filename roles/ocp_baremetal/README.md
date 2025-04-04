# ocp_baremetal
This role installs and configures a baremetal platform on an Openshift cluster.

## Requirements
This role requires the **dnsmasq** role to create DNS records for `BaremetalHosts`.

## Role Variables
* `ocp_baremetal_apply`. _Bool_. Set wether the role should apply manifests or simply create them.
* `ocp_baremetal_bmc_password`. _String_. Default BMC password for `BareMetalHosts`.
* `ocp_baremetal_bmc_username`. _String_. Default BMC user for `BareMetalHosts`.
* `ocp_baremetal_infras`. _List_. List with attributes to create `InfraEnv` resources.
* `ocp_baremetal_path`. _String_. Path where the manifest files are saved.
* `ocp_baremetal_node_cpus`. _Number_. Number of vCPU's in each node.
* `ocp_baremetal_node_disk_data`. _Number_. Disk space, in GB, allocated for data disk.
* `ocp_baremetal_node_disk_sys`. _Number_. Disk space, in GB, allocated for OS disk.
* `ocp_baremetal_node_memory`. _Number_. Memory size, in MB, assigned in each node.

### Variables for `ocp_baremetal_infras` elements
* `name`. _String_. `InfraEnv` name.
* `ns`. _String_. Namespace.
* `redfish`. _String_. Redfish IP address.
* `inventory`. _List_. List of machines and their settings.

## Example Playbook
```yaml
- hosts: servers

  vars:
    ocp_baremetal_infras:
      - name: 'hosted'
        ns: 'hardware-inventory'
        redfish: '192.168.125.1'
        inventory:
          - {'name': "example-bmh-1", 'id': '25'}
          - {'name': "example-bmh-2", 'id': '26'}
          - {'name': "example-bmh-3", 'id': '27'}

  roles:
    - ocp_baremetal
```

## License
MIT / BSD

## Author Information
 - **Manuel Lorenzo** (mlorenzofr@redhat.com) (2024-)
