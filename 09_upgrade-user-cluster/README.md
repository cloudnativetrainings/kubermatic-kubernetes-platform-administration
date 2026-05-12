# Upgrade User Clusters

In this lab you will update your user cluster.

## Upgrade of User Cluster with UI

We will also verify if there is a downtime during the upgrade process of the deployed applications.

Note that there are some requirements for the applications to make that possible:

- The Application has to have a `RollingUpdate` Rollout Strategy.
- The Application has to have proper liveness and readiness probes set.
- The Application has to have a proper `terminationGracePeriod`.
- The Application has to be scaled > 1.

Within the UI upgrade your cluster to version `1.35.3`. Also check the checkbox `Upgrade Machine Deployments`.

The control plane of your user cluster will be upgraded very fast, because it is only about starting new containers. The worker nodes will need about ~ 5 minutes to get updated, because this is about starting new VMs.

## Manage the available Kubernetes versions

Add the following to the file `kubermatic.yaml` in the `spec` section (mind the proper indent):

```bash
yq ".spec.versions.versions[0] = \"v1.35.1\"" -i /training/kkp/kubermatic.yaml
yq ".spec.versions.versions[1] = \"v1.35.2\"" -i /training/kkp/kubermatic.yaml
yq ".spec.versions.versions[2] = \"v1.35.3\"" -i /training/kkp/kubermatic.yaml
yq ".spec.versions.versions[3] = \"v1.35.4\"" -i /training/kkp/kubermatic.yaml
yq ".spec.versions.default = \"v1.35.3\"" -i /training/kkp/kubermatic.yaml
```

Apply the updated Kubermatic configuration

```bash
kubectl apply -f /training/kkp/kubermatic.yaml
```

Afterwards you can also verify the available Kubernetes versions for your User Cluster in the KKP UI.

## Upgrade of User Cluster via Bash

Now you will update your User Cluster via bash. Additionally you will verify the availability of our echoserver application.

### Upgrade the Control Plane

```bash
# change the field `spec.version` of the User Cluster to `1.35.4`.
kubectl edit cluster XXXXX

# verify the rollout
watch -n 1 kubectl -n cluster-XXXXX get pods
```

### Upgrade the Worker Nodes

```bash
# change the version of the User Clusters MachineDeployment via the following. Change the version of the field `spec.template.spec.versions.kubelet` to `1.35.4`.
kubectl --kubeconfig /training/kubeconfig-admin-XXXXX -n kube-system edit md XXXXX

# observe the nodes getting upgraded
watch -n 1 kubectl --kubeconfig /training/kubeconfig-admin-XXXXX get md,ms,machine,nodes -A
```
