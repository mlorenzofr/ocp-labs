#!/bin/bash

registry="$1"
version="$2"

while read -r image; do
  crictl images --digests --no-trunc | grep -q "${image}" || echo "${image} not found"
done < <(oc adm --insecure=true release info "${registry}/openshift/release-images:${version}" --output=json \
           | jq "[.references.spec.tags[] | .from.name]" \
           | grep quay \
           | tr -d '",' \
           | awk '{ print $1 }' \
           | cut -d "@" -f2)
