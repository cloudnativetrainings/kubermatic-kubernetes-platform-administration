
```bash

# does not work due to not allowed to engage oauth2 api
gcloud services enable oauth2.googleapis.com --project=kkp-fourdata
gcloud auth app-create --project=my-gcp-project \
  --client-type=web \
  --name="My Example Web App" \
  --uri="http://localhost:8080"

# UI
https://console.cloud.google.com/apis/credentials?project=kkp-fourdata
https://console.cloud.google.com/auth/clients/create

```

# Connect to OIDC Provider

## Configure OIDC Provider

### Create OAuth Consent Screen

Visit <https://console.cloud.google.com/apis/credentials/consent> and create an OAuth Consent Screen. In the Tab `OAuth Consent Screen` choose `External` and fill in

- `App name`
- `User support email`
- Add the `Authorized Domain` with the domain `cloud-native.training`

### Create an OAuth 2.0 Client ID

Visit <https://console.cloud.google.com/apis/credentials> and click the button `Create Credentials` and choose `OAuth client ID`

- Choose `Application Type` with type `Web application` and fill in a proper name.
- Add the following `Authorized redirect URI` with the URI `https://<DOMAIN>/dex/callback`. Fill in your domain.
- Download the client secret json file

### Connect KKP to the OIDC Provider

Add the following to the file `values.yaml` in the section `dex`. Do not miss to fill in the missing values.

```yaml
connectors:
  - type: google
    id: google
    name: Google
    config:
      clientID: <CLIENT-ID>
      clientSecret: <CLIENT-SECRET>
      redirectURI: https://<DOMAIN>/dex/callback
      hostedDomains:
        - cloud-native.training
```

Apply the changes

```bash
kubermatic-installer  --kubeconfig ~/.kube/config \
    --charts-directory ~/kkp/charts deploy \
    --config ~/kkp/kubermatic.yaml \
    --helm-values ~/kkp/values.yaml
```

Now, after signing out, you can log in with Google. Note that this is a new user which does not have admin permissions.

## Change the role of a user

```bash
kubectl get user

# Change the field `spec.admin` to true
kubectl edit user XXXXX
```

Now you have admin permissions also for this user.
