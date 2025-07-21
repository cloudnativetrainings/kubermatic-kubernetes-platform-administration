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
sed -i "s/<a-random-key>/$RANDOM_KEY/g" /training/kkp/kubermatic.yaml
RANDOM_KEY="$(cat /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c32)"
sed -i "s/<another-random-key>/$RANDOM_KEY/g" /training/kkp/kubermatic.yaml
KUBERMATIC_ISSUER_SECRET="$(cat /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c32)"
sed -i "s/<dex-kubermatic-issuer-oauth-secret-here>/$KUBERMATIC_ISSUER_SECRET/g" /training/kkp/kubermatic.yaml
```

### Configure the file `/training/kkp/values.yaml`

```bash
# configure the domain
sed -i "s/kkp.example.com/$DOMAIN/g" /training/kkp/values.yaml

# configure the `dex.clients[kubermaticIssuer].secret`
# => note that the value has to be exactly the same like in the file `/training/kkp/values.yaml` field `spec.auth.issuerClientSecret`
echo $KUBERMATIC_ISSUER_SECRET
# => copy&paste the value into the field `dex.clients[kubermaticIssuer].secret`

# configure the `dex.clients[kubermatic].secret`
RANDOM_KEY="$(cat /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c32)"
sed -i "s/<a-random-key>/$RANDOM_KEY/g" /training/kkp/values.yaml

# configure the user for accessing to KKP UI
# TODO email address for clusterissuer via env
EMAIL=<FILL-IN-YOUR-MAIL-ADDRESS>
sed -i "s/kubermatic@example.com/$EMAIL/g" /training/kkp/values.yaml

# configure the password for accessing to KKP UI (note you should remember the password later ;) )
htpasswd -bnBC 10 '' <FILL-IN-YOUR-PASSWORD> | tr -d ':\n' | sed 's/$2y/$2a/'
# => copy&paste the value into the field `dex.staticPasswords[0].hash`

# generate uuid for telemetry
sed -i 's/uuid: \"\"/uuid: \"'$(uuidgen -r)'\"/g' /training/kkp/values.yaml
```
