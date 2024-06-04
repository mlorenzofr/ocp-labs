#!/bin/bash

set -euo pipefail

IMAGE="${1:-agent.x86_64.iso}"

if [ -f "${IMAGE}" ]; then
    TMPDIR="$(mktemp -d)"

    mount -o loop "${IMAGE}" "${TMPDIR}"
    zcat "${TMPDIR}"/images/ignition.img | cpio -idmv
    umount "${TMPDIR}"
    rmdir "${TMPDIR}"
else
    echo "${IMAGE} file not found."
fi
