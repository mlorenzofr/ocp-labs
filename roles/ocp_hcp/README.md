# ocp_hcp
This role installs (optional) and configures **Hosted Clusters** (AKA **Hypershift)**.

## Requirements
This role requires the following roles:
* **ocp_assisted_service**, for managing infrastructure resources.
* **ocp_metallb**, to enable communication between clusters.
* **dnsmasq**, to create DNS records for the Hosted Clusters.

## Role Variables
* `ocp_hcp_apply`. _Bool_. Set wether the role should apply manifests or simply create them.
* `ocp_hcp_clusters`. _List_. List of `Hosted Clusters` and their configuration.
* `ocp_hcp_kubeapi_ips`. _List_. List of IP addresses available for the kubeapi `LoadBalancer`.
* `ocp_hcp_kubeapi_name`. _String_. Name for the `IPAddressPool` (_metallb_) used by the kubeapi `LoadBalancers`.
* `ocp_hcp_lab_name`. _String_. Lab name.
* `ocp_hcp_path`. _String_. Path where the manifest files are saved.
* `ocp_hcp_pullsecret`. _String_. Default value for _pull-secret_ on `hostedclusters`.
* `ocp_hcp_ssh_key`. _String_. Default value for _sshAuthorizedKey_ on `hostedclusters`.

### Variables for `ocp_hcp_clusters` elements
* `name`. _String_. Cluster name.
* `ns`. _String_. Cluster namespace.
* `ctl_availability`. _String_. Controller Availability Policy. It could be `SingleReplica`or `HighlyAvailable`.
* `infra_availability`. _String_. Infrastructure Availability Policy. It could be `SingleReplica`or `HighlyAvailable`.
* `image`. _String_. Container image used for the installation.
* `version`. _String_. Openshift release version used for the installation.
* `arch`. _String_. Architecture used for the installation.
* `pullsecret`. _String_. Personal pull secret, in base64 format.
* `cluster_network`. _String_. Hosted cluster internal network CIDR.
* `service_network`. _String_. Hosted Cluster service network CIDR.
* `network_type`. _String_. Network type used (`OVNKubernetes|Calico|Other`).
* `agent_ns`. _String_. Namespace where the agent is installed.
* `ssh_key`. _String_. Personal SSH public key.
* `domain`. _String_. Hosted cluster base domain.
* `replicas`. _Number_. Number of node replicas.
* `lb`. _String_. Hub cluster IP address. Required for management.

## Example Playbook
```yaml
- hosts: servers

  vars:
    ocp_hcp_install: true
    ocp_hcp_path: '/home/labs/hcp'

    ocp_hcp_kubeapi_ips: ['192.168.0.40-192.168.0.45']
    ocp_assisted_service_infraenvs:
      - name: 'inventory'
        ns: 'inventory'
        hypershift: true
        ntp: ['192.168.0.1']
        redfish: '192.168.0.1'
        inventory:
          - {'name': 'hcp1-worker-1', 'id': '51'}

    ocp_hcp_clusters:
      - name: 'hcp1'
        ns: 'hcp1'
        ctl_availability: 'HighlyAvailable'
        infra: 'inventory'
        agent_ns: 'inventory'
        version: '4.14.8'
        service_network: '172.32.0.0/16'
        domain: 'local.lab'
        lb: '192.168.0.50'
        replicas: 1

  roles:
    - ocp_hcp
```

## License
MIT / BSD

## Author Information
 - **Manuel Lorenzo** (mlorenzofr@redhat.com) (2024-)
