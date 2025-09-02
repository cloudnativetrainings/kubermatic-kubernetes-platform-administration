# Install kubermatic-installer

In this lab you will install the `kubermatic-installer` to your local environment.

>**NOTE:**
>You are not the downloading the latest kubermatic-installer version for being able to upgrade kubermatic-installer in a later step.

```bash
# set the kubermatic-installer version
KKP_INSTALLER_VERSION=2.28.1

# download the kubermatic-installer release
curl -L https://github.com/kubermatic/kubermatic/releases/download/v$KKP_INSTALLER_VERSION/kubermatic-ce-v$KKP_INSTALLER_VERSION-linux-amd64.tar.gz --output /tmp/kubermatic-ce-$KKP_INSTALLER_VERSION.tar.gz

# unzip kubermatic-installer release
mkdir /training/kubermatic-ce-$KKP_INSTALLER_VERSION
tar -xvf /tmp/kubermatic-ce-$KKP_INSTALLER_VERSION.tar.gz -C /training/kubermatic-ce-$KKP_INSTALLER_VERSION

# copy `kubermatic-installer` into directory within `$PATH`
cp /training/kubermatic-ce-$KKP_INSTALLER_VERSION/kubermatic-installer /usr/local/bin

# verify `kubermatic-installer` installation
kubermatic-installer --version

# add kubermatic-installer completion to your environment
echo 'source <(kubermatic-installer completion bash)' | tee -a /root/.trainingrc 

# persist the kubermatic-installer version into an environment variable
echo "export KKP_INSTALLER_VERSION=${KKP_INSTALLER_VERSION}" | tee -a /root/.trainingrc

# ensure kubermatic-installer version is set in your current bash
source /root/.trainingrc
```
