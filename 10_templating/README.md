# Templating

In this lab you will learn about templating in KKP.

## Create a Provider Preset

```bash
# add the base64 encoded gcp serviceaccount to the file `/training/kkp/gcp-preset.yaml`
ENC_SA=$(base64 -w0 /training/.secrets/gcp-service-account.json)
yq ".spec.gcp.serviceAccount = \"$ENC_SA\"" -i /training/kkp/gcp-preset.yaml
```

```bash
# apply the preset 
kubectl apply -f /training/kkp/gcp-preset.yaml
```

```bash
# verify
kubectl get preset
```

>**NOTE:**
>You can also manage presets via the UI in the `Admin Panel` / `Manage Resources` / `Provider Presets`.

## Create Cluster Template

1. Create a new cluster via the UI.
1. In the tab `Settings`, make use of the Provider Preset `gcp` you have created in the previous step.
1. You can also add Default Applications into your ClusterTemplate in the tab `Applications`.
1. Instead of clicking the button `Create Cluster`, click the button `Save Cluster Template` in the tab `Summary`.
1. Give the template a proper name and save it, e.g. on scope `Project`.

Verify the ClusterTemplate via the CLI:

```bash
kubectl get clustertemplate
```

## Make use of templates

Within the UI, create a cluster via the button `Create Cluster from Template` and make use of the template created in the previous step.
