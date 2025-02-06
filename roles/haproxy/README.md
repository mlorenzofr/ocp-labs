# haproxy
Install and configure haproxy on a RHEL/Fedora system to provide access to Openshift/k8s clusters.

## Requirements
None.

## Role Variables
* `haproxy_labs`. _List_. List of labs (clusters)
* `haproxy_snippets`. _List_. List of additional snippets with extra configurations.
* `haproxy_stats_user`. _String_. Username to access to the stats page.
* `haproxy_stats_password`. _String_. Password to access to the stats page.

## Example Playbook
```yaml
- hosts: servers

  vars:
    haproxy_labs:
        - {'name': 'standard', 'backends': ['192.168.125.11']}

  roles:
    - haproxy
```

## License
MIT / BSD

## Author Information
 - **Manuel Lorenzo** (mlorenzofr@redhat.com) (2024-)
