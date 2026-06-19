# ocp_oadp

This role installs and configures the OpenShift API for Data Protection (OADP) operator on an OpenShift cluster.

## Requirements

This role requires the **ocp_olm** role.

## Role Variables

* `ocp_oadp_apply`. _Bool_. Set whether the role should apply the manifests or simply create them. Default: `true` (or value of `ocp_apply`).
* `ocp_oadp_channel`. _String_. Operator subscription channel. Default: `'stable'`.
* `ocp_oadp_ns`. _String_. Namespace for the Operator. Default: `'openshift-adp'`.
* `ocp_oadp_operatorgroup`. _String_. OperatorGroup for the operator. Default: `'openshift-adp'`.
* `ocp_oadp_path`. _String_. Path where the manifest files are stored. Default: value of `lab_configs` or `'/tmp'`.
* `ocp_oadp_source`. _String_. Name of the catalog source for installing the OADP operator. Default: `'community-operators'`.
* `ocp_oadp_source_ns`. _String_. Namespace of the catalog source. Default: `'openshift-marketplace'`.

## Example Playbook

```yaml

- hosts: servers

  roles:
    - ocp_oadp
```

## License

MIT / BSD

## Author Information

* **Manuel Lorenzo** (<mlorenzofr@redhat.com>) (2026-)
