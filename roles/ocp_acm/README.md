# ocp_acm

This role installs and configures **A**dvanced **C**luster **M**anagement (**ACM**) in an OpenShift cluster.

The role manages the installation of ACM, as well as the task of importing clusters (`ManagedClusters`) into the _Hub_ cluster.

## Requirements

None.

## Role Variables

* `ocp_acm_apply`. _Bool_. Set wether the role should apply manifests or simply create them.
* `ocp_acm_channel`. _String_. Operator subscription channel.
* `ocp_acm_ns`. _String_. Namespace for the Operator.
* `ocp_acm_path`. _String_. Path where the manifest files are saved.
* `ocp_acm_pullsecret`. _String_. Pull secret credentials for distribution registry.
* `ocp_acm_siteconfig`. _Bool_. Enable or disable `SiteConfig` component (ZTP).
* `ocp_acm_source`. _String_. Name of the `CatalogSource` to install ACM.
* `ocp_acm_default_addons`. _List_. List of `ManagedClusterAddons` to install on the _Spoke_ cluster by default.
* `ocp_acm_governance_addons`. _List_. List of Governance `ManagedClusterAddons`.

## Variables for the `import` task

* `cluster`. _String_. Cluster name.
* `addons`. _List_. List of `ManagedClusterAddons` to install on the _Spoke_ cluster.
* `cloud`. _String_. _Spoke_ cluster Cloud provider.
* `cluster_labels`. _Dict_. Dictionary with the `key:value` tags for the `ManagedCluster`.
* `cluster_set`. _String_. `ClusterSet` to which the `ManagedCluster` will belong.
* `cwd`. _String_. Working directory.
* `governance`. _Bool_. If set to **true**, adds Governance Addons to the _Spoke_ cluster.
* `kubeconfig`. _String_. Path to the _Spoke_ cluster kubeconfig file.
* `vendor`. _String_. _Spoke_ cluster Vendor.

## Examples

### Playbook

```yaml
- hosts: servers

  vars:
    ocp_acm_pullsecret: '{"auths":{<redacted>}}'

  roles:
    - ocp_acm
```

### Importing a cluster

```yaml
- name: 'Import external cluster'
  ansible.builtin.import_role:
    name: 'ocp_acm'
    tasks_from: 'import.yaml'
  vars:
    lab_name: 'acm'
    cluster: 'example'
    cwd: "{{ lab_path }}/{{ lab_name }}/{{ cluster }}/import"
    kubeconfig: '{{ lab_path }}/{{ lab_name }}/{{ cluster }}/auth/kubeconfig'
    governance: true
```

## License

MIT / BSD

## Author Information

 - **Manuel Lorenzo** (mlorenzofr@redhat.com) (2024-)
