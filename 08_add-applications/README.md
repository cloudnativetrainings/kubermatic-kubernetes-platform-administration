# Adding Applications to the User Cluster

In this lab you will add your own application [training-application](https://github.com/cloudnativetrainings/training-application) to be deployable int your user clusters.

Further information about applications can be found in the [kkp documentation](https://docs.kubermatic.com/kubermatic/main/architecture/concept/kkp-concepts/applications/).

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

# get the IP of the LoadBalancer of the application
APP_IP=$(kubectl --kubeconfig kubeconfig-admin-XXXXX -n training-application get svc my-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# persist the kkp version into an environment variable
echo "export APP_IP=${APP_IP}" | tee -a /root/.trainingrc

# ensure value is set in your current bash
source /root/.trainingrc
```

## Engate "poor-mans-application-monitoring"

Keep the application running and monitor its availability in a seperate bash.

```bash
# run this 
while true; do curl -I http://$APP_IP:80/; sleep 10s; done;
```
