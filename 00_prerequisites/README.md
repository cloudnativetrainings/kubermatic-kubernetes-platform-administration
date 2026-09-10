# Prerequisites

In this lab you will ensure everything is in place to create a Kubernetes cluster via kubeone.

## Verify installed software

```bash
# verify kubectl is installed
kubectl version --client
```

```bash
# verify terraform is installed
terraform version
```

### Copy your Training Files

```bash
# create a directory for holding sensitive information
mkdir /training/.secrets
```

Drag and drop the files (provided by the trainer) into the directory `/training/.secrets/`

- environment.sh
- README.md
- gcloud-service-account.json

## Set important environment variables

> **IMPORTANT:**
> These variables will get referenced during the following labs. Make sure to set them before continuing. You can find the required information in the file `/training/.secrets/README.md`, but, for convenience, there is also a shell script which will persist the environment variables in the file `/root/.trainingrc`.

```bash
# make the shell script executable
chmod 0700 /training/.secrets/environment.sh
```

```bash
# persist the environment variables into the file /root/.trainingrc
/training/.secrets/environment.sh
```

```bash
# ensure changes are applied in your current bash
source /root/.trainingrc
```

```bash
# verify
echo $GCE_PROJECT
echo $TRAINEE_NAME
echo $DOMAIN
echo $DNS_ZONE_NAME
```

## Ensure SSH requirements

KubeOne needs an SSH key pair for communicating with the control plane and worker nodes.

```bash
# create a ssh-key-pair for gce
ssh-keygen -q -N "" -t rsa -f /training/.secrets/gce -C root
```

```bash
# ensure proper private key file permissions
chmod 400 /training/.secrets/gce
```

```bash
# ensure .ssh key is known on environment restarts
echo 'eval `ssh-agent`' >> /root/.trainingrc
echo "ssh-add /training/.secrets/gce" >> /root/.trainingrc
```

```bash
# ensure changes are applied in your current bash
source /root/.trainingrc
```

```bash
# verify agent is running and holds proper key
ssh-add -l | grep "$(ssh-keygen -lf /training/.secrets/gce)"
```

## Configure GCE

```bash
# activate gce account
gcloud auth activate-service-account --key-file=/training/.secrets/gcloud-service-account.json
```

```bash
# set the gce project
gcloud config set project $GCE_PROJECT --quiet
```

```bash
# set the compute region and zone
gcloud config set compute/region europe-west3
gcloud config set compute/zone europe-west3-a
```

```bash
# verify your settings
gcloud config list
```

```bash
# persist the google credentials into an environment variable (needed by terraform and k1)
echo "export GOOGLE_CREDENTIALS='$(cat /training/.secrets/gcloud-service-account.json)'" >> /root/.trainingrc
```

## Install KubeOne

```bash
# set the k1 version
K1_VERSION=1.13.5
```

```bash
# download the k1 release
wget -P /tmp/ https://github.com/kubermatic/kubeone/releases/download/v${K1_VERSION}/kubeone_${K1_VERSION}_linux_amd64.zip
```

```bash
# unzip k1 release
unzip /tmp/kubeone_${K1_VERSION}_linux_amd64.zip -d /training/kubeone_${K1_VERSION}_linux_amd64
```

```bash
# copy k1 into directory within `$PATH`
cp /training/kubeone_${K1_VERSION}_linux_amd64/kubeone /usr/local/bin
```

```bash
# verify k1 installation
kubeone version
```

```bash
# add k1 completion to your environment
echo 'source <(kubeone completion bash)' | tee -a /root/.trainingrc 
```

```bash
# persist the k1 version into an environment variable
echo "export K1_VERSION=${K1_VERSION}" | tee -a /root/.trainingrc
```

## Verify your environment

```bash
# ensure all environment variables get set in your current bash
source /root/.trainingrc
```

```bash
# verify
make verify
```
