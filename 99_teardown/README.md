# Teardown the infrastructure

In this lab you will destroy all infrastructure you have created.

```bash
# delete user clusters
kubectl delete clusters --all

# reset the cluster
kubeone reset -m /training/k1/kubeone.yaml -t /training/k1/tf_infra/

# delete the gce DNS entries
gcloud dns record-sets delete *.kubermatic.$DOMAIN. --type=A --zone=$DNS_ZONE_NAME
gcloud dns record-sets delete *.$DOMAIN. --type=A --zone=$DNS_ZONE_NAME
gcloud dns record-sets delete $DOMAIN. --type=A --zone=$DNS_ZONE_NAME

# destroy the infrastructure provided via terraform
terraform -chdir=/training/k1/tf_infra/ destroy -auto-approve

# verify no vms are running
gcloud compute instances list

# delete minio pvc
gcloud compute disks delete --quiet pvc-XXXXX
```
