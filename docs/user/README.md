# User Configuration Guide

This directory contains user configuration templates and documentation for setting up your personal environment to work with ocp-labs.

## Quick Setup

```bash
# Copy the template to your user directory
cp docs/user/vars.yaml.example .user/vars.yml

# Edit with your credentials
vim .user/vars.yml  # or use your preferred editor
```

## vars.yaml.example

This template file provides a starting point for your `.user/vars.yml` configuration. It includes:

### Required Variables

- **OpenShift Pull Secret**: Required for downloading OpenShift images
  - Get from: https://console.redhat.com/openshift/install/pull-secret
  - Can be stored as direct value, in a file, or in a secret manager

- **SSH Public Keys**: Required for accessing cluster nodes
  - Standard key: `lab_ssh_pubkey`
  - FIPS-compatible key: `lab_ssh_pubkey_fips`

### Optional Variables by Platform

**AWS** (if deploying to AWS):
- `lab_aws_dns_domain`
- `lab_aws_access_key_id`
- `lab_aws_secret_access_key`
- `lab_aws_region`

**Nutanix** (if deploying to Nutanix):
- `nutanix_prism_central`
- `nutanix_prism_element`
- `nutanix_user`
- `nutanix_password`
- `nutanix_cluster`
- `nutanix_network`
- `nutanix_csi_storage_container`

**Beaker** (if using Red Hat Beaker):
- `beaker_domains`
- `beaker_dns_servers`
- `rh_repo`
- `beaker_repo`

### Variable Naming Conventions

The template uses placeholder values that should be replaced:

- `X.X.X.X` - Replace with actual IP addresses
- `example.com` - Replace with your domain names
- `YOUR_*` - Replace with your actual credentials
- `BASE64_ENCODED_*` - Replace with base64-encoded values
- `your-*` - Replace with your specific configuration values

### Secret Management Options

The template shows multiple approaches for handling secrets:

1. **Direct Values** (least secure, simplest):
   ```yaml
   lab_pull_secret_str: '{"auths":{...}}'
   ```

2. **File Lookups** (recommended):
   ```yaml
   lab_pull_secret_str: "{{ lookup('file', '/path/to/secret') }}"
   ```

3. **Secret Management Tools** (most secure):
   ```yaml
   # passwordstore
   lab_pull_secret_str: "{{ lookup('community.general.passwordstore', 'path/to/secret') }}"

   # Ansible Vault
   lab_aws_secret: "{{ vault_aws_secret }}"
   ```

## Important Security Notes

- **Never commit** `.user/vars.yml` to version control
- The `.user/` directory is gitignored by default
- Consider using external secret management for production environments
- Keep backup copies of your configuration in a secure location

## Minimal Configuration Example

For a simple Beaker-based deployment, you minimally need:

```yaml
# .user/vars.yml
---
# Pull secret from Red Hat
lab_pull_secret_str: '{"auths":{...}}'

# Your SSH public key
lab_ssh_pubkey: 'ssh-ed25519 AAAA... user@host'

# Beaker configuration
beaker_domains:
  - 'your.lab.domain'
beaker_dns_servers:
  - {base: 'your.domain', address: '10.0.0.1'}
```

## Environment Variables

In addition to `vars.yml`, configure your shell environment in `.user/env`:

```bash
# .user/env
ANSIBLE_SSH_ARGS="-C -o ControlMaster=auto -o ControlPersist=60s"
```

This file is sourced by the Ansible container and can include other environment-specific settings.

## Getting Help

If you're unsure about a specific variable:

1. Check the comments in `vars.yaml.example`
2. Look at playbook/role documentation in the main repository
3. Search for variable usage: `grep -r "variable_name" roles/ playbooks/`
4. Review the main [README.md](../../README.md) for more context
