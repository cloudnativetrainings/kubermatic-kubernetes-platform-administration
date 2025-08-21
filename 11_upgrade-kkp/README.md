# Upgrade KKP

In this lab you will upgrade KKP.

## Pre Steps

### Check the Release Notes

Before upgrading KKP please **ALWAYS** take a look into the release notes. Eg for 2.27 you can find them in the [kkp documentation](https://docs.kubermatic.com/kubermatic/v2.27/release-notes/).

### Check the supported Kubernetes Versions

Furthermore we will remove our Kubernetes Versions Settings again, to go with the defaults. You can find the supported versions [here](https://docs.kubermatic.com/kubermatic/main/architecture/compatibility/supported-versions/).

>**NOTE:**
>Each KKP version supports a specific set of Kubernetes versions. Therefore the setting from the previous step can be problematic. For keeping things easy we simply delete this configuration.

Remove the following in the file `kubermatic.yaml` in the `spec` section:

```yaml
versions:
  versions:
    - v1.29.1
    - v1.29.4
  default: "1.29.1"
```

And apply this change again.

```bash
kubectl apply -f /training/kkp/kubermatic.yaml
```

## Install the new KKP version

```bash
# set the kkp version
KKP_VERSION=2.28.2

# download the kkp release
curl -L https://github.com/kubermatic/kubermatic/releases/download/v$KKP_VERSION/kubermatic-ce-v$KKP_VERSION-linux-amd64.tar.gz --output /tmp/kubermatic-ce-$KKP_VERSION.tar.gz

# unzip kkp release
mkdir /training/kubermatic-ce-$KKP_VERSION
tar -xvf /tmp/kubermatic-ce-$KKP_VERSION.tar.gz -C /training/kubermatic-ce-$KKP_VERSION

# copy `kubermatic-installer` into directory within `$PATH`
cp /training/kubermatic-ce-$KKP_VERSION/kubermatic-installer /usr/local/bin

# verify `kubermatic-installer` installation
kubermatic-installer --version

# persist the kkp version into an environment variable
echo "export KKP_VERSION=${KKP_VERSION}" | tee -a /root/.trainingrc

# ensure kkp version is set in your current bash
source /root/.trainingrc

# copy the directory `charts` of the new kkp release
cp -r /training/kubermatic-ce-$KKP_VERSION/charts /training/kkp/
```

## Update KKP

```bash
# update master components
kubermatic-installer --kubeconfig /root/.kube/config \
    --charts-directory /training/kkp/charts deploy \
    --config /training/kkp/kubermatic.yaml \
    --helm-values /training/kkp/values.yaml

# update seed components
kubermatic-installer --kubeconfig /root/.kube/config \
    --charts-directory /training/kkp/charts deploy kubermatic-seed \
    --config /training/kkp/kubermatic.yaml \
    --helm-values /training/kkp/values.yaml

# verify the control plane components of the user cluster gets restarted
watch -n 1 kubectl -n cluster-XXXXX get pods
```

## Verification of Upgrade

### Via CLI

```bash
# Verify everything is running again
watch -n 1 kubectl -n kubermatic get pods
```

### Via UI

- Verify the version in the UI, you can find the KKP version number on the left below of the UI.
- Verify the newly available Kubernetes Versions within your Cluster via the Uprade DropDown.
