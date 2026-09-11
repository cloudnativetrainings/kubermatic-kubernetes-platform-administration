IMAGE_NAME = quay.io/kubermatic-labs/training-ghcs-kubermatic-kubernetes-platform-administration-trainee-environment
IMAGE_TAG = 2.0.0
CONTAINER_NAME = kkp-workshop

.PHONY: clear
clear:
	docker rmi $(IMAGE_NAME):$(IMAGE_TAG)

.PHONY: lint
lint:
	hadolint ./dockerfile

.PHONY: build
build: lint
	docker buildx build --platform linux/amd64,linux/arm64 --tag ${IMAGE_NAME}:${IMAGE_TAG} .

.PHONY: run
run: build
	docker rm --force $(CONTAINER_NAME)
	docker run -it -d \
		--name $(CONTAINER_NAME) \
		--restart=always \
		--cpus=2 \
		--memory=4g \
		-p 8080:8080 \
		-p 8081:8081 \
		--hostname kkp-workshop \
		-v $(PWD)/..:/training \
		$(IMAGE_NAME):$(IMAGE_TAG)

.PHONY: push
push: lint
	docker buildx build --platform linux/amd64,linux/arm64 --tag ${IMAGE_NAME}:${IMAGE_TAG} --push .
