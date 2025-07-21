# Installation of the Seed

In this lab you will create a KKP Seed Cluster.

```bash
cd /training/05_setup-kkp-seed/
```

## Add the Seed kubeconfig to the Master

For the KKP Seed Components being able to communicate with the KKP Master Components you have to create a secret containing the kubeconfig of the Master Cluster. In our case the Seed and Master Components are running in the same cluster.

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

Also the communication from the Master Components towards the Control Plane components of the User Clusters, running in the Seed Cluster, has to be encrypted. Therefore we configure a new wildcard DNS entry.

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

KKP backups User Clusters regulary. The backups are stored via [minio](https://min.io/). You have to configure minio.

<!-- TODO do I need yq??? maybe should be in base image-->

Change the existing minio settings in the file `/training/kkp/values.yaml` to the following:

```yaml
minio:
  storeSize: "10Gi"
  storageClass: kubermatic-backup
  credentials:
    accessKey: "reoshe9Eiwei2ku5foB6owiva2Sheeth"
    secretKey: "rooNgohsh4ohJo7aefoofeiTae4poht0cohxua5eithiexu7quieng5ailoosha8"
```

## Re-run the kubermatic-installer

```bash
# re-run the installer with kubermatic-seed option
kubermatic-installer --kubeconfig /root/.kube/config \
    --charts-directory /training/kkp/charts deploy kubermatic-seed \
    --config /training/kkp/kubermatic.yaml \
    --helm-values /training/kkp/values.yaml
```

>**CONGRATS:**
>Congrats your KKP installation is now ready for use!!!
