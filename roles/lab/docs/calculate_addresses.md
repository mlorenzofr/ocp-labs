# Automatic Address Calculation

This task automatically calculates available MAC and IP addresses for lab VMs based on current dnsmasq configuration and leases.

## How It Works

The task analyzes:

1. **Active leases** from `/var/lib/dnsmasq/dnsmasq.leases`
2. **Reserved IPs** from `/etc/dnsmasq.d/*.conf` files (host-record, address, dhcp-host entries)

## IP Range Allocation

* **VM IPs**: `192.168.x.10-99`
* **API/Ingress IPs**: `192.168.x.100-254`

## Usage

### Auto-Calculation is Enabled by Default

The feature is enabled by default (`lab_auto_addresses: true` in `roles/lab/defaults/main.yml`).

Simply specify the number of VMs needed:

```yaml

- name: 'Import ABI playbook'
  ansible.builtin.import_playbook: ../../playbooks/base/abi.yaml
  vars:
    lab_name: 'mylab'
    lab_master_replicas: 3
    lab_worker_replicas: 2
    lab_mac_base: 'be:be:ca:fe:05:'
    lab_node_network_base: '192.168.125.'
```

### Calculated Variables

The task automatically sets these variables if not manually defined:

* `lab_hosts`: List of VM configurations with auto-calculated IDs
* `lab_abi_ip`: IP for the first node (e.g., `192.168.125.10`)
* `lab_api_ips`: API endpoint IP(s)
* `lab_ingress_ips`: Ingress endpoint IP(s)

### Preserving Manual Properties

You can specify additional properties for VMs, and the task will only fill in missing `id` fields:

```yaml
vars:
  lab_name: 'mylab'
  lab_master_replicas: 3
  lab_hosts:
    - {role: 'master', memory: 32000}  # ID will be auto-calculated
    - {role: 'master', memory: 32000}  # ID will be auto-calculated  
    - {role: 'master', cpus: 16}       # ID will be auto-calculated
```

Or mix manual IDs with auto-calculated ones:

```yaml
vars:
  lab_hosts:
    - {id: '51', role: 'master'}       # Manual ID preserved
    - {role: 'master'}                 # ID auto-calculated
    - {iface: 'enp1s0'}                # ID auto-calculated
```

### Single Node OpenShift (SNO)

For SNO deployments (`lab_master_replicas: 1`):

* `lab_api_ips` and `lab_ingress_ips` will be set to the same IP as `lab_abi_ip`

### Multi-Node Clusters

For non-SNO deployments:

* `lab_api_ips` and `lab_ingress_ips` will be assigned 2 available IPs from the range `192.168.x.100-254`

## Example Output

```
Lab type: Multi-node
VMs needed: 3
lab_hosts: [{'id': '10'}, {'id': '11'}, {'id': '12'}]
lab_abi_ip: 192.168.125.10
lab_api_ips: ['192.168.125.100']
lab_ingress_ips: ['192.168.125.101']
```

With manual properties preserved:

```
Lab type: Multi-node
VMs needed: 3
lab_hosts: [{'id': '10', 'role': 'master'}, {'id': '11', 'role': 'master'}, {'id': '12', 'iface': 'enp1s0'}]
lab_abi_ip: 192.168.125.10
lab_api_ips: ['192.168.125.100']
lab_ingress_ips: ['192.168.125.101']
```

## Tags

Run only the calculation task:

```bash
ansible-playbook deploy.yaml --tags calculate
```

## Disable Auto-Calculation

If you prefer to disable auto-calculation entirely, set `lab_auto_addresses: false`:

```yaml
vars:
  lab_auto_addresses: false
  lab_hosts:
    - {id: '51'}
    - {id: '52'}
    - {id: '53'}
  lab_abi_ip: "{{ lab_node_network_base }}51"
  lab_api_ips: ["{{ lab_node_network_base }}58"]
  lab_ingress_ips: ["{{ lab_node_network_base }}59"]
```

## How It Works Internally

1. **Check for manual definitions**: If `lab_hosts` has entries with `id` fields, those are preserved
2. **Calculate missing IDs**: For entries without `id`, or when `lab_hosts` is empty, auto-calculate from available pool
3. **Preserve properties**: Any properties like `role`, `iface`, `memory`, `cpus` are kept intact
4. **Set network IPs**: Auto-calculate `lab_abi_ip`, `lab_api_ips`, `lab_ingress_ips` only if not manually defined
