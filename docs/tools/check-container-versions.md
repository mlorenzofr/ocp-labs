# Container version checker

Use `tools/check-container-versions.py` before updating `container/Containerfile`.
It compares pinned component versions with the latest upstream releases and verifies
that `ansible` and `ansible-lint` remain compatible.

The script checks these components:

* Alpine base image
* `ansible`
* `ansible-lint`
* `community.general`
* `kubectl`

## Setup

Create the dedicated virtual environment once:

```bash
python3 -m venv tools/.venv
tools/.venv/bin/pip install -r tools/requirements.txt
```

The script automatically re-executes itself with `tools/.venv/bin/python` when the
virtual environment exists.

## Usage

1. Create the virtual environment if it does not exist yet (see [Setup](#setup))
2. Activate the virtual environment:

   ```bash
   source tools/.venv/bin/activate
   ```

3. Run `./tools/check-container-versions.py`
4. Review the pinned vs latest table
5. Update `container/Containerfile` when newer compatible versions are available
6. Rebuild the Ansible container image with `./run-ansible.sh`
7. Deactivate the virtual environment when finished:

   ```bash
   deactivate
   ```
