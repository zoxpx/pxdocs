---
title: "Operating and Troubleshooting Autopilot"
linkTitle: "Operating and Troubleshooting"
keywords: troubleshoot, autopilot
description: Instructions on common operating procedures and troubleshooting for Autopilot
weight: 300
---

This section provides common operational procedures for monitoring and troubleshooting your autopilot installation.

## Troubleshooting objects monitored by autopilot

### Get recent statuses using AutopilotRuleObjects

For each object monitored by Autopilot, it will create a corresponding `autopilotruleobject` instance in the namespace of the object.

* For volumes (PVCs), the `autopilotruleobject` instance will be in the namespace of the PVC.
* For storage pools, the `autopilotruleobject` instance will be in the namespace where Portworx is installed.

The `autopilotruleobject` is created only if an object's condiitons were atleast triggered once. In other words, you will not see an `autopilotruleobject` if the object was always in nornal state.

#### List all autopilotruleobjects 
The following command lists all Autopilot rule objects in all namespaces:
``` text
kubectl get autopilotruleobjects --all-namespaces
```

Instead of entering the full `autopilotruleobjects` string, you can use the `aro` alias.

``` text
kubectl get aro --all-namespaces
```
```output
NAMESPACE   NAME                                       AGE
pg1         pvc-ec475444-e2d6-4533-863b-03263da7b04c   1s
```

#### Describe a specific object

The `Status` section contains a list of recent object statuses:

```text
kubectl describe aro -n pg1 pvc-ec475444-e2d6-4533-863b-03263da7b04c
```
```output
Name:         pvc-ec475444-e2d6-4533-863b-03263da7b04c
Namespace:    pg1
Labels:       rule=volume-resize
Annotations:  <none>
API Version:  autopilot.libopenstorage.org/v1alpha1
Kind:         AutopilotRuleObject
Metadata:
  Creation Timestamp:  2020-08-26T22:29:45Z
  Generation:          2
  Owner References:
    API Version:           autopilot.libopenstorage.org/v1alpha1
    Block Owner Deletion:  true
    Controller:            true
    Kind:                  AutopilotRule
    Name:                  volume-resize
    UID:                   070e9932-5f6f-448c-a14a-62fbd2d5dbbc
  Resource Version:        7554069
  Self Link:               /apis/autopilot.libopenstorage.org/v1alpha1/namespaces/pg1/autopilotruleobjects/pvc-ec475444-e2d6-4533-863b-03263da7b04c
  UID:                     06030869-e1dd-4016-b12c-37fe57310baf
Status:
  Items:
    Last Process Timestamp:  2020-08-26T22:29:45Z
    Message:                 rule: volume-resize:pvc-ec475444-e2d6-4533-863b-03263da7b04c transition from Normal => Triggered
    State:                   Triggered
    Last Process Timestamp:  2020-08-26T22:30:19Z
    Message:                 rule: volume-resize:pvc-ec475444-e2d6-4533-863b-03263da7b04c transition from Triggered => ActionAwaitingApproval
    State:                   ActionAwaitingApproval
Events:                      <none>
```

#### List autopilotruleobjects for a given autopilotrule

You can use the label selector `rule=<RULE_NAME>` for list `autopilotruleobjects` only for that autopilotrule.

```text
kubectl get aro --all-namespaces -l rule=volume-resize
```
```output
NAMESPACE   NAME                                       AGE
pg1         pvc-ec475444-e2d6-4533-863b-03263da7b04c   4m3s
```


## Troubleshooting autopilot

### Collecting a support bundle

1. Create a directory (`ap-cores`) in which to store your support bundle files and send the support signal to the autopilot process:

      ```text
      mkdir ap-cores
      POD=$(kubectl get pods -n kube-system -l name=autopilot | grep -v NAME | awk '{print $1}')
      kubectl exec -n kube-system $POD -- killall -SIGUSR1 autopilot
      ```

2. Copy the support bundle files from your Kubernetes cluster to your directory:

      ```text
      kubectl cp  kube-system/$POD:/var/cores ap-cores/
      ls ap-cores
      ```

3. Collect and place your autopilot pod logs into an `autopilot-pod.log` file within your temporary directory:

      ```text
      kubectl logs $POD -n kube-system --tail=99999 > ap-cores/autopilot-pod.log
      ```

Once you've created a support bundle and collected your logs, send all of the files in the `ap-cores/` directory to Portworx support.
