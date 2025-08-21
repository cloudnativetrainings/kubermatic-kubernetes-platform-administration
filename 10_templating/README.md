# Templating

In this lab you will learn about templating in KKP.

## Create a Provider Preset

```bash
# add the base64 encoded gce serviceaccount to the file `/training/kkp/gce-preset.yaml`
ENC_SA=$(base64 -w0 /training/.secrets/gcloud-service-account.json)
yq eval ".spec.gcp.serviceAccount = \"$ENC_SA\"" -i /training/kkp/gce-preset.yaml

# apply the preset 
kubectl apply -f /training/kkp/gce-preset.yaml

# verify
kubectl get preset
```

>**NOTE:**
>You can also manage presets via UI in the `Admin Panel` / `Manage Resources` / `Provider Presets`

## Create Cluster Template

1. Create a new cluster via the UI.
1. Make use of the Provider Preset `gce` in the tab `Settings` you have created in the previous step.
1. You can also add Default Applications into your ClusterTemplate in the tab `Applications`.
1. Instead of clicking the button `Create Cluster` click the button `Save Cluster Template` in the tab `Summary`.
1. Give the template a proper name and save it eg on scope `Project`.

Verify the ClusterTemplate via CLI

```bash
kubectl get clustertemplate
```

## Make use of templates

Within the UI create a cluster via the button `Create Cluster from Template` and make use of the template created in the previous step.

## Cleanup

```bash
# delete the new cluster again, for keeping GCE costs low
kubectl delete cluster XXXXX 
```
