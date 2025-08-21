# Install KKP

In this lab you will install KKP to your local environment.

>**NOTE:**
>You are not the downloading the latest KKP version for being able to upgrade KKP in a later step.

```bash
# set the kkp version
KKP_VERSION=2.28.1

# download the kkp release
curl -L https://github.com/kubermatic/kubermatic/releases/download/v$KKP_VERSION/kubermatic-ce-v$KKP_VERSION-linux-amd64.tar.gz --output /tmp/kubermatic-ce-$KKP_VERSION.tar.gz

# unzip kkp release
mkdir /training/kubermatic-ce-$KKP_VERSION
tar -xvf /tmp/kubermatic-ce-$KKP_VERSION.tar.gz -C /training/kubermatic-ce-$KKP_VERSION

# copy `kubermatic-installer` into directory within `$PATH`
cp /training/kubermatic-ce-$KKP_VERSION/kubermatic-installer /usr/local/bin

# verify `kubermatic-installer` installation
kubermatic-installer --version

# add kkp completion to your environment
echo 'source <(kubermatic-installer completion bash)' | tee -a /root/.trainingrc 

# persist the kkp version into an environment variable
echo "export KKP_VERSION=${KKP_VERSION}" | tee -a /root/.trainingrc

# ensure kkp version is set in your current bash
source /root/.trainingrc
```
