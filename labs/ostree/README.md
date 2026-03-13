# ostree lab

## Requirements

## Steps

1. Create a new VM using [this XML definition](libvirt/rhcos-ostree.xml)

2. The VM has a `qemu:commandline` argument pointing to the ignition file. Change the SELinux context on that file:

```shell
chcon --verbose --type svirt_home_t /home/libvirt-ocp/ostree.ign
```

## Validation

## Links

* []()
