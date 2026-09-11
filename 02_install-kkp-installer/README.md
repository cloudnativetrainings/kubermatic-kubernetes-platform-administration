# Install kubermatic-installer

In this lab you will install the `kubermatic-installer` in your local environment.

>**NOTE:**
>You are not downloading the latest kubermatic-installer version, so that you can upgrade it in a later step.

```bash
# set the kubermatic-installer version
KKP_INSTALLER_VERSION=2.31.0
```

<!-- TODO yq with arrays do not use indexes -->

```bash
# download the kubermatic-installer release
curl -L https://github.com/kubermatic/kubermatic/releases/download/v$KKP_INSTALLER_VERSION/kubermatic-ee-v$KKP_INSTALLER_VERSION-linux-amd64.tar.gz --output /tmp/kubermatic-ee-$KKP_INSTALLER_VERSION.tar.gz
```

```bash
# unzip kubermatic-installer release
mkdir /training/kubermatic-ee-$KKP_INSTALLER_VERSION
tar -xvf /tmp/kubermatic-ee-$KKP_INSTALLER_VERSION.tar.gz -C /training/kubermatic-ee-$KKP_INSTALLER_VERSION
```

```bash
# copy `kubermatic-installer` into directory within `$PATH`
cp /training/kubermatic-ee-$KKP_INSTALLER_VERSION/kubermatic-installer /usr/local/bin
```

```bash
# verify `kubermatic-installer` installation
kubermatic-installer --version
```

```bash
# add kubermatic-installer completion to your environment
echo 'source <(kubermatic-installer completion zsh)' | tee -a /root/.trainingrc 
```

```bash
# persist the kubermatic-installer version into an environment variable
echo "export KKP_INSTALLER_VERSION=${KKP_INSTALLER_VERSION}" | tee -a /root/.trainingrc
```

```bash
# ensure kubermatic-installer version is set in your current bash
source /root/.trainingrc
```
