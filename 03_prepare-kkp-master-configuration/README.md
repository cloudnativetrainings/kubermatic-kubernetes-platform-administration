# Prepare KKP Master Configuration

In this lab you will adapt the configuration files for installing the KKP Master components afterwards.

## Copy the KKP Charts

```bash
# copy the directory `charts` of the kkp release
cp -r /training/kubermatic-ce-$KKP_INSTALLER_VERSION/charts /training/kkp/
```

## Configure KKP

### Configure the file `/training/kkp/kubermatic.yaml`

```bash
# copy the file `kubermatic.yaml` of the kkp release
cp /training/kubermatic-ce-$KKP_INSTALLER_VERSION/examples/kubermatic.example.yaml /training/kkp/kubermatic.yaml

# configure the domain
sed -i "s/kkp.example.com/$DOMAIN/g" /training/kkp/kubermatic.yaml

# configure auth
export RANDOM_KEY="$(cat /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c32)"
yq ".spec.auth.issuerCookieKey = strenv(RANDOM_KEY)" -i /training/kkp/kubermatic.yaml
export RANDOM_KEY="$(cat /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c32)"
yq ".spec.auth.serviceAccountKey = strenv(RANDOM_KEY)" -i /training/kkp/kubermatic.yaml
export KUBERMATIC_ISSUER_SECRET="$(cat /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c32)"
yq ".spec.auth.issuerClientSecret = strenv(KUBERMATIC_ISSUER_SECRET)" -i /training/kkp/kubermatic.yaml
```

### Configure the file `/training/kkp/values.yaml`

```bash
# copy the file `values.yaml` of the kkp release
cp /training/kubermatic-ce-$KKP_INSTALLER_VERSION/examples/values.example.yaml /training/kkp/values.yaml

# configure the domain
sed -i "s/kkp.example.com/$DOMAIN/g" /training/kkp/values.yaml

# configure auth
# => note that the value has to be exactly the same like in the file `/training/kkp/values.yaml` field `spec.auth.issuerClientSecret`
yq ".dex.config.staticClients[1].secret = strenv(KUBERMATIC_ISSUER_SECRET)" -i /training/kkp/values.yaml
export RANDOM_KEY="$(cat /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c32)"
yq ".dex.config.staticClients[0].secret = strenv(RANDOM_KEY)" -i /training/kkp/values.yaml

# configure the user for accessing to KKP UI
EMAIL=<FILL-IN-YOUR-MAIL-ADDRESS>
yq ".dex.config.staticPasswords[0].email = \"$EMAIL\"" -i /training/kkp/values.yaml

# configure the password for accessing to KKP UI (note you should remember the password later ;) )
PASSWORD=<FILL-IN-YOUR-PASSWORD>
PASSWORD_HASH=$(printf %s "$PASSWORD" | htpasswd -inBC 10 '' | tr -d ':\n' | sed 's/$2y/$2a/')
yq ".dex.config.staticPasswords[0].hash = \"$PASSWORD_HASH\"" -i /training/kkp/values.yaml

# configure uuid for telemetry
UUID=$(uuidgen -r)
yq ".telemetry.uuid = \"$UUID\"" -i /training/kkp/values.yaml

# remove the credentials for the EE version of kkp
yq 'del(.kubermaticOperator)' -i /training/kkp/values.yaml
```
