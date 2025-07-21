.PHONY: install_new_kkp
install_new_kkp:
	curl -L https://github.com/kubermatic/kubermatic/releases/download/v$(KKP_VERSION_NEW)/kubermatic-ce-v$(KKP_VERSION_NEW)-linux-amd64.tar.gz --output /training/.tmp/kubermatic-ce-$(KKP_VERSION_NEW).tar.gz
	mkdir -p /training/.tmp/kubermatic-ce-$(KKP_VERSION_NEW)
	rm -rf /training/.tmp/kubermatic-ce-$(KKP_VERSION_NEW)/*
	tar -xvf /training/.tmp/kubermatic-ce-$(KKP_VERSION_NEW).tar.gz -C /training/.tmp/kubermatic-ce-$(KKP_VERSION_NEW)
	chmod +x /training/.tmp/kubermatic-ce-$(KKP_VERSION_NEW)/kubermatic-installer
	sudo cp /training/.tmp/kubermatic-ce-$(KKP_VERSION_NEW)/kubermatic-installer /training/bin/kubermatic-installer
	rm -rf /training/kkp/charts
	cp -r /training/.tmp/kubermatic-ce-$(KKP_VERSION_NEW)/charts /training/kkp
