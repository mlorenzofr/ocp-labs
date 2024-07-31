# quay lab
In this lab we want to create an environment with Openshift and quay registry running on it.

## Requirements

## Steps
### Hub cluster
1. Deploy an _Agent Based installation_ of Openshift with:
```shell
ap labs/quay/deploy.yaml --tags ocp
```
2. Deploy Quay and its dependencies with:
```shell
ap labs/quay/deploy.yaml --tags postinst
```
3. Validate

## Validation
1. Check if the cluster is running:
```shell
$ export KUBECONFIG=/root/labs/quay/deploy/auth/kubeconfig

$ oc get nodes
NAME          STATUS   ROLES                         AGE   VERSION
quay-node-1   Ready    control-plane,master,worker   13m   v1.29.6+aba1e8d
quay-node-2   Ready    control-plane,master,worker   30m   v1.29.6+aba1e8d
quay-node-3   Ready    control-plane,master,worker   30m   v1.29.6+aba1e8d

$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.16.3    True        False         2m27s   Cluster version is 4.16.3
```
2. Review if the PVCs used by **NooBaa** and **Quay** are in `Bound` status:
```shell
$ oc get pvc -A
NAMESPACE           NAME                                               STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
openshift-storage   db-noobaa-db-pg-0                                  Bound    pvc-2863c2b2-50ec-475a-9c82-839800a1e243   50Gi       RWO            lvms-vg1       <unset>                 16m
openshift-storage   noobaa-default-backing-store-noobaa-pvc-9bc87833   Bound    pvc-33e683b8-7b04-4333-b68e-52b7d7c56b2b   50Gi       RWO            lvms-vg1       <unset>                 15m
quay                registry-clair-postgres-13                         Bound    pvc-57a2cedd-ad3b-4b65-a1bc-0e5e81f8eb27   50Gi       RWO            lvms-vg1       <unset>                 13m
quay                registry-quay-postgres-13                          Bound    pvc-e637403d-6ce0-422c-81f6-52e391008e67   50Gi       RWO            lvms-vg1       <unset>                 13m
```
3. Check if the _NooBaa_ endpoint, required by quay's datastorage, is available:
```shell
$ oc get noobaa -n openshift-storage
NAME     S3-ENDPOINTS                       STS-ENDPOINTS                      SYSLOG-ENDPOINTS   IMAGE                                                                                                            PHASE   AGE
noobaa   ["https://192.168.129.65:32170"]   ["https://192.168.129.65:30817"]                      registry.redhat.io/odf4/mcg-core-rhel9@sha256:5f56419be1582bf7a0ee0b9d99efae7523fbf781a88f8fe603182757a315e871   Ready   16m
```
4. Check if Quay operator is running:
```shell
$ oc get pods -n openshift-operators
NAME                                     READY   STATUS    RESTARTS   AGE
quay-operator.v3.12.0-5fb458b9b6-wh7nl   1/1     Running   0          12m
```
5. Check if Quay pods are up and running:
> **NOTE**: It may take approximately 15m for the registry to upgrade and startup.
> It's normal for some pods to experience errors during the process.
```shell
$ oc get pods -n quay
NAME                                       READY   STATUS      RESTARTS        AGE
registry-clair-app-66588c95dd-22djp        1/1     Running     0               11s
registry-clair-app-66588c95dd-czctf        1/1     Running     0               41s
registry-clair-app-66588c95dd-fd4d5        1/1     Running     5 (7m54s ago)   9m45s
registry-clair-app-66588c95dd-l698x        1/1     Running     0               4m42s
registry-clair-app-66588c95dd-wsqvr        1/1     Running     0               6m24s
registry-clair-postgres-55db455947-bp4dj   1/1     Running     0               6m44s
registry-quay-app-c9d4f78f7-5rw7h          1/1     Running     0               9m13s
registry-quay-app-c9d4f78f7-p5kt4          1/1     Running     0               9m13s
registry-quay-app-upgrade-bj5wx            0/1     Completed   0               9m46s
registry-quay-database-5b95bb578-zrk7w     1/1     Running     0               9m44s
registry-quay-mirror-75cf8c545f-66xp2      1/1     Running     0               9m44s
registry-quay-mirror-75cf8c545f-g4ckh      1/1     Running     0               9m44s
registry-quay-redis-5f77dbbf95-vhctz       1/1     Running     0               9m45s
```
6. Access to the [Quay UI](https://registry-quay-quay.apps.quay.local.lab)
7. Create a new user for tests, in this example `username`.
8. Create a new repository using the UI, in this case we call it `ubi9`.
9. Login in the Quay registry using `podman`:
```shell
$ podman login registry-quay-quay.apps.quay.local.lab --tls-verify=false
Username: username
Password:
Login Succeeded!
```
9. Push a new image to our repository
```shell
$ podman tag 02b9afe55b31 registry-quay-quay.apps.quay.local.lab/username/ubi9
$ podman push registry-quay-quay.apps.quay.local.lab/username/ubi9 --tls-verify=false --remove-signatures
Copying blob 5d477c0506fb done   |
Copying config 02b9afe55b done   |
Writing manifest to image destination
```
10. Inspect the image pushed in the previous step:
```shell
$ skopeo inspect docker://registry-quay-quay.apps.quay.local.lab/username/ubi9:latest --tls-verify=false
```

## Links
* [Red Hat Quay 3.12 Documentation](https://docs.redhat.com/en/documentation/red_hat_quay/3.12)
* [Use Red Hat Quay](https://docs.redhat.com/en/documentation/red_hat_quay/3.12/html/use_red_hat_quay/index)
* [Deploy Red Hat Quay on Openshift with the Quay Operator](https://docs.redhat.com/en/documentation/red_hat_quay/3.5/html/deploy_red_hat_quay_on_openshift_with_the_quay_operator/)
