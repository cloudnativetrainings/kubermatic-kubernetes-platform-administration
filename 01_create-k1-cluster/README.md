# Create Master/Seed Kubernetes Cluster

In this lab you will create the Kubernetes Cluster in which we will deploy KKP.

```bash
cd /training/01_create-k1-cluster/
```

## Create Cluster

```bash
# create the cluster
make create-cluster

# ensure the downloaded kubeconfig is the default kubeconfig
mkdir /root/.kube
cp /training/k1/$TRAINEE_NAME-k1-cluster-kubeconfig /root/.kube/config

# verify
kubectl get nodes

# get a minimalistic visual representation of your cluster
# note the ui is currently only in beta state
kubeone ui -m /training/k1/kubeone.yaml -t /training/k1/tf_infra
```

## Engage autoscaling on worker nodes

```bash
# verify cluster-autoscaler is running
kubectl -n kube-system get deployment cluster-autoscaler

# get the machinedeployment
kubeone config machinedeployments -m /training/k1/kubeone.yaml -t /training/k1/tf_infra > /training/k1/md.yaml

# change the max worker nodes from 1 to 3
sed -i 's/cluster-api-autoscaler-node-group-max-size: "1"/cluster-api-autoscaler-node-group-max-size: "3"/g' /training/k1/md.yaml

# apply the change
kubectl apply -f /training/k1/md.yaml
```
