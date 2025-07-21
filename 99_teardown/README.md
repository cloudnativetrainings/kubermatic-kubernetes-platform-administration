# Bonus Topics

In this lab you will learn how to destroy the cluster and release the provisioned infrastructure.

```bash
# delete user clusters
kubectl delete clusters --all

# reset the cluster
kubeone reset -m /training/k1/kubeone.yaml -t /training/k1/tf_infra/

# verify all worker nodes have been deleted
gcloud compute instances list

# destroy the infrastructure provided via terraform
terraform -chdir=/training/k1/tf_infra/ destroy

# verify no vms are running
gcloud compute instances list

# delete the gce DNS entry
# TODO does not work need ips
# gcloud dns record-sets transaction start --zone $DNS_ZONE_NAME
# gcloud dns record-sets transaction remove --zone=$DNS_ZONE_NAME --ttl 60 --name="*.kubermatic.$DOMAIN." --type A $SEED_IP
# gcloud dns record-sets transaction remove --zone=$DNS_ZONE_NAME --ttl 60 --name="$DOMAIN." --type A $INGRESS_IP
# gcloud dns record-sets transaction remove --zone=$DNS_ZONE_NAME --ttl 60 --name="*.$DOMAIN."  --type A $INGRESS_IP
# gcloud dns record-sets transaction remove --zone $DNS_ZONE_NAME --ttl 60 --name="$DOMAIN." --type A $INGRESS_IP
# gcloud dns record-sets transaction execute --zone $DNS_ZONE_NAME
# gcloud dns record-sets list --zone $DNS_ZONE_NAME

```
