# Setup KKP Master

In this lab you will set up the KKP Master components in your cluster.

## Install KKP into K1 Cluster

```bash
kubermatic-installer deploy \
    --kubeconfig /root/.kube/config \
    --charts-directory /training/kkp/charts \
    --config /training/kkp/kubermatic.yaml \
    --helm-values /training/kkp/values.yaml
```

```bash
# verify everything is running smoothly
# => note that the pods kubermatic-api-XXXXX will not run smoothly due to dns is not setup yet
watch -n 1 kubectl -n kubermatic get pods
```

```bash
# verify installed helm charts
helm ls --all-namespaces
```

## Setup DNS and TLS

### Configure DNS

Configure the DNS records for accessing KKP UI.

```bash
# store the IP of the gateway load balancer into an environment variable
GATEWAY_IP=$(kubectl -n kubermatic get gateway kubermatic -o jsonpath='{.status.addresses[0].value}')
```

```bash
# verify that environment variable is set
echo $GATEWAY_IP
```

```bash
# create the dns entries, pointing at the gatway ip at gcp
gcloud dns record-sets transaction start --zone=$DNS_ZONE_NAME
gcloud dns record-sets transaction add --zone=$DNS_ZONE_NAME --ttl 60 --name="$DOMAIN." --type A $GATEWAY_IP
gcloud dns record-sets transaction add --zone=$DNS_ZONE_NAME --ttl 60 --name="*.$DOMAIN."  --type A $GATEWAY_IP
gcloud dns record-sets transaction execute --zone $DNS_ZONE_NAME
```

```bash
# verify dns entries via dig
dig +short A $DOMAIN
dig +short A test.$DOMAIN
```

### Apply the Production Cert-Manager ClusterIssuer

To enable TLS communication, we use cert-manager.

```bash
# configure the email address for the clusterissuer
yq ".spec.acme.email = \"$TRAINEE_EMAIL\"" -i /training/kkp/clusterissuer.yaml
```

```bash
# apply the clusterissuer
kubectl apply -f /training/kkp/clusterissuer.yaml
```

### Switch to LetsEncrypt Prod

```bash
# engage the letsencrypt production clusterissuer in the kkp configuration files
yq ".spec.ingress.certificateIssuer.name = \"letsencrypt-prod\"" -i /training/kkp/kubermatic.yaml
yq ".spec.auth.skipTokenIssuerTLSVerify = false" -i /training/kkp/kubermatic.yaml

# TODO was there a breaking change, as it looks not needed anymore
# sed -i "s/letsencrypt-staging/letsencrypt-prod/g" /training/kkp/values.yaml
```

<!-- TODO get rid of all seds, use yq instead -->

```bash
# re-run the installer again
kubermatic-installer deploy \
    --kubeconfig /root/.kube/config \
    --charts-directory /training/kkp/charts \
    --config /training/kkp/kubermatic.yaml \
    --helm-values /training/kkp/values.yaml
```

```bash
# verify you obtain valid certificates from LetsEncrypt
# => note that it can take up a few minutes to get the certs in ready state
watch -n 1 kubectl get certs -A
```

```bash
# verify everything is running smoothly
# => note that the pods kubermatic-api-XXXXX should be fine
watch -n 1 kubectl -n kubermatic get pods
```

## Visit your KKP Master Installation

>**IMPORTANT:**
> You have only installed the master components so far; the UI is reachable, but you cannot create Kubernetes Clusters yet.

```bash
# echo the URL of your running KKP
# note, make use of the email address you configured previously
# make use of the password you configured in the previous lab
echo https://$DOMAIN
```
