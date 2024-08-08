# Disabling `TechPreviewNoUpgrade` FeatureSet

## *** User advisory ***
This procedure is a hack used for a specific case at Red Hat, where we need to test a TechPreview and upgrade an Openshift cluster before releasing the feature as GA.  
In **no case** it is a recommended solution for other scenarios.  
**This procedure can harm your Openshift Cluster and cause data loss and instability**.  
No production cluster must have the `FeatureSet` set to `TechPreviewNoUpgrade`.

## Procedure
We will change the `FeatureGate` CR directly in **etcd**.  
1. Open a shell in the **etcdctl** container:
```shell
oc exec -ti etcd-cluster-node-2 -c etcdctl -n openshift-etcd -- /bin/bash
```
2. Get the current value of the `/kubernetes.io/config.openshift.io/featuregates/cluster` key:
```shell
etcdctl get /kubernetes.io/config.openshift.io/featuregates/cluster
```
3. Edit the output. In the output, we will change:
	1. Replace the `spec` value and set it to `{}`
	2. Increase the value of `generation` by 1.
4. Set the new value for the key
```shell
etcdctl put /kubernetes.io/config.openshift.io/featuregates/cluster '{"apiVersion":"config.openshift.io/v1","kind":"FeatureGate","metadata":{"annotations":{"include.release.openshift.io/self-managed-high-availability":"true","kubectl.kubernetes.io/last-applied-configuration":"{\"apiVersion\":\"config.openshift.io/v1\",\"kind\":\"FeatureGate\",\"metadata\":{\"annotations\":{},\"name\":\"cluster\"},\"spec\":{}}\n"},"creationTimestamp":"2024-08-07T14:09:24Z","generation":3,"managedFields":[{"apiVersion":"config.openshift.io/v1","fieldsType":"FieldsV1","fieldsV1":{"f:metadata":{"f:annotations":{".":{},"f:include.release.openshift.io/self-managed-high-availability":{}}},"f:spec":{}},"manager":"cluster-bootstrap","operation":"Update","time":"2024-08-07T14:09:24Z"},{"apiVersion":"config.openshift.io/v1","fieldsType":"FieldsV1","fieldsV1":{"f:status":{".":{},"f:featureGates":{".":{},"k:{\"version\":\"4.16.3\"}":{".":{},"f:version":{}}}}},"manager":"cluster-bootstrap","operation":"Update","subresource":"status","time":"2024-08-07T14:09:24Z"},{"apiVersion":"config.openshift.io/v1","fieldsType":"FieldsV1","fieldsV1":{"f:metadata":{"f:annotations":{"f:kubectl.kubernetes.io/last-applied-configuration":{}}},"f:spec":{"f:featureSet":{}}},"manager":"kubectl-client-side-apply","operation":"Update","time":"2024-08-08T09:40:51Z"},{"apiVersion":"config.openshift.io/v1","fieldsType":"FieldsV1","fieldsV1":{"f:status":{"f:featureGates":{"k:{\"version\":\"4.16.3\"}":{"f:disabled":{},"f:enabled":{}}}}},"manager":"cluster-config-operator","operation":"Update","subresource":"status","time":"2024-08-08T09:41:22Z"}],"name":"cluster","uid":"0b3993d0-3e9f-4037-bf8c-5caa59a86dd5"},"spec":{},"status":{"featureGates":[{"disabled":[{"name":"ClusterAPIInstall"},{"name":"ClusterAPIInstallAzure"},{"name":"ClusterAPIInstallIBMCloud"},{"name":"EventedPLEG"},{"name":"GatewayAPI"},{"name":"MachineAPIOperatorDisableMachineHealthCheckController"}],"enabled":[{"name":"AdminNetworkPolicy"},{"name":"AlibabaPlatform"},{"name":"AutomatedEtcdBackup"},{"name":"AzureWorkloadIdentity"},{"name":"BareMetalLoadBalancer"},{"name":"BuildCSIVolumes"},{"name":"CSIDriverSharedResource"},{"name":"ChunkSizeMiB"},{"name":"CloudDualStackNodeIPs"},{"name":"ClusterAPIInstallAWS"},{"name":"ClusterAPIInstallGCP"},{"name":"ClusterAPIInstallNutanix"},{"name":"ClusterAPIInstallOpenStack"},{"name":"ClusterAPIInstallPowerVS"},{"name":"ClusterAPIInstallVSphere"},{"name":"DNSNameResolver"},{"name":"DisableKubeletCloudCredentialProviders"},{"name":"DynamicResourceAllocation"},{"name":"EtcdBackendQuota"},{"name":"Example"},{"name":"ExternalCloudProvider"},{"name":"ExternalCloudProviderAzure"},{"name":"ExternalCloudProviderExternal"},{"name":"ExternalCloudProviderGCP"},{"name":"ExternalOIDC"},{"name":"ExternalRouteCertificate"},{"name":"GCPClusterHostedDNS"},{"name":"GCPLabelsTags"},{"name":"HardwareSpeed"},{"name":"ImagePolicy"},{"name":"InsightsConfig"},{"name":"InsightsConfigAPI"},{"name":"InsightsOnDemandDataGather"},{"name":"InstallAlternateInfrastructureAWS"},{"name":"KMSv1"},{"name":"MachineAPIProviderOpenStack"},{"name":"MachineConfigNodes"},{"name":"ManagedBootImages"},{"name":"MaxUnavailableStatefulSet"},{"name":"MetricsCollectionProfiles"},{"name":"MetricsServer"},{"name":"MixedCPUsAllocation"},{"name":"NetworkDiagnosticsConfig"},{"name":"NetworkLiveMigration"},{"name":"NewOLM"},{"name":"NodeDisruptionPolicy"},{"name":"NodeSwap"},{"name":"OnClusterBuild"},{"name":"OpenShiftPodSecurityAdmission"},{"name":"PinnedImages"},{"name":"PlatformOperators"},{"name":"PrivateHostedZoneAWS"},{"name":"RouteExternalCertificate"},{"name":"ServiceAccountTokenNodeBinding"},{"name":"ServiceAccountTokenNodeBindingValidation"},{"name":"ServiceAccountTokenPodNodeInfo"},{"name":"SignatureStores"},{"name":"SigstoreImageVerification"},{"name":"TranslateStreamCloseWebsocketRequests"},{"name":"UpgradeStatus"},{"name":"VSphereControlPlaneMachineSet"},{"name":"VSphereDriverConfiguration"},{"name":"VSphereMultiVCenters"},{"name":"VSphereStaticIPs"},{"name":"ValidatingAdmissionPolicy"},{"name":"VolumeGroupSnapshot"}],"version":"4.16.3"}]}}'
```
5. Now in our cluster we should be able to see the new configuration for `FeatureGate`:
```shell
$ oc get featuregates.config.openshift.io cluster -o yaml
apiVersion: config.openshift.io/v1
kind: FeatureGate
metadata:
  annotations:
    include.release.openshift.io/self-managed-high-availability: "true"
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"config.openshift.io/v1","kind":"FeatureGate","metadata":{"annotations":{},"name":"cluster"},"spec":{}}
  creationTimestamp: "2024-08-07T14:09:24Z"
  generation: 3
  name: cluster
  resourceVersion: "60928"
  uid: 0b3993d0-3e9f-4037-bf8c-5caa59a86dd5
spec: {}

... (content omitted) ...
```
6. This change will trigger changes in our cluster. The `kube-apiserver` y `kube-controller-manager` operators will be updated, and a new `MachineConfig` will be deployed to the cluster nodes, restarting them in the process. Wait until this process had finished.
```shell
oc adm wait-for-stable-cluster --minimum-stable-period=300s
```