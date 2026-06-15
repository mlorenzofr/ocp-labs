# lab_host

This role is used to configure a Beaker machine and get it ready to deploy OpenShift labs using libvirt.

## Requirements

* RHEL 8 or RHEL 9 based system
* Sufficient resources for running virtual machines (CPU, memory, storage)

## Role Variables

### General Variables

* `lab_host_aws`. _Bool_. Enable AWS credentials configuration. Defaults to `true`.
* `lab_host_dhcp_lease`. _String_. DHCP lease time configuration. Defaults to `'24h'`.
* `lab_host_dhcp_netmask`. _String_. DHCP netmask configuration. Defaults to `'255.255.255.0'`.
* `lab_host_helm_version`. _String_. Helm version to install. Defaults to `'3.15.2'`.
* `lab_host_hide_secrets`. _Bool_. Hide sensitive data in logs. Defaults to `True`.
* `lab_host_kustomize_version`. _String_. Kustomize version to install. Defaults to `'5.4.2'`.
* `lab_host_kustomize_reinstall`. _Bool_. Force reinstall of kustomize. Defaults to `False`.
* `lab_host_squid_networks`. _List_. Networks allowed in squid proxy configuration. Defaults to `lab_host_networks`.
* `lab_host_networks`. _List_. List of networks to configure. Defaults to `[]`.
* `lab_host_ocp_mirror`. _String_. OpenShift mirror URL. Defaults to `'https://mirror.openshift.com/pub/openshift-v4'`.
* `lab_host_ocp_versions`. _List_. List of OpenShift versions to install. Defaults to `[]`.
* `lab_host_oc_source`. _String_. OpenShift client source tarball name. Defaults to `'openshift-client-linux.tar.gz'`.
* `lab_host_packages`. _List_. Additional packages to install. Defaults to `[]`.
* `lab_host_repos`. _List_. Additional software repositories to configure. Defaults to `[]`.
* `lab_host_rh_release`. _String_. Red Hat release version. Defaults to `'9.5.0'`.

### Variables for `lab_host_repos` items

* `name`. _String_. Repository name.
* `baseurl`. _String_. Repository base URL.
* `description`. _String_. Repository description. Defaults to the value of `name` if not specified.
* `enabled`. _Bool_. Enable or disable the repository. Defaults to `true`.
* `gpgcheck`. _Bool_. Enable GPG check for packages. Defaults to `false`.
* `skip_if_unavailable`. _Bool_. Skip repository if unavailable. Defaults to `false`.

### Variables for `lab_host_ocp_versions` items

* `version`. _String_. OpenShift version to install (e.g., `'4.16.0'`).
* `state`. _String_. Installation state (`'present'` or `'absent'`). Defaults to `'present'`.

### AWS Configuration Variables

These variables are used when `lab_host_aws` is enabled:

* `lab_aws_access_key_id`. _String_. AWS access key ID.
* `lab_aws_secret_access_key`. _String_. AWS secret access key.
* `lab_aws_region`. _String_. AWS region. Defaults to `'us-east-1'`.
* `lab_aws_output`. _String_. AWS CLI output format. Defaults to `'json'`.

### Container Registry Variables

* `lab_pull_secret`. _String_. Container pull secret for registry authentication.

## Dependencies

None.

## What This Role Does

This role performs the following tasks:

1. **Software Repositories**: Configures custom YUM/DNF repositories.
2. **Package Installation**: Installs required system packages and Python packages.
3. **Service Configuration**: Configures and manages:
   * libvirt and related services (qemu, network, storage, etc.)
   * chronyd (NTP)
   * squid (HTTP proxy)
   * firewalld (disabled)
4. **Development Tools**: Installs and configures:
   * kcli (Kubernetes/OpenShift cluster management)
   * ksushy (Redfish BMC emulator)
   * helm (Kubernetes package manager)
   * kustomize (Kubernetes configuration management)
   * OpenShift CLI tools (oc, kubectl, openshift-install, oc-mirror)
5. **Container Configuration**: Sets up container registry authentication.
6. **AWS Configuration**: Configures AWS credentials (optional).
7. **Utility Scripts**: Deploys helper scripts for cluster management.

## Example Playbook

### Basic Usage

```yaml
- hosts: servers

  roles:
    - 'lab_host'
```

### Advanced Configuration

```yaml
- hosts: servers

  vars:
    lab_host_ocp_versions:
      - version: '4.16.0'
        state: 'present'
      - version: '4.15.0'
        state: 'present'
    lab_host_packages:
      - 'vim-enhanced'
      - 'tmux'
    lab_host_networks:
      - '192.168.125.0/24'
      - '192.168.126.0/24'
    lab_pull_secret: "{{ lookup('file', '~/.pull-secret.json') }}"
    lab_aws_access_key_id: 'AKIAIOSFODNN7EXAMPLE'
    lab_aws_secret_access_key: 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY'

  roles:
    - 'lab_host'
```

### Installing Multiple OpenShift Versions

```yaml
- hosts: servers

  vars:
    lab_host_ocp_versions:
      - version: '4.16.9'
        state: 'present'
      - version: '4.15.4'
        state: 'present'
      - version: '4.14.0'
        state: 'absent'

  roles:
    - 'lab_host'
  tags: ['oc']
```

## License

MIT / BSD

## Author Information

* **Manuel Lorenzo** (<mlorenzofr@redhat.com>) (2024-)
