#!/bin/bash

function usage {
  echo "Usage: $0 [-h] [-i] <version> [server]"
  echo "  -h       Show this help message"
  echo "  -i       Allow insecure connection to the server"
  echo "  version: Openshift version"
  echo "  server:  Address of a registry server with images"
  echo -e "\nExamples:"
  echo "${0} 4.18.3-x86_64"
  echo "${0} -i 4.17.0-ec.0-x86_64 example.local.lab/openshift/release-images"
}

insecure=""

while getopts "hi" opt; do
  case "${opt}" in
    "h")
      usage
      exit 0
      ;;
    "i")
      insecure="--insecure=true"
      ;;
    "*")
      usage
      exit 1
      ;;
  esac
done

# Delete non-operands
shift $((OPTIND - 1))

# Collect remaining positional arguments
version="$1"
registry="${2:-quay.io/openshift-release-dev/ocp-release}"

if [ -z "${version}" ]; then
  echo -e "Empty version\n"
  usage
  exit 1
fi

while read -r image; do
  crictl images --digests --no-trunc | grep -q "${image}" || echo "${image} not found"
done < <(oc adm "${insecure}" release info "${registry}:${version}" --output=json \
           | jq "[.references.spec.tags[] | .from.name]" \
           | grep quay \
           | tr -d '",' \
           | awk '{ print $1 }' \
           | cut -d "@" -f2)
