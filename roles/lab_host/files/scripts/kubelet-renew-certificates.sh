#!/bin/bash

# set -x

function node_exec() {
  local node
  node="${1}"
  shift
  ssh -o UserKnownHostsFile=/dev/null \
      -o StrictHostKeyChecking=no \
      -l core \
      "${node}" -- sudo "$@"
}

function cert_test() {
  node_exec "${1}" test -f "/var/lib/kubelet/pki/$2" || return 1
  node_exec "${1}" openssl x509 -checkend 2160000 -noout -in "/var/lib/kubelet/pki/$2"
}

function cert_purge() {
  node_exec "${1}" rm /var/lib/kubelet/pki/*
  node_exec "${1}" systemctl restart kubelet.service
}

function force_csr_renewal() {
  oc patch secret/"${2}" -n "${1}" \
    --type json \
    -p '[{ "op": "remove", "path": "/metadata/annotations/auth.openshift.io~1certificate-not-after" }]'
}

function cert_renew() {
    # Purge current certificates
    cert_purge "${1}"

    # Loop until the kubelet certs are valid for a month
    for i in {1..60}; do
        if ! cert_test "${1}" kubelet-client-current.pem ||
           ! cert_test "${1}" kubelet-server-current.pem; then
            oc get csr \
              -o go-template='{{range .items}}{{if not .status}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}' | \
              xargs --no-run-if-empty oc adm certificate approve
            sleep 10
        else
            break
        fi
    done

    if [ "${i}" -eq 60 ]; then
      echo "Error during certificate renewal on ${1}"
      exit 1
    fi
}

function cert_bootstrap() {
  oc get secret -A -o json \
    | jq -r '.items[] | select(.metadata.annotations."auth.openshift.io/certificate-not-after"
      | . != null and fromdateiso8601<='"$(date --date="+2day" +%s)"')
      | "\(.metadata.namespace) \(.metadata.name)"'
}

while [ "$(cert_bootstrap | wc -l)" -ne 0 ]; do
  while read -r ns secret; do
    force_csr_renewal "${ns}" "${secret}"
    sleep 10
  done < <(cert_bootstrap)

  # Wait some time for the servica-ca renewal
  sleep 60
done

oc adm wait-for-stable-cluster --minimum-stable-period=30s

for node in $(oc get nodes --no-headers | awk '{ print $1 }'); do
  cert_renew "${node}"
done
