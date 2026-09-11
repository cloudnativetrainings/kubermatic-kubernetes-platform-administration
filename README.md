# Kubermatic Kubernetes Platform

In this training you will learn how to install and administer the Kubermatic Kubernetes Platform (KKP).

## Set up the training environment

### Clone the Git Repo

```bash
git clone https://github.com/cloudnativetrainings/kubermatic-kubernetes-platform-administration
```

### Run the k1-workshop Container

```bash
docker run -it -d \
  --name kkp-workshop \
  --restart=always \
  --cpus=2 \
  --memory=4g \
  -p 8080:8080 \
  -p 8081:8081 \
  --hostname kkp-workshop \
  -v ./kubermatic-kubernetes-platform-administration:/training \
  quay.io/kubermatic-labs/training-ghcs-kubermatic-kubernetes-platform-administration-trainee-environment:2.0.0
```

### Access your kkp-workshop IDE with your browser

The URL therefore is <http://localhost:8080>
