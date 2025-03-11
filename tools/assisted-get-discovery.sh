#!/bin/bash

if [ $# -lt 1 ]; then
  echo "Usage: ${0} <infraenv-name> [namespace]"
  echo "Get the discovery ignition file from assisted-service API."
  exit 1
fi

infraEnvName="${1}"
ns="${2:-assisted-installer}"

token=$(oc get infraenv -n "${ns}" "${infraEnvName}" -o json | jq -r '.status.isoDownloadURL' | cut -d / -f 5)
host=$(oc get route -n "${ns}" assisted-service -o json | jq -r '.spec.host')
infraEnvID=$(oc get infraenv -n "${ns}" "${infraEnvName}" -o json | jq -r '.status.bootArtifacts.initrd' | cut -d / -f 5)

echo "Save discovery.ign file to ignition.json"
curl -k -o ignition.json "https://${host}/api/assisted-install/v2/infra-envs/${infraEnvID}/downloads/files?file_name=discovery.ign&api_key=${token}"
