.PHONY verify:
verify:
	test -f /root/.trainingrc
	grep "source /root/.trainingrc" /root/.bashrc
	yq --version
	uuidgen --version
	which htpasswd
	kubectl version --client
	gcloud version
	terraform version
	kubectx
	helm version
	test -n "$(GCE_PROJECT)" 
	test -n "$(TRAINEE_NAME)" 
	test -n "$(DOMAIN)" 
	test -n "$(DNS_ZONE_NAME)" 
# TODO	kubens => failing due no cluster yet
	test -n "$(K8S_VERSION)" 
	test -n "$(TF_VERSION)" 
	test -e /training/.secrets/gce
	test -e /training/.secrets/gce.pub
# TODO ensure that is the right ssh key - ssh-add -l | grep "$(ssh-keygen -lf .secrets/gce)"
	test -e /training/.secrets/gcloud-service-account.json 
# TODO test -v $(GOOGLE_CREDENTIALS)
# TODO verify gcp sa permissions
	test -n "$(K1_VERSION)"
	kubeone version
	test -e /training/kubeone_${K1_VERSION}_linux_amd64/
	echo "Training Environment successfully verified"
