# dnsmasq
Install and configure dnsmasq on a RHEL/Fedora systems.

## Requirements
None.

## Role Variables
* `dnsmasq_addresses`. _List_. List of `address` entries for wildcard host resolution.
* `dnsmasq_bind_dynamic`. _Bool_. Enable/disable dynamic interface binding.
* `dnsmasq_bogus_priv`. _Bool_. If enabled, never forward addresses in the non-routed address spaces.
* `dnsmasq_cache_size`. _Number_. DNS cache size.
* `dnsmasq_conf_files`. _List_. Additional configuration files for dnsmasq.
* `dnsmasq_conf_dirs`. _List_. Directories with additional configuration files.
* `dnsmasq_conf_snippets`. _List_. List of templates with additional configuration.
* `dnsmasq_dhcp_authoritative`. _Bool_. Enable/disable DHCP server in authoritative mode.
* `dnsmasq_dhcp_hosts` _List_. List of static DHCP entries for hosts.
* `dnsmasq_dhcp_leasefile`. _String_. Path to DHCP leases file.
* `dnsmasq_dhcp_lease_max`. _Number_. Limits dnsmasq to the specified maximum number of DHCP leases.
* `dnsmasq_disable_resolved`. _Bool_. Sets wether `systemd-resolved` should be disabled or not to avoid conflicts.
* `dnsmasq_domain_needed`. _Bool_. Never forward A or AAAA queries for plain names, without dots or domain parts, to upstream  nameservers.
* `dnsmasq_enable_ra`. _Bool_. Enable router advertisements for all subnets where we are using DHCPv6.
* `dnsmasq_except_interfaces`. _List_. List of interfaces **not** to listen on.
* `dnsmasq_group`. _String_. GID used to run the dnsmasq process.
* `dnsmasq_host_records`. _List_. List of individual host records for name resolution.
* `dnsmasq_interfaces`. _List_. List of listening interfaces for the service.
* `dnsmasq_listen_address`. _String_. Listening address for dnsmasq service.
* `dnsmasq_max_cache_ttl`. _String_. Sets a maximum TTL value for entries in the cache.
* `dnsmasq_min_cache_ttl`. _String_. Extends short TTL values to the time given when caching them.
* `dnsmasq_local_service`. _String_. This restricts service to the connected network (`net`) or the _lo_ interface (`host`) only.
* `dnsmasq_log_dhcp`. _Bool_. Enables log for DHCP requests.
* `dnsmasq_log_queries`. _Bool_. Enables log for DNS requests.
* `dnsmasq_no_hosts`. _Bool_. Don't read the hostnames in /etc/hosts.
* `dnsmasq_no_negcache`. _Bool_. Disable  negative  caching.
* `dnsmasq_no_poll`. _Bool_. Don't poll `/etc/resolv.conf` for changes.
* `dnsmasq_no_resolv`. _Bool_. Don't read `/etc/resolv.conf`.
* `dnsmasq_port`. _Number_. Listening port for the dnsmasq service.
* `dnsmasq_servers`. _List_. List of upstream servers.
* `dnsmasq_strict_order`. _Bool_. Forces queries to strictly follow the order of servers in which they appear in `/etc/resolv.conf`.
* `dnsmasq_resolvconf`. _Bool_. Sets wether `/etc/resolv.conf` should be managed or not.
* `dnsmasq_resolvconf_domains`. _List_. List of search domains for the `/etc/resolv.conf` file.
* `dnsmasq_resolvconf_options`. _List_. List of extra options for the `/etc/resolv.conf` file.
* `dnsmasq_resolvconf_servers`. _List_. List of DNS servers for the `/etc/resolv.conf` file.
* `dnsmasq_resolv_file`. _String_. Alternative `resolv.conf` file to use instead of `/etc/resolv.conf`.
* `dnsmasq_user`. _String_. UID used to run the dnsmasq process.

## Example Playbook
```yaml
- hosts: servers

  vars:
    dnsmasq_addresses:
        - {name: '.apps.example.com', ipaddr: '10.0.0.81'}
    dnsmasq_cache_size: 250
    dnsmasq_conf_snippets:
        - {src: 'dhcp-hosts.conf.j2', dest: 'dhcp-hosts.conf'}
        - {src: 'records.conf.j2', dest: 'host-records.conf'}
    dnsmasq_dhcp_authoritative: true
    dnsmasq_dhcp_hosts:
        - {hwaddr: '52:54:00:00:00:01', hostname: 'machine-01', ipaddr: '192.168.1.35'}
    dnsmasq_except_interfaces:
        - 'podman*'
        - 'vnet*'
    dnsmasq_host_records:
        - {hostname: 'www.example.com', ipaddr: '10.0.0.80'}
    dnsmasq_max_cache_ttl: 300
    dnsmasq_no_negcache: true
    dnsmasq_no_resolv: true
    dnsmasq_servers:
        - {address: '1.1.1.1'}
        - {base: 'example.com', address: '10.0.0.1'}

  roles:
    - dnsmasq
```

External roles can include or import this role to add their own dnsmasq configuration snippets:
```yaml
- name: 'Create dnsmasq snippet'
  ansible.builtin.include_role:
    name: 'dnsmasq'
    tasks_from: 'extra_conf.yaml'
  vars:
    dnsmasq_conf_snippets:
      - {src: 'dnsmasq-config.j2', dest: 'custom.conf'}
  tags: ['dnsmasq']
```

## License
MIT / BSD

## Author Information
 - **Manuel Lorenzo** (mlorenzofr@redhat.com) (2025-)
