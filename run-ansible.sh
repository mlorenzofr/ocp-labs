#!/usr/bin/env bash

set -euo pipefail

PROJECT="openshift"
CONTAINER_NAME="ansible-${PROJECT}"

# Here we have our personal settings (ANSIBLE_SSH_ARGS)
# shellcheck disable=SC1091
source .user/env

if ! podman images -n | grep -q "${PROJECT}"; then
  echo "Building ansible image ..."
  podman build \
    --build-arg UID="$(id -u)" \
    -t "${CONTAINER_NAME}" \
    -f container/Containerfile .
fi

echo "Running ${CONTAINER_NAME} ..."
# Volumes must be relabeled (:Z) to avoid access problems with selinux
podman run --rm -it \
  --security-opt label=disable \
  --name "${CONTAINER_NAME}" \
  -h "${CONTAINER_NAME}" \
  -v "${PWD}:/ansible:Z" \
  -v "$SSH_AUTH_SOCK:/ssh-agent" \
  -v ~/.password-store:/root/.password-store \
  -v ~/.gnupg:/root/.gnupg \
  -v "${PWD}/.user/history:/root/.bash_history_ansible" \
  -v "${PWD}/.user/vars.yml:/ansible/inventory/group_vars/all/user.yml" \
  --env SSH_AUTH_SOCK=/ssh-agent \
  --env ANSIBLE_SSH_ARGS="${ANSIBLE_SSH_ARGS}" \
  --dns 10.45.248.15 \
  "${CONTAINER_NAME}"
