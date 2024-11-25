# ocp_baremetal
This role installs and configures baremetal operator resources (`InfraEnv` and `BaremetalHost`) on an Openshift cluster.  

## Requirements
This role requires (yet included by dependencies):
* `ocp_assisted_service`
* `ocp_mce` or `ocp_acm`
* `ocp_lvms`

## Role Variables
* `ocp_baremetal_install`. _Bool_. Set wether the role should apply manifests or simply create them.
* `ocp_assisted_service_ns`. _String_. Namespace for the Operator.
* `ocp_baremetal_path`. _String_. Path where the manifest files are saved.
* `ocp_baremetal_node_cpus`. _Number_. Number of vCPU's in each node.
* `ocp_baremetal_node_disk_data`. _Number_. Disk space, in GB, allocated for data disk.
* `ocp_baremetal_node_disk_sys`. _Number_. Disk space, in GB, allocated for OS disk.
* `ocp_baremetal_node_memory`. _Number_. Memory size, in MB, assigned in each node.

### Variables for `ocp_baremetal_infras` elements
* `name`. _String_. `InfraEnv` name.
* `ns`. _String_. Namespace.
* `hypershift`. _Bool_. Enable/Disable HCP configuration fields.
* `ntp`. _List_. List of NTP servers.
* `pullsecret`. _String_. Personal pull secret.
* `sshkey`. _String_. Personal SSH public key.
* `redfish`. _String_. Redfish IP address.
* `inventory`. _List_. List of machines and their settings.

## Example Playbook
```yaml
- hosts: servers

  vars:
    ocp_baremetal_install: true
    ocp_baremetal_path: '/home/labs/standard'

    ocp_baremetal_infras:
      - name: 'hosted'
        ns: 'hardware-inventory'
        hypershift: true
        ntp: ['192.168.125.1']
        pullsecret: "{{ lab_pull_secret }}"
        sshkey: "{{ lab_ssh_pubkey }}"
        redfish: '192.168.125.1'
        inventory:
          - {'name': "{{ lab_name }}-bmh-1", 'id': '25'}
          - {'name': "{{ lab_name }}-bmh-2", 'id': '26'}
          - {'name': "{{ lab_name }}-bmh-3", 'id': '27'}

  roles:
    - ocp_baremetal
```

## License
MIT / BSD

## Author Information
 - **Manuel Lorenzo** (mlorenzofr@redhat.com) (2024-)
