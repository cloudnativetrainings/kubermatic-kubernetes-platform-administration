# Adding Addons to the User Cluster

Kubermatic provides some useful extensions for User Clusters out of the box. Further information about addons can be found in the [kkp documentation](https://docs.kubermatic.com/kubermatic/main/architecture/concept/kkp-concepts/addons/).

In this lab you will add the cluster-autoscaler addon to your User Cluster.

## Enabling the Addon

- Within your cluster click on the tab `Addons`
- Select the cluster-autoscaler addon
  - Within the tab `Select Addon`
  - Enable the checkbox `Continously reconcile addon`

## Engage the cluster-autoscaler on your MachineDeployment

- Click the edit button of your MachineDeployment
  - Set the `Min Replicas` to 1
  - Set the `Max Replicas` to 3

>**NOTE:**
>The effect of this change will be visible later. Cluster-autoscaling has some latency.
