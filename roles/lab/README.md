# lab
This role is used to create labs in my beaker machine.

## Requirements
None.

## Role Variables
* `lab_abi`. _Bool_. Enable Agent Based Installation.
* `lab_abi_ip`. _String_. Assisted Service IP for ABI installation.
* `lab_api_ips`. _List_. List of IP addresses assigned OCP API.
* `lab_bootstrap_ip`. _String_. IP address of the machine used for bootstrap OCP cluster.
* `lab_bootstrap_mac`. _String_. MAC address of the machine used for bootstrap OCP cluster.
* `lab_cluster_network`. _String_. k8s internal network CIDR.
* `lab_domain`. _String_. Base domain used in the OCP cluster.
* `lab_dnsmasq_root`. _String_. Path to the directory where the dnsmasq snippets are hosted.
* `lab_hosts`. _List_. List of machines in the cluster.
* `lab_ingress_ips`. _List_. List of IP addresses assigned to the OCP ingress controller, where the **console** is published.
* `lab_master_replicas`. _Number_. Number of master nodes.
* `lab_name`. _String_. lab name.
* `lab_network_name`. _String_. **Libvirt** network name used.
* `lab_network_type`. _String_. Network type used (`OVNKubernetes|Calico|Other`)
* `lab_machine_network`. _String_. Node network CIDR.
* `lab_path`. _String_. Path in the server where the files will be placed.
* `lab_platform`. _String_. Set the platform (`none|baremetal|vsphere`).
* `lab_pull_secret`: _String_. Personal pull secret.
* `lab_redfish_ip`. _String_. Redfish server IP address.
* `lab_service_network`. _String_. k8s service network CIDR.
* `lab_ssh_pubkey`: _String_. Personal SSH public key.
* `lab_worker_replicas`. _Number_. Number of worker nodes.

### Variables for `lab_hosts` items
* `disk`. _String_. Device used to install Openshift (default: `/dev/vda`).
* `iface`. _String_. Machine interface name.
* `ip`. _String_. Machine IP address.
* `mac`. _String_. Machine MAC address.
* `role`. _String_. Machine role (`master|worker`).

## Dependencies
None.

## Example Playbook
```yaml
- hosts: servers

  vars:
    lab_domain: 'example.com'
    lab_network_name: 'example-network'
    lab_worker_replicas: 2

  roles:
    - lab
```

## License
MIT / BSD

## Versioning
The version number takes the form X.Y.Z where:
* **X** is the major version. It changes with the Ansible major version.
* **Y** is the minor version. It changes with new functionalities.
* **Z** is the patch version. It changes with fixes or cosmetic changes.

For Ansible 7 the major version is **1**.

## Author Information
 - **Manuel Lorenzo** (mlorenzofr@redhat.com) (2024-)
