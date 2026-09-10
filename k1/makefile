
.PHONY: prepare-tf-config
prepare-tf-config:
	kubeone init --provider gce --cluster-name ${TRAINEE_NAME}-cluster --path /training/k1/tf_infra
	cp /training/k1/terraform.tfvars /training/k1/tf_infra/
	sed -i "s/<FILL-IN-YOUR-GCP-PROJECT-ID>/${GCP_PROJECT}/g" /training/k1/tf_infra/terraform.tfvars
	sed -i "s/<FILL-IN-CLUSTER-NAME>/${TRAINEE_NAME}-k1-cluster/g" /training/k1/tf_infra/terraform.tfvars
	rm /training/k1/tf_infra/kubeone.yaml

.PHONY: terraform
terraform: prepare-tf-config
	terraform -chdir=/training/k1/tf_infra init
	terraform -chdir=/training/k1/tf_infra apply -var=control_plane_target_pool_members_count=1 -auto-approve
	
.PHONY: create-cluster
create-cluster: terraform
	cd /training/k1; kubeone apply -t /training/k1/tf_infra -y --verbose
