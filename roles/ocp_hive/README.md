# ocp_hive
This role installs (optional) and configures **Hive** operator.  
Hive is usually installed with **MCE**/**ACM** and the main task in this role is to configure it.  
If we want, it is also possible to install the operator using this role.  

## Requirements
This role uses the `ocp_baremetal` role for infrastructure resources.  

## Role Variables
* `ocp_hive_dnsmasq_root`. _String_. dnsmasq base directory.
* `ocp_hive_channel`. _String_. Operator subscription channel.
* `ocp_hive_clusters`. _List_. 
* `ocp_hive_clusterimagesets`. _List_. 
* `ocp_hive_install`. _Bool_. Set wether the role should apply manifests or simply create them.
* `ocp_hive_lab_name`. _String_. Lab name.
* `ocp_hive_ns`. _String_. Namespace for the Operator.
* `ocp_hive_operator`. _Bool_. Set to `True` to install the Hive operator.
* `ocp_hive_path`. _String_. Path where the manifest files are saved.
* `ocp_hive_source`. _String_. CatalogSource name to get the operator.

### Variables for `ocp_hive_clusters` elements
* `name`. _String_. 
* `ns`. _String_. 
* `pullsecret`. _String_. 
* `image`. _String_. 
* `network_type`. _String_. 
* `cluster_network`. _String_. 
* `service_network`. _String_. 
* `host_network`. _String_. 
* `masters`. _Number_. 
* `workers`. _Number_. 
* `sshkey`. _String_. 
* `domain`. _String_. 

### Variables for `ocp_hive_clusterimagesets` elements
* `name`. _String_. 
* `image`. _String_. 
* `visible`. _Bool_. 
* `channel`. _String_. 

## Example Playbook
```yaml
- hosts: servers

  vars:
    ocp_hive_install: true
    ocp_hive_path: '/home/labs/hive'

  roles:
    - ocp_hive
```

## License
MIT / BSD

## Author Information
 - **Manuel Lorenzo** (mlorenzofr@redhat.com) (2024-)
