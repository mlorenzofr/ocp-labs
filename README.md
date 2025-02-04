# Openshift Container Platform labs
This repository contains a series of ansible playbooks for creating and
 configuring Openshift labs in the Red Hat beaker environment.

## Using ansible
A containerized environment has been created with ansible to be able to launch
 the playbooks from a previously configured environment.  
This can be started using the script `run-ansible.sh`.
For older OS versions, such as RHEL8, an older version of Ansible is required. For those versions, use:
```shell
ANSIBLE_OS_DIST="-rhel8" ./run-ansible.sh
```

The environment uses several volumes which I use to host private information
 (GPG/SSH keys, passwords,...) this must be customized for each user's
 environment.

The `.user` directory contains environment variables, the bash history file and
 personal variables that we want to use in ansible.
```
.user/
├── env
├── history
└── vars.yml
```

## Examples
### 1st step
This creates the virtual machines and an Openshift installation.
* 3 node cluster. They all have master/worker roles.
```bash
ap playbooks/base/ctlplane.yml -e "start_install=true"
```
* standard cluster. 3 master nodes + 1 worker node.
```bash
ap playbooks/base/ocp.yml -e "start_install=true"
```
* sno. A **S**ingle **N**ode **O**penshift installation, in this case with ABI.
```bash
ap playbooks/base/sno.yml
```

### 2nd step
In a second step we can apply additional configurations to the environment.
* Hosted clusters installation.
```bash
ap playbooks/setups/hcp-calico.yml
```

### tasks
There are also a series of playbooks for specific tasks.
* Remove a lab:
```bash
ap playbooks/jobs/clean-lab.yml -e lab_name=standard
```
