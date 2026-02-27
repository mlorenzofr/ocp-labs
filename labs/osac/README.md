# osac lab

This lab installs a Openshift cluster and a spoke cluster to test OSAC deployment.

## Requirements

None.

## Steps

1. Deploy:
```shell
ap labs/osac/deploy.yaml
```
2. Export spoke cluster configuration
```shell
ap labs/osac/deploy.yaml --tags spoke-config
```
3. Import the spoke cluster (create a `ManagedCluster`)
```shell
ap labs/osac/deploy.yaml --tags import-cluster
```
4. Label the `ManagedCluster`
```shell
oc label managedcluster/test-cluster sovcloud.open-cluster-management.io/vmaas=true
```
5. Install AAP & OSAC Operator
```shell
ap labs/osac/deploy.yaml --tags aap
```

## Validation

1. Check if the Openshift cluster is running:
```shell
$ export KUBECONFIG=/root/labs/osac/deploy/auth/kubeconfig

$ oc get nodes
NAME          STATUS   ROLES                         AGE     VERSION
osac-node-1   Ready    control-plane,master,worker   6h22m   v1.33.6
osac-node-2   Ready    control-plane,master,worker   6h37m   v1.33.6
osac-node-3   Ready    control-plane,master,worker   6h37m   v1.33.6

$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.20.8    True        False         6h16m   Cluster version is 4.20.8
```
2. Review the `ansible-aap` namespace. We should have:
    * `secret/config-as-code-ig`
    * `secret/config-as-code-manifest-ig`
    * `secret/vmaas-cluster-kubeconfig`
    * `route.route.openshift.io/osac-aap-controller`
