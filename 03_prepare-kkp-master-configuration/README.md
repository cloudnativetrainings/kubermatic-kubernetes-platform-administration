# Prepare KKP Master Configuration

In this lab you will adapt the configuration files for installing the KKP Master components afterwards.

```bash
cd /training/03_prepare-kkp-master-configuration
```

## Copy the KKP Configuration Files

```bash
# copy the directory `charts` of the kkp release
cp -r /training/kubermatic-ce-$KKP_VERSION/charts /training/kkp/

# copy the file `kubermatic.yaml` of the kkp release
cp /training/kubermatic-ce-$KKP_VERSION/examples/kubermatic.example.yaml /training/kkp/kubermatic.yaml

# copy the file `values.yaml` of the kkp release
cp /training/kubermatic-ce-$KKP_VERSION/examples/values.example.yaml /training/kkp/values.yaml
```

## Configure KKP

### Configure the file `/training/kkp/kubermatic.yaml`

```bash
# configure the domain
sed -i "s/kkp.example.com/$DOMAIN/g" /training/kkp/kubermatic.yaml

# configure auth
RANDOM_KEY="$(cat /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c32)"
yq ".spec.auth.issuerCookieKey = \"$RANDOM_KEY\"" -i /training/kkp/kubermatic.yaml
RANDOM_KEY="$(cat /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c32)"
yq ".spec.auth.serviceAccountKey = \"$RANDOM_KEY\"" -i /training/kkp/kubermatic.yaml
KUBERMATIC_ISSUER_SECRET="$(cat /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c32)"
yq ".spec.auth.issuerClientSecret = \"$KUBERMATIC_ISSUER_SECRET\"" -i /training/kkp/kubermatic.yaml
```

### Configure the file `/training/kkp/values.yaml`

```bash
# configure the domain
sed -i "s/kkp.example.com/$DOMAIN/g" /training/kkp/values.yaml

# configure auth
# => note that the value has to be exactly the same like in the file `/training/kkp/values.yaml` field `spec.auth.issuerClientSecret`
yq ".dex.clients[1].secret = \"$KUBERMATIC_ISSUER_SECRET\"" -i /training/kkp/values.yaml
RANDOM_KEY="$(cat /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c32)"
yq ".dex.clients[0].secret = \"$RANDOM_KEY\"" -i /training/kkp/values.yaml

# configure the user for accessing to KKP UI
EMAIL=<FILL-IN-YOUR-MAIL-ADDRESS>
yq ".dex.staticPasswords[0].email = \"$EMAIL\"" -i /training/kkp/values.yaml

# configure the password for accessing to KKP UI (note you should remember the password later ;) )
PASSWORD=<FILL-IN-YOUR-PASSWORD>
PASSWORD_HASH=$(htpasswd -bnBC 10 '' $PASSWORD | tr -d ':\n' | sed 's/$2y/$2a/')
yq ".dex.staticPasswords[0].hash = \"$PASSWORD_HASH\"" -i /training/kkp/values.yaml

# configure uuid for telemetry
UUID=$(uuidgen -r)
yq ".telemetry.uuid = \"$UUID\"" -i /training/kkp/values.yaml
```
