# ocp_olm

This role manages **O**perator **L**ifecycle **M**anager (**OLM**) tasks in an OpenShift Cluster.

## Requirements

None.

## Role Variables

* `ocp_olm_apply`. _Bool_. Set wether the role should apply the manifests or simply create them.
* `ocp_olm_check_sources`. _Bool_. Enable validation of `CatalogSource` status before creating a subscription.
* `ocp_olm_path`. _String_. Path where manifest files are stored.
* `ocp_olm_disablealldefaultsources`. _Bool_. Set wether the default OpenShift `CatalogSources` should be enabled or not.

### Variables for `Subscription` (v0) elements

* `channel`. _String_. Name of the catalog channel used to install the operator.
* `csv`. _String_. Install the specific version set in this variable.
* `global`. _Bool_. Set wether the operator should work in global mode (no `targetNamespace`) or not.
* `monitoring`. _Bool_. Set wether the resources in the `Namespace` should be monitored.
* `ns`. _String_. Namespace for OLM resources used for the installation.
* `operator_name`. _String_. Name of the operator in the catalog.
* `operator_group`. _String_. Name of the `OperatorGroup` resource.
* `privileged`. _Bool_. Set wether pods in the `Namespace` should run in privileged mode.
* `source`. _String_. Name of the catalog source to install the operator.
* `source_ns`. _String_. Namespace of the catalog source.
* `subscription_name`. _String_. Name of the `Subscription` resource.
* `wait_for`. _List_. List of the subscription names whose will be awaited to consider the subscription ready.

### Variables for `ConsolePlugin` elements

* `name`. _String_. Name of the `ConsolePlugin` resource.
* `display_name`. _String_. Display name for the console plugin. Defaults to the value of `name` if not specified.
* `ns`. _String_. Namespace where the console plugin service is running.
* `port`. _Integer_. Port number where the console plugin service is exposed.
* `service_name`. _String_. Name of the service for the console plugin. Defaults to the value of `name` if not specified.
* `base_path`. _String_. Base path for the console plugin service. Defaults to `/` if not specified.

## Example Playbook

### Creating an Operator Subscription

```yaml
- hosts: servers

  tasks:
    - name: 'Create operator subscription manifest'
      ansible.builtin.include_role:
        name: 'ocp_olm'
        tasks_from: 'subscription.yaml'
      loop:
        - name: 'example-operator'
          ns: 'olm-example'
          operator_group: 'example-operatorgroup'
          source: 'community-operators'
      tags: ['olm']
```

### Creating a ConsolePlugin

```yaml
- hosts: servers

  tasks:
    - name: 'Create ConsolePlugin manifest'
      ansible.builtin.include_role:
        name: 'ocp_olm'
        tasks_from: 'console_plugin.yaml'
      loop:
        - name: 'gitops-plugin'
          display_name: 'GitOps Plugin'
          ns: 'openshift-gitops'
          port: 9001
      tags: ['console']
```

## License

MIT / BSD

## Author Information

* **Manuel Lorenzo** (<mlorenzofr@redhat.com>) (2025-)
