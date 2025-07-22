# Adding Applications to the User Cluster

Besides Addons Kubermatic provides an additional way for enhancing your user clusters with functionalities.

The difference between Addons and Applications:

- Addons are for low-level capabilities, they are typically maintained by Kubermatic.
- Applications are for additional tooling on top of the infrastructure. This is where you can manifest your opinion about third party tools on top of Kubernetes.

Further information about addons can be found in the [kkp documentation](https://docs.kubermatic.com/kubermatic/main/architecture/concept/kkp-concepts/applications/).

You will add the [training-application](https://github.com/cloudnativetrainings/training-application) to your user cluster.

## Apply the Application Defintions

```bash
# apply the application definitions
kubectl apply -f /training/kkp/training-application.yaml

# verify the application definitions
kubectl get applicationdefinitions
```

## Deploy the applications into your user cluster

You will be able to deploy the applications in your user cluster after ~ 30 seconds. You have to do the following in the KKP UI:

- Choose your user cluster
- Click the `Applications` Tab
- Click the `Add Application` Button
- Add the application `training-application`

## Verify your application

```bash
# verify the helm release
helm --kubeconfig /training/kubeconfig-admin-XXXXX -n training-application ls

# verify the application
kubectl --kubeconfig=/training/kubeconfig-admin-XXXXX -n training-application get all

# get the external ip of the service
# => afterwards you can visit the application via your browser http://<EXTERNAL-IP>:80/
kubectl --kubeconfig=/training/kubeconfig-admin-XXXXX -n training-application get svc
```
