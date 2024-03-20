# ocp_acm
This role installs and configures **A**dvanced **C**luster **M**anagement (ACM) on Openshift cluster.

## Requirements
None.

## Role Variables
* `ocp_acm_install`. _Bool_. Set wether the role should apply manifests or simply create them.
* `ocp_acm_ns`. _String_. Namespace for the Operator.
* `ocp_acm_path`. _String_. Path where the manifest files are saved.
* `ocp_acm_pullsecret`. _String_. Pull secret credentials for distribution registry.
* `ocp_acm_subscription_channel`. _String_. Operator subscription channel.

## Example Playbook
```yaml
- hosts: servers

  vars:
    ocp_acm_install: true
    ocp_acm_path: '/home/labs/acm'
    ocp_acm_pullsecret: '{"auths":{<redacted>}}'

  roles:
    - ocp_acm
```

## License
MIT / BSD

## Author Information
 - **Manuel Lorenzo** (mlorenzofr@redhat.com) (2024-)
