# Installation of the Seed

In this lab you will create a KKP Seed Cluster.

## Add the Seed kubeconfig to the Master

Components running in the master cluster have to be able to talk to the seed clusters for

- managing user clusters
- getting health information about the user clusters
- getting the kubeconfigs
- distrubte global configuration like Presets, Application Definitions, Templates,...

Therefore the seed has to be configured in the master cluster.

In our case the Seed and Master Components are running in the same cluster.

```bash
# copy the existing kubeconfig to a new file
cp /training/k1/$TRAINEE_NAME-k1-cluster-kubeconfig /training/kkp/temp-seed-kubeconfig.yaml

# create the secret manifest
kubectl create secret generic seed-kubeconfig -n kubermatic --from-file kubeconfig=/training/kkp/temp-seed-kubeconfig.yaml --dry-run=client -o yaml > /training/kkp/seed-kubeconfig-secret.yaml

# apply the secret to your cluster
kubectl apply -f /training/kkp/seed-kubeconfig-secret.yaml
```

## Configure the Seed

Take a look into `/training/kkp/seed.yaml`

## Apply the Seed

```bash
# apply the seed components to your cluster
kubectl apply -f /training/kkp/seed.yaml

# verify the seed components are running
# => kubermatic-seed-controller-manager-... 
# => nodeport-proxy-...
# => seed-proxy-kubermatic-...
watch -n 1 kubectl -n kubermatic get pods
```

## Create DNS entries for Seed

The apiservers of the user clusters have to be reachable for

- kubernetes components of the user clusters running outside of the controlplane, eg the kubelets on the worker nodes
- clients like kubectl
- from master cluster components when master and seed are separate clusters

Therefore you have to make use of the nodeport proxy which exposes the apiservers of the user clusters.

```bash
# store IP of NodePort Proxy into environment variable
SEED_IP=$(kubectl -n kubermatic get svc nodeport-proxy -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# verify that environment variable is set
echo $SEED_IP

# create a dns entry for the seed clusters at gce
gcloud dns record-sets transaction start --zone=$DNS_ZONE_NAME
gcloud dns record-sets transaction add --zone=$DNS_ZONE_NAME --ttl 60 --name="*.kubermatic.$DOMAIN." --type A $SEED_IP
gcloud dns record-sets transaction execute --zone $DNS_ZONE_NAME

# verify DNS record
nslookup test.kubermatic.$DOMAIN
```

## Setup up minio

Components in the seed clusters backup the etcd snapshots of the user clusters regularly. The backups are stored via [minio](https://min.io/). You have to configure minio.

Change the existing minio settings in the file `/training/kkp/values.yaml` to the following:

```yaml
yq ".minio.storeSize = \"10Gi\"" -i /training/kkp/values.yaml
yq ".minio.storageClass = \"kubermatic-fast\"" -i /training/kkp/values.yaml
yq ".minio.credentials.accessKey = \"reoshe9Eiwei2ku5foB6owiva2Sheeth\"" -i /training/kkp/values.yaml
yq ".minio.credentials.secretKey = \"rooNgohsh4ohJo7aefoofeiTae4poht0cohxua5eithiexu7quieng5ailoosha8\"" -i /training/kkp/values.yaml
```

## Re-run the kubermatic-installer

```bash
# re-run the installer with kubermatic-seed option
kubermatic-installer deploy kubermatic-seed \
    --kubeconfig /root/.kube/config \
    --charts-directory /training/kkp/charts deploy \
    --config /training/kkp/kubermatic.yaml \
    --helm-values /training/kkp/values.yaml
```

>**CONGRATS:**
>Congrats your KKP installation is now ready for use!!!
