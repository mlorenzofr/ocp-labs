#!/bin/bash

# This script finds and displays pods with a imagePullPolicy other than
# IfNotPresent in an Openshift Cluster.

while read -r ns pod; do
  oc get pod -n "${ns}" "${pod}" -o json \
    | jq -r '.spec.containers | .[].imagePullPolicy' \
    | grep -v IfNotPresent && echo "${ns}/${pod}"
done < <(oc get pods -A | grep -v NAMESPACE | awk '{ print $1" "$2 }')
