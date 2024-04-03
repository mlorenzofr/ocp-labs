# lab
This role is used to create labs in my beaker machine.

## Requirements
None.

## Role Variables
* `lab_api_ips`. _List_. List of IP addresses assigned OCP API.
* `lab_bootstrap_ip`. _String_. IP address of the machine used for bootstrap OCP cluster.
* `lab_bootstrap_mac`. _String_. MAC address of the machine used for bootstrap OCP cluster.
* `lab_cluster_network`. _String_. k8s internal network CIDR.
* `lab_domain`. _String_. Base domain used in the OCP cluster.
* `lab_dnsmasq_root`. _String_. Path to the directory where the dnsmasq snippets are hosted.
* `lab_dns_servers`. _List_. List of static DNS servers.
* `lab_external_bridge`. _String_. External bridge used by the Openshift platform.
* `lab_hosts`. _List_. List of machines in the cluster.
* `lab_ingress_ips`. _List_. List of IP addresses assigned to the OCP ingress controller, where the **console** is published.
* `lab_mac_base`. _String_. MAC vendor address for the lab.
* `lab_master_replicas`. _Number_. Number of master nodes.
* `lab_name`. _String_. lab name.
* `lab_network_name`. _String_. **Libvirt** network name used.
* `lab_network_type`. _String_. Network type used (`OVNKubernetes|Calico|Other`)
* `lab_node_cpus`. _Number_. Number of vCPU's in each node.
* `lab_node_disk_data`. _Number_. Disk space, in GB, allocated for data disk.
* `lab_node_disk_sys`. _Number_. Disk space, in GB, allocated for OS disk.
* `lab_node_disk_pool`. _String_. Libvirt storage pool to create disks.
* `lab_node_memory`. _Number_. Memory size, in MB, assigned in each node.
* `lab_node_network`. _String_. Node network base (example: `192.168.125`).
* `lab_node_role`. _String_. Node default role.
* `lab_ntp_sources`. _List_. List of static NTP servers.
* `lab_path`. _String_. Path in the server where the files will be placed.
* `lab_platform`. _String_. Set the platform (`none|baremetal|vsphere`).
* `lab_proxy_http`. _String_. Set HTTP proxy for the cluster.
* `lab_proxy_https`. _String_. Set HTTPS proxy for the cluster.
* `lab_proxy_exceptions`. _List_. List with domains or networks excluded for proxy use.
* `lab_pull_secret`: _String_. Personal pull secret.
* `lab_redfish_ip`. _String_. Redfish server IP address.
* `lab_service_network`. _String_. k8s service network CIDR.
* `lab_ssh_pubkey`: _String_. Personal SSH public key.
* `lab_worker_replicas`. _Number_. Number of worker nodes.

### ABI related variables
* `lab_abi`. _Bool_. Enable Agent Based Installation.
* `lab_abi_ip`. _String_. Assisted Service IP for ABI installation.
* `lab_node_dhcp`. _Bool_. Enable/Disable IPv4 DHCP for nodes.
* `lab_node_dhcp6`. _Bool_. Enable/Disable IPv4 DHCP for nodes.
* `lab_node_ipv4`. _Bool_. Enable/Disable IPv4 network stack for nodes.
* `lab_node_ipv6`. _Bool_. Enable/Disable IPv6 network stack for nodes.

### Appliance related variables
* `lab_appliance`. _Bool_. Enable Appliance installation (ABI subtype).
* `lab_appliance_arch`. _String_. Platform architecture.
* `lab_appliance_channel`. _String_. Openshift distribution channel.
* `lab_appliance_disk_size`. _Number_. Virtual size of the appliance disk image (150 GB min).
* `lab_appliance_local_registry`. _Bool_. Enable/Disable local registry in Appliance nodes.
* `lab_appliance_password`. _String_. Password of user 'core' during the bootstrap phase.
* `lab_appliance_version`. _String_. Openshift version.

### Variables for `lab_hosts` items
* `cpus`. _Number_. Machine vCPUs.
* `disk`. _String_. Device used to install Openshift (default: `/dev/vda`).
* `disk_data`. _Number_. Disk size for data disk (GB).
* `id`. _String_. Machine ID, used for IP and MAC addresses.
* `iface`. _String_. Machine interface name.
* `ip`. _String_. Machine IP address.
* `mac`. _String_. Machine MAC address.
* `memory`. _Number_. Memory assigned (MB)
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
