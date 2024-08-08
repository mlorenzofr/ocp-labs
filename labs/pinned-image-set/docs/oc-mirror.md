# registry mirroring
For this lab we will work with an internal registry. To retrieve the OCI images  
 from the external registries we will use the `oc-mirror` tool.

## binary rebuild
Unfortunately, this tool only works with stable Openshift registries, used by OCP  
 and OKD. Therefore, we have had to rebuild the binary by replacing the OCP  
 Cincinnati graph address with its CI counterpart. These changes can be found in 
 the branch  [ci-releases](https://github.com/mlorenzofr/oc-mirror/tree/ci-releases)  
 of my personal `oc-mirror` fork.
```shell
$ git clone git@github.com:mlorenzofr/oc-mirror.git
$ cd oc-mirror
$ git checkout ci-releases

$ podman build -f Dockerfile -t local/oc-mirror-build .
$ podman run -it --rm --privileged --net slirp4netns:enable_ipv6=false -v ${PWD}:/build:Z local/oc-mirror-build

$ cp bin/oc-mirror /usr/local/bin/oc-mirror-mod
$ update-alternatives --install /usr/local/bin/oc-mirror oc-mirror /usr/local/bin/oc-mirror-mod 10
$ update-alternatives --config oc-mirror
```

## Configuration file
The mirror configuration is managed by a CR `ImageSetConfiguration`.  
It's not strictly necessary, but for our testing and to provide support for original and upgrade versions, we will include fixed versions for 4.16 and 4.17.  
The `oc-mirror` downloads all versions between _minversion_ and _maxversion_ (only the last version if the parameters are omitted). We set a fixed version to save space.  
```yaml
---
kind: ImageSetConfiguration
apiVersion: mirror.openshift.io/v1alpha2
storageConfig:
  registry:
    imageURL: pinnedis-registry.pinnedis.local.lab/metadata
    skipTLS: true
mirror:
  platform:
    channels:
      - name: stable-4.16
        type: ocp
        minversion: '4.16.3'
        maxversion: '4.16.3'
      - name: stable-4.17
        type: ocp
        minversion: '4.17.0-0.nightly-2024-08-07-043456'
        maxversion: '4.17.0-0.nightly-2024-08-07-043456'
    graph: true
  operators: []
  additionalImages:
    - name: registry.access.redhat.com/ubi8/ubi:latest
  helm: {}
```

## Create the mirror
Once we have the binary and our registry server, we can create a mirror using  
 the configuration and executing the command:
```shell
$ oc-mirror --config=./imageset-config.yaml --dest-skip-tls docker://pinnedis-registry.pinnedis.local.lab
```

## caveats
The `oc-mirror` binary does not use the authentication file `${XDG_CONFIG_HOME}/containers/auth.json`.  
You will probably need to copy it to `/run/user/<uid>/containers/auth.json`.
