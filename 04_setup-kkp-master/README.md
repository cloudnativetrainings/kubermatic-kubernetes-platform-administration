# Setup KKP Master

In this lab you will setup the KKP Master Components into your cluster.

```bash
cd /training/04_setup-kkp-master
```

## Apply StorageClasses

```bash
kubectl apply -f /training/kkp/storageclass-fast.yaml
kubectl apply -f /training/kkp/storageclass-backup.yaml
```

Verify the storage class

```bash
kubectl get sc
```

## Install KKP into K1 Cluster

```bash
kubermatic-installer --kubeconfig /root/.kube/config \
    --charts-directory /training/kkp/charts deploy \
    --config /training/kkp/kubermatic.yaml \
    --helm-values /training/kkp/values.yaml

# verify everyting is running smoothly
# => note that the pods kubermatic-api-XXXXX will not run smoothly due to dns is not setup yet
watch -n 1 kubectl -n kubermatic get pods
```

## Setup DNS and TLS

### Configure DNS

Configure the DNS records for accessing KKP UI.

```bash
# store IP of Loadbalancer into environment variable
INGRESS_IP=$(kubectl -n nginx-ingress-controller get service nginx-ingress-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# verify that environment variable is set
echo $INGRESS_IP

# create the dns entries at gce
gcloud dns record-sets transaction start --zone=$DNS_ZONE_NAME
gcloud dns record-sets transaction add --zone=$DNS_ZONE_NAME --ttl 60 --name="$DOMAIN." --type A $INGRESS_IP
gcloud dns record-sets transaction add --zone=$DNS_ZONE_NAME --ttl 60 --name="*.$DOMAIN."  --type A $INGRESS_IP
gcloud dns record-sets transaction execute --zone $DNS_ZONE_NAME

# verify dns records
nslookup $DOMAIN
nslookup test.$DOMAIN
```

### Apply the Production Cert-Manager ClusterIssuer

For having TLS communication we are using cert-manager.

```bash
# configure the email address for the clusterissuer
EMAIL=<FILL-IN-YOUR-MAIL-ADDRESS>
sed -i "s/TODO-STUDENT-EMAIL@cloud-native.training/$EMAIL/g" /training/kkp/clusterissuer.yaml

# apply the clusterissuer
kubectl apply -f /training/kkp/clusterissuer.yaml
```

### Switch to LetsEncrypt Prod

```bash
# engage the letsencrypt production clusterissuer in the kkp configuration files
sed -i 's/letsencrypt-staging/letsencrypt-prod/g' /training/kkp/values.yaml
sed -i 's/letsencrypt-staging/letsencrypt-prod/g' /training/kkp/kubermatic.yaml
sed -i 's/skipTokenIssuerTLSVerify: true/skipTokenIssuerTLSVerify: false/g' /training/kkp/kubermatic.yaml

# re-run the installer again
kubermatic-installer --kubeconfig /root/.kube/config \
    --charts-directory /training/kkp/charts deploy \
    --config /training/kkp/kubermatic.yaml \
    --helm-values /training/kkp/values.yaml

# verify you are obtain valid certificates from LetsEncrypt
# => note that it can take up a few minutes to get the certs in ready state
kubectl get certs -A

# verify everyting is running smoothly
# => note that the pods kubermatic-api-XXXXX should be fine
watch -n 1 kubectl -n kubermatic get pods
```

## Visit your KKP Master Installation

>**IMPORTANT:**
> You  only installed the master componenents yet, which means the UI is reachable, you cannot create Kubernetes Clusters yet.

```bash
# echo the URL of your running KKP
echo https://$DOMAIN

# make use of the email address you configured previously

# the password is `password` if you haven't changed it
```
