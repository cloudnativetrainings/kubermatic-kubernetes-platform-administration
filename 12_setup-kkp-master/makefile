.PHONY: install_kkp
install_kkp:
	curl -L https://github.com/kubermatic/kubermatic/releases/download/v$(KKP_VERSION)/kubermatic-ce-v$(KKP_VERSION)-linux-amd64.tar.gz --output /training/.tmp/kubermatic-ce-$(KKP_VERSION).tar.gz
	mkdir -p /training/.tmp/kubermatic-ce-$(KKP_VERSION)
	rm -rf /training/.tmp/kubermatic-ce-$(KKP_VERSION)/*
	tar -xvf /training/.tmp/kubermatic-ce-$(KKP_VERSION).tar.gz -C /training/.tmp/kubermatic-ce-$(KKP_VERSION)
	chmod +x /training/.tmp/kubermatic-ce-$(KKP_VERSION)/kubermatic-installer
	sudo cp /training/.tmp/kubermatic-ce-$(KKP_VERSION)/kubermatic-installer /training/bin

.PHONY: setup_kkp_folder
setup_kkp_folder:
	cp -r /training/.tmp/kubermatic-ce-$(KKP_VERSION)/charts /training/kkp
	cp /training/.tmp/kubermatic-ce-$(KKP_VERSION)/examples/kubermatic.example.yaml /training/kkp/kubermatic.yaml
	cp /training/.tmp/kubermatic-ce-$(KKP_VERSION)/examples/values.example.yaml /training/kkp/values.yaml

.PHONY: create_dns_records
create_dns_records: 
	gcloud dns record-sets transaction start --zone=$(GCP_DNS_ZONE)
	gcloud dns record-sets transaction add --zone=$(GCP_DNS_ZONE) --ttl 60 --name="$(GCP_DOMAIN)." --type A $(IP)
	gcloud dns record-sets transaction add --zone=$(GCP_DNS_ZONE) --ttl 60 --name="*.$(GCP_DOMAIN)."  --type A $(IP)
	gcloud dns record-sets transaction execute --zone $(GCP_DNS_ZONE)
