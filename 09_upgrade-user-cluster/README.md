# Upgrade User Clusters

In this lab you will update your user cluster.

## Upgrade of User Cluster with UI

We will also verify if there is a downtime during the upgrade process of the deployed applications.

Note, that there are some requirements to the applications to make that possible:

- The Application has to have a `RollingUpdate` Rollout Stategy.
- The Application has to have prober liveness and readiness probes set.
- The Application has to have a prober `terminationGracePeriod`.
- The Application has to scaled > 1.

```bash
# get the external ip address of the ingress-controller application
kubectl --kubeconfig=/training/kubeconfig-admin-XXXXX -n training-application get svc

# send a request to the application each 10 seconds
while true; do curl -I http://<EXTERNAL-IP>:80/; sleep 10s; done;
```

Within the UI upgrade your cluster to version `1.32.1`. Also check the checkbox `Upgrade Machine Deployments`.

The control plane of your user cluster will be upgraded very fast, due to it is only about starting new containers. The worker nodes will need about ~ 5 minutes to get updated, due to this is about starting new VMs.

## Manage the available Kubernetes versions

Add the following to the file `kubermatic.yaml` in the `spec` section (mind the proper indent):

```bash
yq ".spec.versions.versions[0] = \"v1.31.8\"" -i /training/kkp/kubermatic.yaml
yq ".spec.versions.versions[1] = \"v1.32.1\"" -i /training/kkp/kubermatic.yaml
yq ".spec.versions.versions[2] = \"v1.32.4\"" -i /training/kkp/kubermatic.yaml
yq ".spec.versions.default = \"v1.31.8\"" -i /training/kkp/kubermatic.yaml
```

Apply the updated Kubermatic configuration

```bash
kubectl apply -f /training/kkp/kubermatic.yaml
```

Afterwards you can verify the choosable Kubernetes Versions for your User Cluster also in the KKP UI.

## Upgrade of User Cluster via Bash

Now you will update your User Cluster via bash. Additionally you will verify the availability of our echoserver application.

### Upgrade the Control Plane

```bash
# change the field `spec.version` of the User Cluster to `1.32.4`.
kubectl edit cluster XXXXX

# verify the rollout
watch -n 1 kubectl -n cluster-XXXXX get pods
```

### Upgrade the Worker Nodes

```bash
# change the version of the User Clusters MachineDeployment via the following. Change the version of the field `spec.template.spec.versions.kubelet` to `1.32.4`.
kubectl --kubeconfig /training/kubeconfig-admin-XXXXX -n kube-system edit md XXXXX

# observe the nodes getting upgraded
watch -n 1 kubectl --kubeconfig /training/kubeconfig-admin-XXXXX get md,ms,machine,nodes -A
```
