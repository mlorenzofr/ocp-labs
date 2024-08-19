# ocp_acs
This role installs and configures **Advanced Cluster Security** on an Openshift cluster.

## Requirements
This role requires the `ocp_lvms` role for local storage.  
They will be installed automatically with this role.

## Role Variables
* `ocp_acs_central`. _Bool_. Enables creation of `central` resource in the cluster.
* `ocp_acs_install`. _Bool_. Set wether the role should apply manifests or simply create them.
* `ocp_acs_ns`. _String_. Namespace for the Operator.
* `ocp_acs_path`. _String_. Path where the manifest files are saved.
* `ocp_acs_secured_clusters`. _List_. List of `SecuredCluster` resources.
* `ocp_acs_subscription_channel`. _String_. Operator subscription channel.
* `ocp_acs_subscription_source`. _String_. Operator subscription source.
* `ocp_acs_subscription_version`. _String_. Operator subscription version.

### Variables for `ocp_acs_secured_clusters` elements
* `name`. _String_. Cluster name.
* `central`. _String_. `central` endpoint address for notifications.
* `admission_control_replicas`. _Number_. Number of replicas for admission control pod.
* `scanner_analyzer_scaling_autoscaling`. _Bool_. Enable/Disable autoscaling for `scanner/analyzer` component.
* `scanner_analyzer_scaling_max_replicas`. _Number_. Maximum number of replicas for `scanner/analyzer` component.
* `scanner_analyzer_scaling_min_replicas`. _Number_. Minimum number of replicas for `scanner/analyzer` component.
* `scanner_analyzer_scaling_replicas`. _Number_. Initial number of replicas for `scanner/analyzer` component.
* `scannerv4_indexer_scaling_autoscaling`. _Bool_. Enable/Disable autoscaling for `scannerv4/indexer` component.
* `scannerv4_indexer_scaling_max_replicas`. _Number_. Maximum number of replicas for `scannerv4/indexer` component.
* `scannerv4_indexer_scaling_min_replicas`. _Number_. Minimum number of replicas for `scanner4/indexer` component.
* `scannerv4_indexer_scaling_replicas`. _Number_. Initial number of replicas for `scannerv4/indexer` component.

## Example Playbook
```yaml
- hosts: servers

  vars:
    ocp_acs_install: true
    ocp_acs_path: '/home/labs/acs'

  roles:
    - ocp_acs
```

## License
MIT / BSD

## Author Information
 - **Manuel Lorenzo** (mlorenzofr@redhat.com) (2024-)
