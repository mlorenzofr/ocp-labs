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

## Create the mirror
Once we have the binary and our registry server, we can create a mirror using  
 the configuration and executing the command:
```shell
$ oc-mirror --config=./imageset-config.yaml --dest-skip-tls docker://pinnedis-registry.pinnedis.local.lab
```

## caveats
The `oc-mirror` binary does not use the authentication file `${XDG_CONFIG_HOME}/containers/auth.json`.  
You will probably need to copy it to `/run/user/<uid>/containers/auth.json`.
