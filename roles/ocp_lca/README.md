# ocp_lca

This role installs and configures the Lifecycle Agent (LCA) operator on an OpenShift cluster.

## Requirements

This role requires the **ocp_oadp** role (OpenShift API for Data Protection).

## Role Variables

* `ocp_lca_apply`. _Bool_. Set whether the role should apply the manifests or simply create them. Default: `true` (or value of `ocp_apply`).
* `ocp_lca_channel`. _String_. Operator subscription channel. Default: `'stable'`.
* `ocp_lca_image_name`. _String_. Name for the seed image in the container registry. Default: value of `lab_name` or `'lifecycle-agent'`.
* `ocp_lca_image_tag`. _String_. Tag for the seed image. If empty, the role will automatically retrieve the OpenShift cluster version. Default: `''`.
* `ocp_lca_ns`. _String_. Namespace for the Operator. Default: `'openshift-lifecycle-agent'`.
* `ocp_lca_operatorgroup`. _String_. OperatorGroup for the operator. Default: `'openshift-lifecycle-agent'`.
* `ocp_lca_path`. _String_. Path where the manifest files are stored. Default: value of `lab_configs` or `'/tmp'`.
* `ocp_lca_registry`. _String_. Container registry URL where the seed image will be pushed. Default: `'quay.io/example'`.
* `ocp_lca_seedgen_auth`. _String_. Authentication secret name for the seed generator to access the container registry. Default: `''`.
* `ocp_lca_source`. _String_. Name of the catalog source for installing the lifecycle-agent operator. Default: `'redhat-operators'`.

## Example Playbook

```yaml

- hosts: servers

  roles:
    - ocp_lca
```

## License

MIT / BSD

## Author Information

* **Manuel Lorenzo** (<mlorenzofr@redhat.com>) (2026-)
