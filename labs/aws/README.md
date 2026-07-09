# aws lab

This lab installs a compact Openshift cluster on AWS platform.

## Requirements

* You must have your AWS credentials added inside the `~/.aws/credentials` file.
* Your _baseDomain_ zone must be manually created in **AWS Route53** before you start the deployment.

## Steps

1. Deploy:

```shell
ap labs/aws/deploy.yaml
```

2. (Optional) Apply a custom TLS certificate to the ingress controller:

   The playbook reads certificate files from `/ansible/labs/aws/cert` inside the
   Ansible container. Mount your local certbot **archive** directory into
   `run-ansible.sh` so those files are available at runtime.

   Certbot directory layout (archive path shown; `live/` contains symlinks to
   the same files):

   ```text
   certbot/conf/
   ├── archive/
   │   └── apps.<cluster>.example.com/
   │       ├── cert1.pem
   │       ├── chain1.pem
   │       ├── fullchain1.pem
   │       └── privkey1.pem
   └── live/
       └── apps.<cluster>.example.com/
           ├── fullchain.pem -> ../../archive/apps.<cluster>.example.com/fullchain1.pem
           └── privkey.pem -> ../../archive/apps.<cluster>.example.com/privkey1.pem
   ```

   Add a volume mount to `run-ansible.sh`, pointing the archive directory for
   your domain to `/ansible/labs/aws/cert`:

   ```shell
   podman run --rm -it \
     ...
     -v "${PWD}:/ansible:Z" \
     ...
     -v "${HOME}/projects/<project>/certbot/conf/archive/apps.<cluster>.example.com:/ansible/labs/aws/cert:Z" \
     ...
   ```

   The `:Z` suffix relabels the volume for SELinux. Adjust the host path to
   match your certbot layout; the container path must stay
   `/ansible/labs/aws/cert` unless you also change `__ingress_cert_dir` in
   `labs/aws/deploy.yaml`. By default, the playbook reads `fullchain1.pem` and
   `privkey1.pem` from that directory.

   Apply the certificate:

```shell
ap labs/aws/deploy.yaml --tags ingress-cert
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

* [Hive ClusterPool](https://github.com/openshift/hive/blob/master/docs/clusterpools.md)
