---
title: "Reference"
linkTitle: "Reference"
keywords: autopilot
description: References for the AutopilotRule specification, supported actions and other useful reference material
series: autopilot-home
noicon: true
weight: 3
---

## AutopilotRule CRD specification

| Field                     	| Description                                                                                                                                                         	| Optional? 	| Default    	|
|---------------------------	|---------------------------------------------------------------------------------------------------------------------------------------------------------------------	|-----------	|------------	|
| **selector**              	| Selects the objects affected by this rule using a matchLabels label selector. [Syntax](#selector).                                                                  	| no        	| empty      	|
| **namespaceSelector**     	| Selects the namespaces affected by this rule using a matchLabels label selector. [Syntax](#namespaceselector).                                                      	| yes       	| all        	|
| **conditions**            	| Defines the metrics that need to be for the rule's actions to trigger. All conditions are AND'ed. [Syntax](#conditions).                                            	| no        	| empty      	|
| **actions**               	| Defines what action to take when the conditions are met. [Syntax](#actions). See [Supported Autopilot actions](#supported-autopilot-actions) for all actions that you can specify here. 	| no        	| empty      	|
| **pollInterval**          	| Defines the interval in seconds at which the conditions for the rule are queried from the metrics provider.                                                         	| yes       	| 10 seconds 	|
| **actionsCoolDownPeriod** 	| Defines the duration in seconds for which autopilot will not re-trigger any actions once they have been executed.                                                   	| yes       	| 5 minutes  	|

### selector

Selects the objects affected by this rule using a matchLabels label selector.

```text
selector:
  matchLabels:
    <selector-key>: <selector-value>
```

### namespaceSelector

Selects the namespaces affected by this rule using a matchLabels label selector.

```text
namespaceSelector:
  matchLabels:
    <selector-key>:<selector-value>
```

### conditions

Defines the metrics that need to be for the rule's actions to trigger.

```text
conditions:
  - key: "<condition-formula>"
    operator: <logical-operator>
    values:
    - "<comparator>"
```

Conditions compare the `key` field with the `values` field using the `operator` field. Condition keys can contain logic and use monitoring values.

{{<info>}}Multiple conditions are combined using a logical AND.{{</info>}}

### actions

Defines what action to take when the conditions are met. See [Supported Actions](#supported-actions) for all actions that you can specify here.

```text
action:
  name: <operation>
  params:
    <operation-specific-paramater>: <value>
    maxsize: "<value>Gi"
```

## Supported Autopilot actions

### openstorage.io.action.volume/resize

This action is to perform resize on Kubernetes PersistentVolumeClaims (PVCs).

##### Parameters

* **scalepercentage**: Specifies the percentage of current PVC size by which Autopilot should resize the PVC. If not specified, the default is *50%*.
* **maxsize**: Specifies the maximum PVC size in bytes after which Autopilot should stop resizing the PVCs. Note that you can specify the unit of measurement as part of the value. For example, if you want to use GiB, you can specify the unit of measurement like this: `maxsize: "400Gi"`. If not specified, the default value is unlimited.


##### Examples

Resize the PVC by 100% of current size

```text
  actions:
  - name: openstorage.io.action.volume/resize
    params:
      scalepercentage: "100"
      maxsize: "12Gi"
```


### openstorage.io.action.storagepool/expand

This action is to perform expansion on Portworx Storage Pools.

##### Parameters

* **scalepercentage**: Specifies the percentage of current Pool size by which Autopilot should resize it. If not specified, the default is *50%*.
* **scaletype**: Specifies the type of operation to be performed to expand the pool. Supported values are:
    * *add-disk*: Portworx will add new disk(s) to the existing storage pool
    * *resize-disk*: Portworx will resize existing disks in the storage pool
* **scalesize**: Specifies the amount, in Gi or Ti, by which Autopilot should expand a storage pool.

{{<info>}}
**NOTE:** You cannot combine the **scalepercentage** and **scalesize** parameters; use only one of them in an Autopilot rule.
{{</info>}}

##### Examples

Expand the pool by 50% of current size by adding disks

```text
  actions:
  - name: openstorage.io.action.storagepool/expand
    params:
      scalepercentage: "50"
      scaletype: "add-disk"
```

Expand the pool by 100Gi by resizing disks

```text
  actions:
  - name: openstorage.io.action.storagepool/expand
    params:
      scalesize: "100Gi"
      scaletype: "resize-disk"
```

## Autopilot Events

You can view the actions Autopilot takes by querying Autopilot events. These events provide insight into how your Autopilot rules are functioning, what actions they may be taking, and what actions they have taken in the past.

| **Autopilot rule event** | **Description** |
| ---- | ---- |
| Initializing | The rule's initial startup state where monitoring has not yet begun. |
| Normal | Autopilot is monitoring the rule as expected. |
| Triggered | The rule has its activation conditions met. |
| ActiveActionsPending | The rule's activation conditions have been met, but the actions are not yet being performed. |
| ActiveActionsTaken | Autopilot has performed the rule's actions, but still hasn't moved out of the active status. |
| ActionsDeclined | Autopilot has intentionally declined to perform a rule's action, for example when a PVC reaches a maximum user-defined size. |
| ActiveActionsInProgress | The rule is active and had its conditions met and there is an ongoing action on the object. |
| ActionNotLicensed | The action Autopilot is trying to perform is not permitted due to license restrictions |

You can query events from Kubernetes by entering the following `kubectl get events` command:

```text
kubectl get events --field-selector involvedObject.kind=AutopilotRule
```
```output
LAST SEEN   FIRST SEEN   COUNT   NAME                                   KIND            SUBOBJECT   TYPE      REASON           SOURCE      MESSAGE
41m         41m          1       pvc-total-size-15gi.15f13fcf9664716d   AutopilotRule               Normal    Transition       autopilot   rule: pvc-total-size-15gi:pvc-8c20c7bb-49fa-11ea-a206-000c29fda8e7 transition from Initializing => Normal
41m         41m          1       pvc-total-size-15gi.15f13fcf96a75e4f   AutopilotRule               Normal    Transition       autopilot   rule: pvc-total-size-15gi:pvc-8c292b08-49fa-11ea-a206-000c29fda8e7 transition from Initializing => Normal
36m         38m          2       pvc-total-size-15gi.15f14003ff20f5ec   AutopilotRule               Normal    Transition       autopilot   rule: pvc-total-size-15gi:pvc-8c20c7bb-49fa-11ea-a206-000c29fda8e7 transition from ActiveActionsInProgress => ActiveActionsTaken
35m         37m          2       pvc-total-size-15gi.15f140126cc4021c   AutopilotRule               Normal    Transition       autopilot   rule: pvc-total-size-15gi:pvc-8c20c7bb-49fa-11ea-a206-000c29fda8e7 transition from ActiveActionsTaken => Normal
35m         38m          3       pvc-total-size-15gi.15f13ff9ae4cc963   AutopilotRule               Normal    Transition       autopilot   rule: pvc-total-size-15gi:pvc-8c20c7bb-49fa-11ea-a206-000c29fda8e7 transition from Normal => Triggered
34m         34m          2       pvc-total-size-15gi.15f14032de7660a7   AutopilotRule               Normal    Transition       autopilot   rule: pvc-total-size-15gi:pvc-8c20c7bb-49fa-11ea-a206-000c29fda8e7 transition from ActiveActionsInProgress => ActionsDeclined
```
