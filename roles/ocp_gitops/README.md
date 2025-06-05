# ocp_gitops
This role installs and configures gitops operator on an Openshift cluster.

## Requirements

## Role Variables
* `ocp_gitops_apply`. _Bool_. Set wether the role should apply the manifests or simply create them.
* `ocp_gitops_bmc_password`. _String_. Default BMC password for ZTP secrets.
* `ocp_gitops_bmc_username`. _String_. Default BMC user for ZTP secrets.
* `ocp_gitops_channel`. _String_. Operator subscription channel.
* `ocp_gitops_console_ns`. _String_. Namespace for the gitops `ConsolePlugin`.
* `ocp_gitops_console_plugin`. _Bool_. Enable/Disable the `ConsolePlugin` installation.
* `ocp_gitops_console_port.` _Number_. Service port for the gitops `ConsolePlugin`.
* `ocp_gitops_ns`. _String_. Namespace for the Operator.
* `ocp_gitops_path`. _String_. Path where the manifest files are stored.
* `ocp_gitops_pull_secret`. _String_. Default value for _pull-secret_ for ZTP secrets.
* `ocp_gitops_secrets`. _List_. List of secrets for ZTP clusters.
* `ocp_gitops_source`. _String_. Name of the catalog source name for installing the gitops-operator.

### Variables for `ocp_gitops_secrets` elements
* `ns`. _String_. Namespace.
* `pull_secret_name`. _String_. Name of the pull-secret secret.
* `pull_secret`. _String_. Pull secret (base64 encoded).
* `nodes`. _List_. List of cluster nodes.
    * `hostname`. _String_. Node name.
    * `bmc_username`. _String_. BMC node username.
    * `bmc_password`. _String_. BMC node password.

## Example Playbook
```yaml
- hosts: servers

  roles:
    - ocp_gitops
```

## License
MIT / BSD

## Author Information
 - **Manuel Lorenzo** (mlorenzofr@redhat.com) (2025-)
