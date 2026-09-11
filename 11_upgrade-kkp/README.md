# Upgrade KKP

In this lab you will upgrade KKP.

## Pre Steps

### Check the Release Notes

Before upgrading KKP, please **ALWAYS** take a look at the release notes. E.g. for 2.31, you can find them in the [KKP documentation](https://docs.kubermatic.com/kubermatic/v2.31/release-notes/).

### Check the supported Kubernetes Versions

Furthermore, we will remove our Kubernetes version settings to go with the defaults. You can find the [supported versions](https://docs.kubermatic.com/kubermatic/main/architecture/compatibility/supported-versions/) in the KKP documentation.

>**NOTE:**
>Each KKP version supports a specific set of Kubernetes versions. Therefore, the setting from the previous step can be problematic. To keep things simple, we simply delete this configuration.

We want to go with the supported Kubernetes versions which get delivered with the new KKP version. Therefore you have to remove the `spec.versions` section from the file `kubermatic.yaml`:

```bash
# delete the k8s version settings
yq "del(.spec.versions)" -i /training/kkp/kubermatic.yaml
```

```bash
# apply the change
kubectl apply -f /training/kkp/kubermatic.yaml
```

## Install the new KKP Installer

```bash
# set the kkp-installer version
KKP_INSTALLER_VERSION=2.31.1
```

```bash
# download the kkp-installer release
curl -L https://github.com/kubermatic/kubermatic/releases/download/v$KKP_INSTALLER_VERSION/kubermatic-ee-v$KKP_INSTALLER_VERSION-linux-amd64.tar.gz --output /tmp/kubermatic-ee-$KKP_INSTALLER_VERSION.tar.gz
```

```bash
# unzip kkp-installer release
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
# persist the kkp version into an environment variable
echo "export KKP_INSTALLER_VERSION=${KKP_INSTALLER_VERSION}" | tee -a /root/.trainingrc
```

```bash
# ensure kkp version is set in your current bash
source /root/.trainingrc
```

```bash
# copy the directory `charts` of the new kkp release
cp -r /training/kubermatic-ee-$KKP_INSTALLER_VERSION/charts /training/kkp/
```

```bash
# verify the newer helm charts are in use
kubermatic-installer version \
    --charts-directory /training/kkp/charts
```

## Update KKP

```bash
# update master components
kubermatic-installer deploy \
    --kubeconfig /root/.kube/config \
    --charts-directory /training/kkp/charts \
    --config /training/kkp/kubermatic.yaml \
    --helm-values /training/kkp/values.yaml
```

```bash
# update seed components
kubermatic-installer deploy kubermatic-seed \
    --kubeconfig /root/.kube/config \
    --charts-directory /training/kkp/charts \
    --config /training/kkp/kubermatic.yaml \
    --helm-values /training/kkp/values.yaml
```

```bash
# verify the control plane components of the user cluster get restarted
watch -n 1 kubectl -n cluster-XXXXX get pods
```

## Verification of Upgrade

### Via CLI

```bash
# Verify everything is running again
watch -n 1 kubectl -n kubermatic get pods
```

### Via UI

- Verify the version in the UI — the KKP version number is in the lower left.
- Verify the newly available Kubernetes Versions within your Cluster via the Upgrade DropDown.
