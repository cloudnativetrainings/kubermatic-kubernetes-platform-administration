# Adding System Applications to the User Cluster

Kubermatic provides some useful extensions for User Clusters out of the box. Further information about system application can be found in the [kkp documentation](https://docs.kubermatic.com/kubermatic/main/architecture/concept/kkp-concepts/applications/default-applications-catalog/).

In this lab you will add the cluster-autoscaler system application to your User Cluster.

## Enabling the System Application

- Within your cluster click on the tab `Applications` click the button `Add Application`
  - Select the `Cluster Autoscaler` within the tab `Select Application`
  - Click the button `Next` on the tab `Settings`
  - Click the button `Add Application` on the tab `Application Values`

## Engage the cluster-autoscaler on your MachineDeployment

- Click the edit button of your MachineDeployment
  - Set the `Min Replicas` to 1
  - Set the `Max Replicas` to 3

>**NOTE:**
>The effect of this change will be visible later. Cluster-autoscaling has some latency.
