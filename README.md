# Openshift Container Platform labs

This repository contains a series of ansible playbooks for creating and configuring OpenShift labs in the Red Hat Beaker environment. It provides automation for deploying various OpenShift configurations including standard clusters, SNO (Single Node OpenShift), hosted control planes, and specialized setups.

## Table of Contents

- [Quick Start](#quick-start)
- [Directory Structure](#directory-structure)
- [Ansible Container Environment](#ansible-container-environment)
- [Configuration](#configuration)
- [Usage Examples](#usage-examples)
- [Security](#security)

## Quick Start

1. Clone this repository
2. Set up your user configuration:
   ```bash
   cp docs/user/vars.yaml.example .user/vars.yml
   # Edit .user/vars.yml with your credentials and settings
   ```
3. Start the Ansible container environment:
   ```bash
   ./run-ansible.sh
   ```
4. Deploy a lab (inside the container):
   ```bash
   ap labs/std-slim/deploy.yaml
   ```

## Directory Structure

```
ocp-labs/
├── playbooks/          # Main playbooks organized by purpose
│   ├── base/           # Base cluster deployments (ctlplane, ocp, sno)
│   ├── beaker/         # Beaker infrastructure setup (server, dnsmasq, haproxy)
│   ├── jobs/           # Task-specific playbooks (clean-lab, etc.)
│   └── setup/          # Additional cluster configurations
├── labs/               # Lab definition files
│   ├── std-slim/       # Standard slim cluster configuration
│   ├── ztvp/           # Zero Trust Validated Pattern lab
│   ├── hcp/            # Hosted Control Plane configurations
│   ├── sno/            # Single Node OpenShift configurations
│   └── ...             # Other lab configurations
├── roles/              # Ansible roles for specific components
│   ├── lab/            # Lab infrastructure provisioning
│   ├── ocp_acm/        # Advanced Cluster Management
│   ├── ocp_hcp/        # Hosted Control Plane
│   ├── ocp_hive/       # Hive deployment
│   ├── haproxy/        # HAProxy load balancer
│   ├── dnsmasq/        # DNS/DHCP services
│   └── ...             # Other component roles
├── inventory/          # Ansible inventory configuration
├── container/          # Container build files for Ansible environment
├── docs/               # Documentation
│   └── user/           # User configuration examples
│       └── vars.yaml.example  # Template for user variables
├── .user/              # User-specific configuration (gitignored)
│   ├── env             # Environment variables
│   ├── history         # Bash history (persisted)
│   └── vars.yml        # User-specific Ansible variables
└── tools/              # Utility scripts (e.g., check-secrets.sh)
```

## Ansible Container Environment

This project uses a containerized Ansible environment to ensure consistent execution across different systems. The container includes all required Ansible collections, Python dependencies, and tools.

### Starting the Container

Use the `run-ansible.sh` script to start the Ansible container:

```bash
# Default (latest Ansible version)
./run-ansible.sh

# For RHEL8 compatibility (older Ansible version)
ANSIBLE_OS_DIST="-rhel8" ./run-ansible.sh
```

### Container Features

The container automatically mounts:
- **Project directory** (`/ansible`): Full access to playbooks and roles
- **SSH agent**: For accessing remote systems
- **Password store** (`~/.password-store`): For secret management via passwordstore
- **GPG keys** (`~/.gnupg`): For decrypting secrets
- **User configuration** (`.user/`): Your personal settings and history

### Inside the Container

Once inside the container, you can use the `ap` alias (short for `ansible-playbook`) to run playbooks:

```bash
# Check what would be executed (dry-run)
ap-chk playbooks/base/ocp.yml

# Run with specific tags
ap labs/ztvp/deploy.yaml --tags ocp

# Verbose output
ap playbooks/beaker/server.yaml --tags haproxy -vv
```

The container also includes:
- **Persistent bash history**: Located at `.user/history`
- **Pre-configured DNS**: Set to use internal DNS servers
- **SSH agent forwarding**: Use your host's SSH keys
- **Ansible SSH settings**: Configured via `.user/env`

## Configuration

### User Variables Setup

1. **Create your vars file from the template**:
   ```bash
   cp docs/user/vars.yaml.example .user/vars.yml
   ```

2. **Edit `.user/vars.yml`** with your credentials. The template includes:
   - **Pull Secret**: Download from [console.redhat.com](https://console.redhat.com/openshift/install/pull-secret)
   - **SSH Keys**: Your public SSH key for accessing cluster nodes
   - **Cloud Provider Credentials** (if using AWS/Nutanix):
     - AWS: Access key ID and secret access key
     - Nutanix: Prism Central/Element endpoints and credentials
   - **Beaker Configuration**: DNS servers, domains
   - **Repository URLs**: Customize for your environment

3. **Environment variables** (`.user/env`):
   ```bash
   ANSIBLE_SSH_ARGS="-C -o ControlMaster=auto -o ControlPersist=60s"
   ```

### Secret Management

You have multiple options for managing secrets in `.user/vars.yml`:

**Option 1: Direct values** (simple but less secure):
```yaml
lab_pull_secret_str: '{"auths":{"cloud.openshift.com":{"auth":"YOUR_TOKEN"}}}'
lab_aws_secret_access_key: 'your-aws-secret-key'
```

**Option 2: External files**:
```yaml
lab_pull_secret_str: "{{ lookup('file', '/secure/path/pull-secret.json') }}"
```

**Option 3: Secret management tools** (most secure, recommended):
```yaml
# Using passwordstore
lab_pull_secret_str: "{{ lookup('community.general.passwordstore', 'path/to/secret') | string }}"

# Using Ansible Vault
lab_aws_secret_access_key: "{{ vault_aws_secret }}"
```

**Important**: The `.user/` directory is gitignored to prevent accidentally committing secrets.

### Lab Definitions

Lab configurations are stored in the `labs/` directory. Each lab typically contains:
- `deploy.yaml`: Main deployment playbook
- Configuration files specific to that lab type

Example lab structures:
- `labs/std-slim/`: Standard slim OpenShift cluster
- `labs/ztvp/`: Zero Trust Validated Pattern deployment
- `labs/hcp/`: Hosted Control Plane configurations

## Usage Examples

### Base Cluster Deployments

These playbooks create virtual machines and perform OpenShift installation:

**Compact 3-node cluster** (all nodes have master/worker roles):
```bash
ap playbooks/base/ctlplane.yml -e "start_install=true"
```

**Standard cluster** (3 master nodes + 1 worker node):
```bash
ap playbooks/base/ocp.yml -e "start_install=true"
```

**Single Node OpenShift (SNO)** with Agent-Based Installer:
```bash
ap playbooks/base/sno.yml
```

### Infrastructure Setup

Configure Beaker infrastructure components:

**DNS and DHCP services** (dnsmasq):
```bash
ap playbooks/beaker/server.yaml --tags dnsmasq
```

**HAProxy load balancer**:
```bash
ap playbooks/beaker/server.yaml --tags haproxy
```

### Lab Management

**Deploy a specific lab**:
```bash
ap labs/std-slim/deploy.yaml
```

**Clean up a lab**:
```bash
ap labs/std-slim/deploy.yaml --tags clean
```

### Common Workflow Example

1. Start the Ansible container:
   ```bash
   ./run-ansible.sh
   ```

2. Deploy the hub cluster:
   ```bash
   ap labs/ztvp/deploy.yaml --tags ztvp-hub
   ```

### Useful Tips

- Use `ap-chk` instead of `ap` for dry-run mode (check mode)
- Add `-vv` or `-vvv` for verbose output during troubleshooting
- Use `--tags` to run only specific parts of a playbook
- Your bash history is persisted in `.user/history` for reference

## Security

This repository uses [Gitleaks](https://github.com/gitleaks/gitleaks) to prevent committing secrets such as passwords, SSH keys, pull secrets, and other sensitive information.

### Quick Start

```bash
# Install pre-commit hooks (runs gitleaks automatically before each commit)
pip install pre-commit
pre-commit install

# Manual check for secrets
./tools/check-secrets.sh

# Check only staged files
./tools/check-secrets.sh --staged
```

### Important Security Notes

- **Never commit** `.user/vars.yml` - it contains your secrets
- Use `passwordstore` (pass) for managing sensitive data
- The `.user/` directory is in `.gitignore` by default
- Pre-commit hooks will block commits containing secrets

For detailed security guidelines, see [SECURITY.md](SECURITY.md).

## Troubleshooting

### Container Issues

**Container fails to build**:
```bash
# Force rebuild
podman rmi ansible-openshift
./run-ansible.sh
```

**Permission denied errors**:
- Check that volumes are properly labeled with `:Z` in `run-ansible.sh`
- Ensure SELinux context is correct

### Ansible Issues

**SSH connection failures**:
- Verify SSH agent is forwarded: `echo $SSH_AUTH_SOCK`
- Check SSH keys are loaded: `ssh-add -l`
- Verify `.user/env` contains correct `ANSIBLE_SSH_ARGS`

**Secret lookup failures**:
- Ensure `passwordstore` is set up on your host
- Verify GPG keys are accessible in the container
- Check GPG agent is running

**Playbook fails to find variables**:
- Verify `.user/vars.yml` exists and is mounted correctly
- Check variable names match those expected by the playbook
- Use `-vv` to see which variables are undefined
