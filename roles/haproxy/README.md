# haproxy

Install and configure haproxy on a RHEL/Fedora system to provide access to Openshift/k8s clusters.

## Requirements

None.

## Role Variables

* `haproxy_auto_discover_labs`. _Bool_. Enable/disable automatic lab discovery from dnsmasq configuration files. Default: `true`
* `haproxy_k8s_api`. _Bool_. Set whether haproxy should listen on port 6443 or not. Default: `true`
* `haproxy_labs`. _List_. List of manually configured labs (clusters). These take precedence over auto-discovered labs. Default: `[]`
* `haproxy_snippets`. _List_. List of additional snippets with extra configurations. Default: `[]`
* `haproxy_stats_user`. _String_. Username to access the stats page. Default: `admin`
* `haproxy_stats_password`. _String_. Password to access the stats page. Default: `''`

## Example Playbook

### Basic Usage with Auto-Discovery

```yaml

- hosts: servers
  roles:
    - haproxy
```

This will automatically discover all labs from `/etc/dnsmasq.d/*.conf`.

### Manual Configuration Only

```yaml

- hosts: servers
  vars:
    haproxy_auto_discover_labs: false
    haproxy_labs:
      - name: 'standard'
        backends: ['192.168.125.11']
  roles:
    - haproxy
```

### Mixed Auto-Discovery and Manual Configuration

```yaml

- hosts: servers
  vars:
    haproxy_labs:
      # Manually override an auto-discovered lab
      - name: 'example'
        backends: ['192.168.125.103', '192.168.125.104']
        api: true
        api_ips: ['192.168.125.102']
  roles:
    - haproxy
```

## Integration with Lab Role

When using the `lab` role to deploy OpenShift clusters, it automatically creates dnsmasq configuration files that this role can discover:

```yaml

- name: 'Deploy new lab and update HAProxy'
  hosts: lab_servers
  roles:
    - role: lab
      vars:
        lab_name: 'newlab'
        # ... other lab variables
    - role: haproxy
      # Auto-discovery will pick up the new lab
```

## Features

### Automatic Lab Discovery

The role can automatically discover OpenShift labs from dnsmasq configuration files in `/etc/dnsmasq.d/*.conf`. This eliminates the need to manually update the `haproxy_labs` variable when deploying new labs.

#### How It Works

1. The role scans `/etc/dnsmasq.d/*.conf` files for lab configurations
2. Extracts lab information from dnsmasq entries:
    * **API endpoint**: `host-record=api.<lab-name>.<domain>,<api-ip>`
    * **Ingress endpoint**: `address=/apps.<lab-name>.<domain>/<ingress-ip>`

3. Automatically configures HAProxy backends for discovered labs
4. Merges auto-discovered labs with manually configured ones (manual configuration takes precedence)

#### Example dnsmasq Configuration

```text
host-record=api-int.example.local.lab,192.168.125.102
host-record=api.example.local.lab,192.168.125.102
address=/apps.example.local.lab/192.168.125.103
dhcp-host=ce:00:0a:ba:ee:71,example-node-1,192.168.125.71
```

From this configuration, the role will extract:

* `name`: example
* `domain`: local.lab
* `api_ips`: [192.168.125.102]
* `backends`: [192.168.125.103]

## License

MIT / BSD

## Author Information

* **Manuel Lorenzo** (mlorenzofr@redhat.com) (2024-)
