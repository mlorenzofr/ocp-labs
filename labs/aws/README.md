# aws lab

This lab installs a compact Openshift cluster on AWS platform.

## Requirements

- You must have your AWS credentials added inside the `~/.aws/credentials` file.
- Your _baseDomain_ zone must be manually created in **AWS Route53** before you start the deployment.

## Steps

1. Deploy:

```shell
ap labs/aws/deploy.yaml
```

## Validation

1. Check if the Openshift cluster is running:

```shell
$ export KUBECONFIG=/root/labs/aws/deploy/auth/kubeconfig

$ oc get nodes
NAME                          STATUS   ROLES                         AGE   VERSION
ip-10-0-10-134.ec2.internal   Ready    control-plane,master,worker   27m   v1.32.7
ip-10-0-40-114.ec2.internal   Ready    control-plane,master,worker   26m   v1.32.7
ip-10-0-88-216.ec2.internal   Ready    control-plane,master,worker   21m   v1.32.7

$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.19.10   True        False         102s    Cluster version is 4.19.10

$ oc get sc
NAME                PROVISIONER       RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
gp2-csi             ebs.csi.aws.com   Delete          WaitForFirstConsumer   true                   23m
gp3-csi (default)   ebs.csi.aws.com   Delete          WaitForFirstConsumer   true                   23m

$ oc get clusterpool -A
NAMESPACE                 NAME            SIZE   STANDBY   READY   BASEDOMAIN              IMAGESET
open-cluster-management   aws-group-one   1      0         0       <redacted>              img4.19.10-multi-appsub
```

## Links
- [Hive ClusterPool](https://github.com/openshift/hive/blob/master/docs/clusterpools.md)