```shell
$ oc get all,secrets -n ansible-aap

NAME                                                                  READY   STATUS      RESTARTS   AGE
pod/aap-bootstrap-dgdnc                                               0/1     Error       0          61m
pod/aap-bootstrap-fwzcg                                               0/1     Error       0          61m
pod/aap-bootstrap-kdbfj                                               0/1     Completed   0          60m
pod/aap-bootstrap-scfql                                               0/1     Error       0          61m
pod/aap-gateway-operator-controller-manager-67c6749984-2zxj8          2/2     Running     0          70m
pod/activation-job-1-1-lzcgx                                          1/1     Running     0          58m
pod/ansible-lightspeed-operator-controller-manager-5d6cfff7d7-fgntc   2/2     Running     0          70m
pod/automation-controller-operator-controller-manager-5b94bcdbt4tmc   2/2     Running     0          70m
pod/automation-hub-operator-controller-manager-957988b97-lzzkd        2/2     Running     0          70m
pod/eda-server-operator-controller-manager-64dcf97d94-cf49s           2/2     Running     0          70m
pod/osac-aap-controller-migration-4.6.25-hctpt                        0/1     Completed   0          66m
pod/osac-aap-controller-task-794fd55c7b-f8ngf                         4/4     Running     0          66m
pod/osac-aap-controller-web-7fb4b677df-kd88t                          3/3     Running     0          66m
pod/osac-aap-eda-activation-worker-86d5754449-jpp7v                   1/1     Running     0          66m
pod/osac-aap-eda-activation-worker-86d5754449-vzbfc                   1/1     Running     0          66m
pod/osac-aap-eda-api-7f8fd6568c-r4vt6                                 3/3     Running     0          66m
pod/osac-aap-eda-default-worker-66f54c854f-b2vs4                      1/1     Running     0          66m
pod/osac-aap-eda-default-worker-66f54c854f-mfqdz                      1/1     Running     0          66m
pod/osac-aap-eda-event-stream-5df646984c-znszh                        2/2     Running     0          66m
pod/osac-aap-eda-scheduler-5fd67d5594-rncf5                           1/1     Running     0          66m
pod/osac-aap-eda-scheduler-5fd67d5594-tv546                           1/1     Running     0          66m
pod/osac-aap-gateway-5d6655b9f4-mx58c                                 2/2     Running     0          69m
pod/osac-aap-postgres-15-0                                            1/1     Running     0          69m
pod/osac-aap-redis-0                                                  1/1     Running     0          69m
pod/resource-operator-controller-manager-7988dd5c9d-r2kcv             2/2     Running     0          70m

NAME                                  TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
service/osac-aap                      ClusterIP   172.30.123.195   <none>        80/TCP     69m
service/osac-aap-api                  ClusterIP   172.30.251.194   <none>        80/TCP     69m
service/osac-aap-controller-service   ClusterIP   172.30.177.50    <none>        80/TCP     66m
service/osac-aap-eda-api              ClusterIP   172.30.11.18     <none>        8000/TCP   66m
service/osac-aap-eda-daphne           ClusterIP   172.30.130.217   <none>        8001/TCP   66m
service/osac-aap-eda-event-stream     ClusterIP   172.30.2.255     <none>        8000/TCP   66m
service/osac-aap-postgres-15          ClusterIP   None             <none>        5432/TCP   69m
service/osac-aap-redis-svc            ClusterIP   172.30.3.236     <none>        6379/TCP   69m
service/osac-eda-service              ClusterIP   172.30.97.121    <none>        5000/TCP   58m

NAME                                                                READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/aap-gateway-operator-controller-manager             1/1     1            1           70m
deployment.apps/ansible-lightspeed-operator-controller-manager      1/1     1            1           70m
deployment.apps/automation-controller-operator-controller-manager   1/1     1            1           70m
deployment.apps/automation-hub-operator-controller-manager          1/1     1            1           70m
deployment.apps/eda-server-operator-controller-manager              1/1     1            1           70m
deployment.apps/osac-aap-controller-task                            1/1     1            1           66m
deployment.apps/osac-aap-controller-web                             1/1     1            1           66m
deployment.apps/osac-aap-eda-activation-worker                      2/2     2            2           66m
deployment.apps/osac-aap-eda-api                                    1/1     1            1           66m
deployment.apps/osac-aap-eda-default-worker                         2/2     2            2           66m
deployment.apps/osac-aap-eda-event-stream                           1/1     1            1           66m
deployment.apps/osac-aap-eda-scheduler                              2/2     2            2           66m
deployment.apps/osac-aap-gateway                                    1/1     1            1           69m
deployment.apps/resource-operator-controller-manager                1/1     1            1           70m

NAME                                                                           DESIRED   CURRENT   READY   AGE
replicaset.apps/aap-gateway-operator-controller-manager-67c6749984             1         1         1       70m
replicaset.apps/ansible-lightspeed-operator-controller-manager-5d6cfff7d7      1         1         1       70m
replicaset.apps/automation-controller-operator-controller-manager-5b94bcdbfb   1         1         1       70m
replicaset.apps/automation-hub-operator-controller-manager-957988b97           1         1         1       70m
replicaset.apps/eda-server-operator-controller-manager-64dcf97d94              1         1         1       70m
replicaset.apps/osac-aap-controller-task-794fd55c7b                            1         1         1       66m
replicaset.apps/osac-aap-controller-web-7fb4b677df                             1         1         1       66m
replicaset.apps/osac-aap-eda-activation-worker-86d5754449                      2         2         2       66m
replicaset.apps/osac-aap-eda-api-7f8fd6568c                                    1         1         1       66m
replicaset.apps/osac-aap-eda-default-worker-66f54c854f                         2         2         2       66m
replicaset.apps/osac-aap-eda-event-stream-5df646984c                           1         1         1       66m
replicaset.apps/osac-aap-eda-scheduler-5fd67d5594                              2         2         2       66m
replicaset.apps/osac-aap-gateway-5d6655b9f4                                    1         1         1       69m
replicaset.apps/resource-operator-controller-manager-7988dd5c9d                1         1         1       70m

NAME                                    READY   AGE
statefulset.apps/osac-aap-postgres-15   1/1     69m
statefulset.apps/osac-aap-redis         1/1     69m

NAME                                             STATUS     COMPLETIONS   DURATION   AGE
job.batch/aap-bootstrap                          Complete   1/1           3m17s      61m
job.batch/activation-job-1-1                     Running    0/1           58m        58m
job.batch/osac-aap-controller-migration-4.6.25   Complete   1/1           3m22s      66m

NAME                                           HOST/PORT                                             PATH   SERVICES                      PORT   TERMINATION     WILDCARD
route.route.openshift.io/osac-aap              osac-aap-ansible-aap.apps.osac.local.lab                     osac-aap                      http   edge/Redirect   None
route.route.openshift.io/osac-aap-controller   osac-aap-controller-ansible-aap.apps.osac.local.lab          osac-aap-controller-service   http   edge/Redirect   None
route.route.openshift.io/osac-aap-eda          osac-aap-eda-ansible-aap.apps.osac.local.lab                 osac-aap-eda-api              8000   edge/Redirect   None

NAME                                                TYPE                DATA   AGE
secret/config-as-code-ig                            Opaque              1      70m
secret/config-as-code-manifest-ig                   Opaque              1      61m
secret/osac-aap-admin-password                      Opaque              1      69m
secret/osac-aap-controller-admin-password           Opaque              1      66m
secret/osac-aap-controller-app-credentials          Opaque              3      66m
secret/osac-aap-controller-broadcast-websocket      Opaque              1      66m
secret/osac-aap-controller-postgres-configuration   Opaque              7      69m
secret/osac-aap-controller-receptor-ca              kubernetes.io/tls   2      66m
secret/osac-aap-controller-receptor-work-signing    Opaque              2      66m
secret/osac-aap-controller-secret-key               Opaque              1      67m
secret/osac-aap-db-fields-encryption-secret         Opaque              1      69m
secret/osac-aap-eda-admin-password                  Opaque              1      66m
secret/osac-aap-eda-db-fields-encryption-secret     Opaque              1      66m
secret/osac-aap-eda-postgres-configuration          Opaque              7      69m
secret/osac-aap-eda-redis-configuration             Opaque              10     70m
secret/osac-aap-gateway-oauth2-token-secret         Opaque              1      67m
secret/osac-aap-gateway-postgres-configuration      Opaque              7      69m
secret/osac-aap-gateway-redis-configuration         Opaque              12     70m
secret/osac-aap-gateway-settings                    Opaque              1      69m
secret/osac-aap-redis-users-acl                     Opaque              1      69m
secret/osac-aap-resource-server                     Opaque              2      67m
secret/redhat-operators-pull-secret                 Opaque              1      70m
secret/vmaas-cluster-kubeconfig                     Opaque              1      70m
```
3. Review the `osac-operator-system` namespace. We should have:
    * `secret/osac-config`
    * `secret/vmaas-cluster-kubeconfig`
    * `pod/osac-operator-controller-manager-585cfcfbd9-8g8n7`
