# Security Guidelines

This document outlines security practices for the ocp-labs repository, particularly around preventing secrets leakage.

## Secrets Detection with Gitleaks

This repository uses [Gitleaks](https://github.com/gitleaks/gitleaks) to prevent committing sensitive information such as:

- Pull secrets and Docker registry credentials
- SSH keys (both public and private)
- Passwords and authentication tokens
- OpenShift authentication tokens
- AWS credentials
- Personal email addresses used as usernames
- BMC credentials

### Pre-commit Hook

Gitleaks runs automatically via pre-commit hooks. To install the hooks:

```bash
pip install pre-commit
pre-commit install
```

Now gitleaks will scan your changes before every commit.

### Manual Scanning

To manually scan the repository for secrets:

```bash
# Using podman (recommended)
podman run --rm -v .:/repo:z ghcr.io/gitleaks/gitleaks:v8.30.1 \
  detect --source=/repo --config=/repo/.gitleaks.toml --no-git

# If gitleaks is installed locally
gitleaks detect --config=.gitleaks.toml --no-git
```

### Configuration Files

- **`.gitleaks.toml`**: Main configuration file with custom rules for OpenShift/Ansible patterns
- **`.gitleaksignore`**: Contains fingerprints of known false positives to ignore
- **`.pre-commit-config.yaml`**: Pre-commit hook configuration

### Custom Rules

The gitleaks configuration includes custom rules tailored for OpenShift environments:

1. **dockerconfigjson-secret**: Detects actual dockerconfigjson secrets (not Jinja2 templates)
2. **pullsecret-value**: Detects hardcoded pull secrets
3. **ssh-private-key**: Detects SSH private keys
4. **ssh-public-key-value**: Detects hardcoded SSH public keys (not variable references)
5. **hardcoded-username**: Detects personal email addresses used as usernames
6. **ansible-vault-password**: Detects plain text passwords in Ansible variables
7. **openshift-kubeconfig**: Detects kubeconfig with actual credentials
8. **openshift-token**: Detects OpenShift authentication tokens
9. **aws-credentials**: Detects AWS credentials for OpenShift AWS deployments
10. **redhat-pull-secret**: Detects Red Hat pull secrets with auth tokens
11. **bmc-credentials**: Detects BMC credentials

### Allowlisted Patterns

The following patterns are allowed and won't trigger alerts:

- Jinja2/Ansible variable templates: `{{ variable_name }}`
- Shell variables: `${VARIABLE}`
- Files in `.user/` directory (gitignored)
- Files in `secrets/` directory (gitignored)
- Default/placeholder passwords like `ADMIN` or `changeme`
- Redacted values: `<redacted>`
- Role defaults in `roles/*/defaults/main.yml`

### Handling False Positives

If gitleaks flags something that isn't actually a secret:

1. **Preferred**: Update the allowlist in `.gitleaks.toml` if it's a pattern that should always be allowed
2. **Last resort**: Add the specific fingerprint to `.gitleaksignore`

To get the fingerprint:

```bash
gitleaks detect --config=.gitleaks.toml --no-git -v 2>&1 | grep Fingerprint
```

### Best Practices

1. **Never commit actual secrets**: Use Ansible variables, environment variables, or external secret management
2. **Use `.user/` directory**: Store personal/sensitive configuration in `.user/` (already gitignored)
3. **Use placeholders**: In role defaults, use values like `changeme`, `ADMIN`, or empty strings
4. **Template everything**: Use Jinja2 templates for all sensitive values
5. **Review changes**: Always review your changes before committing

### Emergency: Secret Already Committed

If you accidentally committed a secret:

1. **Rotate the secret immediately**: Change passwords, regenerate tokens, etc.
2. **Remove from history**: Use `git filter-branch` or `BFG Repo-Cleaner` to remove from history
3. **Force push**: After cleaning history (coordinate with team first!)
4. **Verify**: Run a full gitleaks scan to confirm removal

### Bypassing Gitleaks (NOT RECOMMENDED)

In rare cases where you need to bypass gitleaks (e.g., committing an intentionally safe example):

```bash
# Skip pre-commit hooks (use with extreme caution!)
git commit --no-verify -m "Your message"
```

**WARNING**: Only use `--no-verify` when you're absolutely certain the content is safe.

## Pattern Reference

The grep pattern used for detection:
```
dockerconfigjson|pass|user|pull|ssh|auth|ecret
```

This pattern helps identify potential secret leaks in:
- Docker/Kubernetes config JSON (dockerconfigjson)
- Passwords (pass)
- Usernames (user)
- Pull secrets (pull)
- SSH keys (ssh)
- Authentication tokens (auth)
- Generic secrets (ecret - catches 'secret', 'secrets', etc.)

## Questions or Issues?

If you encounter issues with the gitleaks configuration or have questions about security practices, please:

1. Review this documentation
2. Check `.gitleaks.toml` for current rules
3. Consult with the team
4. Open an issue for discussion
