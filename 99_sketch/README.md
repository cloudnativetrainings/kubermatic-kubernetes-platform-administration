
## K1

```bash

# install tf
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt-get install terraform

# install k1
curl -sfL get.kubeone.io | sh

cd kubeone_1.9.1_linux_amd64/examples/terraform/gce
terraform init
export GOOGLE_CREDENTIALS=$(cat /workspaces/kubermatic-kubernetes-platform-administration/gcloud-service-account.json)

# ssh
# TODO path
ssh-keygen -N '' -f /training/.ssh/id_rsa
eval `ssh-agent`
ssh-add /training/.ssh/id_rsa
# edit kubeone.yaml
# /home/codespace/id_rsa  => /home/codespace/.ssh/id_rsa 

# terraform.tfvars
# TODO clustername
# TODO project id


terraform apply -var=control_plane_target_pool_members_count=1 -auto-approve

terraform output -json > tf.json

kubeone apply -m /workspaces/kubermatic-kubernetes-platform-administration/kubeone.yaml -t tf.json
terraform apply

export KUBECONFIG=/workspaces/kubermatic-kubernetes-platform-administration/kubeone_1.9.1_linux_amd64/examples/terraform/gce/hubert-test-kubeconfig
```

## KKP

```bash

mkdir kkp
cd kkp

# For latest version:
VERSION=$(curl -w '%{url_effective}' -I -L -s -S https://github.com/kubermatic/kubermatic/releases/latest -o /dev/null | sed -e 's|.*/v||')
# For specific version set it explicitly:
# VERSION=2.25.x
wget https://github.com/kubermatic/kubermatic/releases/download/v${VERSION}/kubermatic-ce-v${VERSION}-linux-amd64.tar.gz
tar -xzvf kubermatic-ce-v${VERSION}-linux-amd64.tar.gz

sudo cp kubermatic-installer /usr/local/bin/

cat /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c32
htpasswd -bnBC 10 "" pa55word01 | tr -d ':\n' | sed 's/$2y/$2a/'
uuidgen -r

kubermatic.yaml
values.yaml
seed.yaml

kubectl apply -f storageclass-fast.yaml
kubectl apply -f storageclass-backup.yaml

# dns
## values.yaml
nginx:
  controller:
    service:
      loadBalancerIP: "10.33.16.1"
## seed.yaml
spec:
  nodeportProxy:
    annotations:
        networking.gke.io/load-balancer-ip-addresses: "1.2.3.4"

kubermatic-installer --kubeconfig /workspaces/kubermatic-kubernetes-platform-administration/kubeone_1.9.1_linux_amd64/examples/terraform/gce/hubert-test-kubeconfig \
    --charts-directory charts deploy \
    --config kubermatic.yaml \
    --helm-values values.yaml

watch -n 1 kubectl -n kubermatic get pods

# change email in clusterissuer
# TODO email
kubectl apply -f clusterissuer.yaml

# Authenticate with the service account
gcloud auth activate-service-account --key-file=/workspaces/kubermatic-kubernetes-platform-administration/gcloud-service-account.json

gcloud config set project kkp-event-01

gcloud dns record-sets transaction start --zone=event-01-hubert
gcloud dns record-sets transaction add --zone=event-01-hubert --ttl 60 --name="hubert.event-01.cloud-native.training." --type A 35.234.90.235
gcloud dns record-sets transaction add --zone=event-01-hubert --ttl 60 --name="*.hubert.event-01.cloud-native.training."  --type A 35.234.90.235
gcloud dns record-sets transaction execute --zone event-01-hubert

nslookup hubert.event-01.cloud-native.training
nslookup test.hubert.event-01.cloud-native.training

# change clusterissuer in values and kubermatic yaml

# re-run installer

kubectl get certs -A


```

## Seed

```bash

# kubermatic-installer convert-kubeconfig /workspaces/kubermatic-kubernetes-platform-administration/kubeone_1.9.1_linux_amd64/examples/terraform/gce/hubert-test-kubeconfig

cp /workspaces/kubermatic-kubernetes-platform-administration/kubeone_1.9.1_linux_amd64/examples/terraform/gce/hubert-test-kubeconfig temp-seed-kubeconfig
kubectl create secret generic seed-kubeconfig -n kubermatic --from-file kubeconfig=temp-seed-kubeconfig --dry-run=client -o yaml > seed-kubeconfig-secret.yaml
kubectl apply -f seed-kubeconfig-secret.yaml


kubectl apply -f seed.yaml

kubectl -n kubermatic get pods

# Verify that the following pods are running
# * kubermatic-seed-controller-manager-...
# * nodeport-proxy-...
# * seed-proxy-kubermatic-...

# Re-run the installer with kubermatic-seed option
kubermatic-installer --kubeconfig /workspaces/kubermatic-kubernetes-platform-administration/kubeone_1.9.1_linux_amd64/examples/terraform/gce/hubert-test-kubeconfig \
    --charts-directory charts kubermatic-seed \
    --config kubermatic.yaml \
    --helm-values values.yaml    


gcloud dns record-sets transaction start --zone=event-01-hubert
gcloud dns record-sets transaction add --zone=event-01-hubert --ttl 60 --name="*.kubermatic.hubert.event-01.cloud-native.training." --type A 35.246.177.33
gcloud dns record-sets transaction execute --zone event-01-hubert

nslookup test.kubermatic.hubert.event-01.cloud-native.training

```

## Create user cluster

```bash
base64 -w0 /workspaces/kubermatic-kubernetes-platform-administration/gcloud-service-account.json
```

## Teardown K1

```
delete user clusters
delete dns entries
kubeone reset --manifest kubeone.yaml -t tf.json -y
```
