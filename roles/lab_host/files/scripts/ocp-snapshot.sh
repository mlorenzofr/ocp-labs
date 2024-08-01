#!/bin/bash

set -euo pipefail

function vmlist() {
  virsh list | grep "$1-" | awk '{ print $2 }'
}

function create() {
  # Here we should add the bootstrap certificate rotation for Openshift clusters
  # younger than 1 day
  # ./kubelet-renew-certificates.sh

  while read -r domain; do
    virsh destroy "${domain}"
    virsh snapshot-create-as --domain "${domain}" \
                             --name snapshot-"$(date +'%Y%m%d%H%M')" \
                             --disk-only
    virsh start "${domain}"
  done < <(vmlist "${1}")
}

function revert() {
  while read -r domain; do
    virsh destroy "${domain}"
    while read -r vdisk file; do
      backing_file=$(qemu-img info -U "${file}" | awk '/^backing file:/ { print $3 }')
      if [ "x${backing_file}" != "x" ]; then
        virt-xml "${domain}" \
          --edit target="${vdisk}" \
          --disk path="${backing_file}"
        rm -f "${file}"
        while read -r snapshot; do
          virsh snapshot-delete --metadata "${domain}" "${snapshot}"
        done < <(virsh snapshot-list "${domain}" | awk '/snapshot-/ { print $1 }')
      fi
    done < <(virsh domblklist "${domain}" | awk '{ if ($1 ~ /^vd[a-z]/) { print $1" "$2 };}')
    virsh start "${domain}"
  done < <(vmlist "${1}")
}

function usage() {
  echo "Usage: ${0} [create|revert] <domain-base>"
  echo -e "\nCreate or revert a snapshot of an Openshift lab."
  echo "Example: ${0} create quay"
  exit 1
}

if [ $# -ne 2 ]; then
  usage
fi

case "${1}" in
  "revert") revert "${2}"
    ;;
  "create") create "${2}"
    ;;
  *) usage
esac
