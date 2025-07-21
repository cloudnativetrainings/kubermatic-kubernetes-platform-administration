
.PHONY: prepare_tf_config
setup_k1_folder:
	cp /tmp/kubeone_${K1_VERSION}_linux_amd64/examples/terraform/gce/*.tf /training/k1/tf_infra/
	sed -i "s/<FILL-IN-YOUR-GCE-PROJECT-ID>/${GCE_PROJECT}/g" /training/k1/tf_infra/terraform.tfvars
	sed -i "s/<FILL-IN-CLUSTER-NAME>/${TRAINEE_NAME}-k1-cluster/g" /training/k1/tf_infra/terraform.tfvars

.PHONY: terraform
terraform:
	terraform -chdir=/training/k1/tf_infra init
	terraform -chdir=/training/k1/tf_infra apply -var=control_plane_target_pool_members_count=1 -auto-approve
	
.PHONY: create_cluster
create_cluster:
	cd /training/k1; kubeone apply -t /training/k1/tf_infra -y --verbose
	terraform -chdir=/training/k1/tf_infra apply -auto-approve
