```bash

# install tf
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt-get install terraform

# install k1
curl -sfL get.kubeone.io | sh

# cd k1 folder
terraform init
export GOOGLE_CREDENTIALS=$(cat /workspaces/kubermatic-kubernetes-platform-administration/gcloud-service-account.json)

# TODO clustername
# TODO project id

# ssh
# TODO path
ssh-keygen -N '' -f ~/.ssh/id_rsa
eval `ssh-agent`
ssh-add ~/.ssh/id_rsa
# edit kubeone.yaml
# /home/codespace/id_rsa  => /home/codespace/.ssh/id_rsa 


terraform apply -var=control_plane_target_pool_members_count=1 -auto-approve
```