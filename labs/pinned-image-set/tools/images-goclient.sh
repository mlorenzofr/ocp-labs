#!/bin/bash

# This script shows if the images are pinned (present) in the PinnedImageSet and
# prints the image information

# The image hashes were obtained from the nginx access log in the registry server.

declare -a images
images+=( "7d18e2c825800a1f2d537892a218af788b6f2ff138d9934ab0d4166b4f67e2b8" ) # cli
images+=( "f6a5ded58f4c38faad42c41a6d69544cea73438e27d0ed23f0b6a0f11f138186" ) # cli-artifacts
images+=( "2bd9217f72799dc88a6edc54484c04408c8af23945d3116e8f8c866d4965db36" ) # installer
images+=( "3d8be39f766c1bb08ca432376d13d6b087164c6c43cd90d9cd6d08b779880ea7" ) # installer-artifacts
images+=( "14ef0b50e63713e0c2e9012f5a3cb0bef21a242a949f6fc2669dbfb50e30eb23" ) # tests
images+=( "29cdf4ea485ce943c85cf69178cc307c185cf4341cdfd5cffa140bd9c3529bff" ) # tools
images+=( "ea52c9d88e57ce1dd2e355f8020eac95e6b5d1431ba213526cef6e6ca15173c6" ) # must-gather
images+=( "77b7e4d87dd1e0ba6e6c81806d2c2b0d805b8cdaca0c794ec92c628c123dc5a6" ) # oauth-proxy
images+=( "e82df1a8e8f468c0aed0a0223daeb2407d9e44e1c7fff3e74ea60d0abc9b8037" ) # network-tools

for img in "${images[@]}"; do
  echo -e "========================================="
  grep -q "${img}" /root/labs/pinnedis/config/pinned-image-set.yaml && echo "$img is pinned" || echo "$img is NOT pinned"
  skopeo inspect docker://pinnedis-registry.pinnedis.local.lab/openshift/release@sha256:"${img}" \
    | jq '.Labels | .name, ."com.redhat.component", ."io.k8s.display-name", ."io.openshift.maintainer.component", ."io.openshift.build.source-location"'
  echo -e "========================================="
done
