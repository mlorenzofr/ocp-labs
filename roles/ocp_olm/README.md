# ocp_olm
This role manages Operator Lifecycle Manager (**OLM**) tasks in an Openshift Cluster.

## Requirements
None.

## Role Variables
* `ocp_olm_apply`. _Bool_. Set wether the role should apply the manifests or simply create them.
* `ocp_olm_check_sources`. _Bool_. Enable validation of `CatalogSource` status before creating a subscription.
* `ocp_olm_path`. _String_. Path where manifest files are stored.
* `ocp_olm_disablealldefaultsources`. _Bool_. Set wether the default Openshift `CatalogSources` should be enabled or not.

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

## Example Playbook
```yaml
- hosts: servers

  tasks:
    - name: 'Create LVM installation manifest'
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

## License
MIT / BSD

## Author Information
 - **Manuel Lorenzo** (mlorenzofr@redhat.com) (2025-)
