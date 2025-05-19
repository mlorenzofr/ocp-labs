# ovishilit1 lab

## Requirements
None.

## Steps
1. Create the environment network:
```shell
kcli create network -c "192.168.131.0/24" --domain local.lab -P dns=false -P dhcp=false -P plan=ovishlit1 ovishlit-net
```
2. Deploy:
```shell
ap labs/ovishlit1/deploy.yaml
```

## Validation
1. Check if the Openshift cluster is running:
```shell
$ export KUBECONFIG=/root/labs/ovishlit1/deploy/auth/kubeconfig

$ oc get nodes
NAME                 STATUS   ROLES                         AGE     VERSION
ovishlit1-master-1   Ready    control-plane,master,worker   3h52m   v1.31.6
ovishlit1-master-2   Ready    control-plane,master,worker   4h3m    v1.31.6
ovishlit1-master-3   Ready    control-plane,master,worker   4h3m    v1.31.6
```

## Links
