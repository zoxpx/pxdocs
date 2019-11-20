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
| **namespaceSelector**     	| Selects the namespaces affected by this rule using a matchLabels label selector. [Syntax](#namespaceSelector).                                                      	| yes       	| all        	|
| **conditions**            	| Defines the metrics that need to be for the rule's actions to trigger. All conditions are AND'ed. [Syntax](#conditions).                                            	| no        	| empty      	|
| **actions**               	| Defines what action to take when the conditions are met. [Syntax](#actions). See [Supported Actions](#supported-actions) for all actions that you can specify here. 	| no        	| empty      	|
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
    <operation-specific-parameter>: <value>
```

## Supported Autopilot actions

### openstorage.io.action.volume/resize

This action is to perform resize on Kubernetes PersistentVolumeClaims (PVCs).

##### Parameters

* **scalepercentage**: Specifies the percentage of current PVC size by which Autopilot should resize the PVC. If not specified, the default is *50%*.
* **maxsize**: Specifies the maximum threshold size in bytes after which Autopilot should stop resizing the PVCs. Note that you can specify the unit of measurement as part of the value. For example, if you want to use GiB, you can specify the unit of measurement like this: `maxsize: "400Gi"`. If not specified, the default value is unlimited.

##### Examples

Resize the PVC by 100% of current size

```text
  actions:
  - name: openstorage.io.action.volume/resize
    params:
      scalepercentage: "100"
```


### openstorage.io.action.storagepool/expand

This action is to perform expansion on Portworx Storage Pools.

##### Parameters

* **scalepercentage**: Specifies the percentage of current Pool size by which Autopilot should resize it. If not specified, the default is *50%*.
* **scaletype**: Specifies the type of operation to be performed to expand the pool. Supported values are:
    * *add-disk*: Portworx will add new disk(s) to the existing storage pool
    * *resize-disk*: Portworx will resize existing disks in the storage pool

##### Examples

Expand the pool by 50% of current size by adding disks

```text
  actions:
  - name: openstorage.io.action.storagepool/expand
    params:
      scalepercentage: "50"
      scaletype: "add-disk"
```
