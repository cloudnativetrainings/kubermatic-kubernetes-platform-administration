
.PHONY: prepare_tf_config
setup_k1_folder:
	cp /training/kubeone_${K1_VERSION}_linux_amd64/examples/terraform/gce/*.tf /training/kubeone/tf_infra/
	sed -i "s/<FILL-IN-YOUR-GCE-PROJECT-ID>/$GCE_PROJECT/g" /training/kubeone/tf_infra/terraform.tfvars
	sed -i "s/<FILL-IN-CLUSTER-NAME>/$TRAINEE_NAME-k1-cluster/g" /training/kubeone/tf_infra/terraform.tfvars

.PHONY: terraform
terraform:
	terraform -chdir=/training/kubeone/tf_infra init
	terraform -chdir=/training/kubeone/tf_infra apply -var=control_plane_target_pool_members_count=1 -auto-approve
	
.PHONY: create_cluster
create_cluster:
	cd /training/kubeone; kubeone apply -t /training/kubeone/tf_infra --verbose
	terraform -chdir=/training/kubeone/tf_infra apply -auto-approve
