## add email to training-infra terraform

- into the tf output
- set it at beginning
- to be used for k1/certmanager.yaml (k1 training) and kkp values.yaml

## oauth lab => k8s Dashboard

## use gateway api instead of nginx

https://www.kubermatic.com/blog/meet-kkp-2-30-more-support-for-ai-workloads-gateway-api-and-advanced-control/

## clustertemplate/clustertemplateinstance/cluster/preset

explain via slides -> where do they live? (on the master)

## fill in password

does not work with special characters

## create the seed-kubeconfig via kubermatic-installer

# clean up

kubeone reset --cleanup-volumes --cleanup-load-balancers

# check docu links and make them consistent, also in k1

do this via claude

## Aus den Labs ausgelagert (lab-linter)

- `02_install-kkp-installer` / `03_prepare-kkp-master-configuration`: yq mit Arrays ohne feste Indizes schreiben (`.spec.versions.versions[0]`, `.dex.config.staticClients[0]`).
- `03_prepare-kkp-master-configuration`: war das ein Breaking Change? Früher wurde ein zweiter Random Key gebraucht.
- `04_setup-kkp-master`: scheint seit 2.31 nicht mehr nötig, war vorher im Lab:
  `sed -i "s/letsencrypt-staging/letsencrypt-prod/g" /training/kkp/values.yaml`
- `04_setup-kkp-master`: alle `sed`-Aufrufe durch `yq` ersetzen.
