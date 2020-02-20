---
title: "Working with Autopilot Rules"
linkTitle: "Working with Autopilot Rules"
keywords: install, autopilot
description: Shows useful information about working with Autopilot Rules
weight: 200
---

## Understanding an AutopilotRule

Users use an AutopilotRule [CRD](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/) to tell Autopilot which objects to monitor, the conditions to monitor, and the corresponding actions to perform when conditions occur.

An AutopilotRule has 4 main parts:

1. **Selector** Matches labels on the objects that the rule should monitor.
2. **Namespace Selector** Matches labels on the Kubernetes namespaces the rule should monitor. This is optional, and the default is all namespaces.
3. **Conditions** The metrics for the objects to monitor.
4. **Actions** to perform once the metric conditions are met.

The subsequent sections describe common operations for managing these rules.

## Creating an AutopilotRule

1. Create an `AutopilotRule` spec file.
  * The [Use cases page](/portworx-install-with-kubernetes/autopilot/use-cases/) provides end-to-end examples on specific Autopilot use cases. Refer to these to help you create your spec.
  * The [AutopilotRule Reference page](/portworx-install-with-kubernetes/autopilot/reference) page defines the specification of the rule spec.

2. Apply the spec in your cluster.

    ```text
    kubectl apply -f volume-resize-autopilotrule.yaml
    ```
    ```output
    autopilotrule.autopilot.libopenstorage.org/volume-resize created
    ```

## Updating an AutopilotRule

You can update an autopilot rule in-place with the `kubectl edit` command:

```text
kubectl edit autopilotrule volume-resize
```

## Deleting an AutopilotRule

Delete an Autopilot rule by using `kubectl delete autpilotrule` and specifying the rule you want to delete. When you do this, Autopilot stops monitoring all objects that match this rule.

```text
kubectl delete autopilotrule volume-resize
```
```output
autopilotrule.autopilot.libopenstorage.org "volume-resize" deleted
```


## Monitoring AutopilotRules

Autopilot generates events, which you can monitor with the `kubectl get events` command:

* To see events for all `AutopilotRule` objects:
  ```text
  kubectl get events --field-selector involvedObject.kind=AutopilotRule --all-namespaces
  ```

* To see events for a specific `AutopilotRule` object, you must add `involvedObject.name` and the name of your Autopilot rule.

  In below example, we are listing all events for the `volume-resize` rule.
  ```text
  kubectl get events --field-selector involvedObject.kind=AutopilotRule,involvedObject.name=volume-resize --all-namespaces
  ```
  ```output
  NAMESPACE   LAST SEEN   TYPE     REASON       KIND            MESSAGE
default     21m         Normal   Transition   AutopilotRule   rule: pvc-5bfcabfd-d017-11e9-bcdf-aa931955114b transition from Initializing => Normal
default     21m         Normal   Transition   AutopilotRule   rule: pvc-5c9a6451-d017-11e9-bcdf-aa931955114b transition from Initializing => Normal
default     9m52s       Normal   Transition   AutopilotRule   rule: pvc-5bfcabfd-d017-11e9-bcdf-aa931955114b transition from Initializing => Normal
default     9m48s       Normal   Transition   AutopilotRule   rule: pvc-5c9a6451-d017-11e9-bcdf-aa931955114b transition from Initializing => Normal
```