```shell
$ oc get all,secrets -n osac-operator-system

NAME                                                    READY   STATUS    RESTARTS         AGE
pod/osac-operator-controller-manager-585cfcfbd9-8g8n7   1/1     Running   27 (6m23s ago)   175m

NAME                                                       TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
service/osac-operator-controller-manager-metrics-service   ClusterIP   172.30.150.186   <none>        8443/TCP   175m

NAME                                               READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/osac-operator-controller-manager   1/1     1            1           175m

NAME                                                          DESIRED   CURRENT   READY   AGE
replicaset.apps/osac-operator-controller-manager-585cfcfbd9   1         1         1       175m
replicaset.apps/osac-operator-controller-manager-6fdf4dd949   0         0         0       175m

NAME                              TYPE     DATA   AGE
secret/osac-config                Opaque   4      175m
secret/vmaas-cluster-kubeconfig   Opaque   1      175m
```
4. Check if volume `vmaas-cluster-kubeconfig` is present in the `deployment.apps/osac-operator-controller-manager`:
```shell
$ oc get deployment.apps/osac-operator-controller-manager -n osac-operator-system -o yaml
```

## Links
* [osac-operator](https://github.com/osac-project/osac-operator)
* [osac-aap](https://github.com/osac-project/osac-aap)
* [osac-app config-as-code options](https://github.com/osac-project/osac-aap/blob/4f1ba397a8b6c9ef6fa8abe504baafceec8009db/collections/ansible_collections/osac/config_as_code/playbooks/vars/config.yml)
* [osac-app config-as-code README](https://github.com/osac-project/osac-aap/blob/8a97da6fe75750391e56a83692dc7a8bdb16b905/collections/ansible_collections/osac/config_as_code/README.md)
