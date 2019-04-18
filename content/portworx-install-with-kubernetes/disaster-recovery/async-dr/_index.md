---
title: Asynchronous DR
linkTitle: Asynchronous DR
keywords: cloud, backup, restore, snapshot, DR, migration, px-motion
description: How to achieve asynchronous DR across Kubernetes clusters using schduled migrations
weight: 2
---

## Pre-requisites

* **Version**: Portworx v2.1 or later needs to be installed on both clusters. Also requires Stork v2.2+ on both the clusters.
* **Secret Store** : Make sure you have configured a [secret store](/key-management) on both your clusters. This will be used to store the credentials for the objectstore.
* **Network Connectivity**: Ports 9001 and 9010 on the destination cluster should be reachable by the source cluster.
* **Stork helper**: `storkctl` is a command-line tool for interacting with a set of scheduler extensions.
{{% content "portworx-install-with-kubernetes/disaster-recovery/shared/stork-helper.md" %}}

## Overview

With asynchronous DR, you can replicate Kubernetes applications and their data between two Kubernetes clusters. Here, a separate Portworx Enterprise cluster runs under each Kubernetes cluster. 

* The active Kubernetes cluster asynchronously backs-up apps, configuration and data to a standby Kubernetes cluster.
* The standby Kubernetes cluster has running controllers, configuration and PVCs that map to a local volumes.
* Incremental changes in Kubernetes applications and Portworx data are continuously sent to the standy cluster

## Enable DR mode

By default, every 7th migration will be a full migration. For DR though, we want every migration to be incremental. This can be enabled by setting the mode for the clusterPair to DisasterRecovery. For example, for the clusterPair below, we can add the mode under spec.options:

```text
apiVersion: stork.libopenstorage.org/v1alpha1
kind: ClusterPair
metadata:
  creationTimestamp: null
  name: remotecluster
spec:
  config:
    clusters:
      kubernetes:
        LocationOfOrigin: /etc/kubernetes/admin.conf
        certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUN5RENDQWJDZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRFNE1EVXdNekF3TURFME9Wb1hEVEk0TURRek1EQXdNREUwT1Zvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTUFlCiszV2wvakZsUVdlWVZSZE1yV0U1VTVKOXE5TUpUdnUwNDdka1BOLzlYcitld25SVndwcFp5NXB6Q2ZjbEJ4ZDkKZndFcVlad2xEMzhjVU5kekRDdXczT3A5VTJuOVNRVk5iREh6b1JpVUZkV3ZSL2N1RkZYZ0h2WWJwWWo4TTB0VwpwL0JkSU93cXRXTEd0Vm5BeEV5cUhxVEFZOG5NSXQ0Y0thUS9reW1aWFlwSzVxWGxaUXBaL3o0dGZrQXFaUjZXCkhKSmM5QTYwZEVpMzIrcklhM2dZTVM4VFd4Y3cyNFFIVW9QakFLcFNndnZoRGNYNlIvOUhwelVwU3RONlQ5Z04KWUg3UU5JNjFHMkNVbmVrbTV4NGhVU1VoeXpmeDB2MXRUeFl6dFViVEdFNVplcTZZQVFEYVRJeGhwU3NJbHZXbApTOVVTUldycmRzUThpV2JHK2NVQ0F3RUFBYU1qTUNFd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0RRWUpLb1pJaHZjTkFRRUxCUUFEZ2dFQkFMaUw3QVQ0R09CaDR0aGdkTmVzVnQ2ekRVd0UKUU84akhpdFlBTWd5cXEwMGRyYXZ0MVdXc2UzcVpDRWc2RHRvUkkxQkRKaGZPNlFWMERUd1lyeW40b3Zkck5CTwpXMTlvTzV6MENEWGQxcVEvVmNvaUVJaTlXY1ovQkVHeTlUL202c2ZLQ2ZpRHJQZUp4a2ZubnJXOGg1U09oQ0NiCnVXNjdpMFpqRFY0dFdGMlpwWEpaZkt6MmZHWEZIQWVqcHMyVnZFYWJuWk1KZDhuRjUyUk4xSXpxdlZITEI5SHUKUHlFQWZmYmJ0b0ZRQ0Y1YjJYaGtOU1RsRXBpMFRGMUQ0ejFzMERyRGpLU0U5Ym03Zjluak1ycUpCRmx1ajA4NgpIYTlCWEhkOFRrVS95blNiU0hsQzNadlIraE9ZVTE1Z0RTU3dKZC8zclMzVUIvWUlXUy9qWC9LNXc2dz0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=
        server: https://192.168.56.74:6443
    contexts:
      kubernetes-admin@kubernetes:
        LocationOfOrigin: /etc/kubernetes/admin.conf
        cluster: kubernetes
        user: kubernetes-admin
    current-context: kubernetes-admin@kubernetes
    preferences: {}
    users:
      kubernetes-admin:
        LocationOfOrigin: /etc/kubernetes/admin.conf
        client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUM4akNDQWRxZ0F3SUJBZ0lJQ2s4VTZ4L0RNZEV3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB4T0RBMU1ETXdNREF4TkRsYUZ3MHhPVEExTURNd01EQXhOVEZhTURReApGekFWQmdOVkJBb1REbk41YzNSbGJUcHRZWE4wWlhKek1Sa3dGd1lEVlFRREV4QnJkV0psY201bGRHVnpMV0ZrCmJXbHVNSUlCSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQVE4QU1JSUJDZ0tDQVFFQXg2ZWEzVlVqV3RlZXlqS0kKd2g2T2RCL2l3QWhoSm5YUk1wQmRPcXFjY1g2S3dUTUpJZks4MGwrZENNL0ZLU1U1TnhKZHZaUlZDRnlMVDE5WQpOdzFHTHFmSWIyUnBKTHh4RHBETVU2VFBtaE1keVRNck8wRXB2UVpsc2g2cjhObUoxNWM5R1Z3Q0gyRUJKVitGClFwT1ZXK05XWitLc3IxNE9NY1hWdkIreG8rL0NQaEhjQkl1TG4rcUpHcUI1dHJQSWhwM3JEYTdleXljS1pZUTIKT0U1akh4M2tvWWo4c0c5Vkw1T2VEamVvYVZaOGlmTmRldjJqRnEreWsyMVVmMHFiTTZ6c2MxTXllT3JuYytGVQp3b0h2elo2U0Rob0ZzNVJiV3M2RXBoNkl6V0JKNm8rYjk0cHI0WlN6R2VEc2ZCM1FWM1h2RVRHTXg3YVU0UmRyClJEcyt4UUlEQVFBQm95Y3dKVEFPQmdOVkhROEJBZjhFQkFNQ0JhQXdFd1lEVlIwbEJBd3dDZ1lJS3dZQkJRVUgKQXdJd0RRWUpLb1pJaHZjTkFRRUxCUUFEZ2dFQkFDU2xCQTk2SURkdm1icnBwTHlhWTlLNGRGcjBXb0ZxMDFlaQprRXZVZDNFbElQbG9SWmtyWGFQTnB0dGR6Z2t2aE9TTUNxZnpLMnFHVCtmRS9DYUFqSElTK3V3MjR0MWJFQU84CjA2NlJ1Ullwc2l2aVVXdUVRWmpiaVpnRGc4SkRlaVRnUzUyR3dBUXdqNlI2RW5kcWVQZUdkaHlFTGxFQVFpckoKWk52Q0s1eHNDR0EySGhuKzVMMXdmZEYvYi9KUFBrZ0xiaXNCbk11cnhUZ3J2Z0llTlpmQlI2bHdSOTZYRmhpSQpWU3lEbnUyUEFqdHlEYWtKOHMvZ0R1ck8ya25FS0lzbU9rTlZVVW9ybkt1NXY3R0hMdm9qN0MvbVBJWlQwemxwCnZYK0Q4WHU3RFRUMkwrUDlQbkM4a1U0RDZmMnZQRWVGY2xOL1JpMVR0TnViTzJqc1MrRT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=
        client-key-data: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFcEFJQkFBS0NBUUVBeDZlYTNWVWpXdGVleWpLSXdoNk9kQi9pd0FoaEpuWFJNcEJkT3FxY2NYNkt3VE1KCklmSzgwbCtkQ00vRktTVTVOeEpkdlpSVkNGeUxUMTlZTncxR0xxZkliMlJwSkx4eERwRE1VNlRQbWhNZHlUTXIKTzBFcHZRWmxzaDZyOE5tSjE1YzlHVndDSDJFQkpWK0ZRcE9WVytOV1orS3NyMTRPTWNYVnZCK3hvKy9DUGhIYwpCSXVMbitxSkdxQjV0clBJaHAzckRhN2V5eWNLWllRMk9FNWpIeDNrb1lqOHNHOVZMNU9lRGplb2FWWjhpZk5kCmV2MmpGcSt5azIxVWYwcWJNNnpzYzFNeWVPcm5jK0ZVd29IdnpaNlNEaG9GczVSYldzNkVwaDZJeldCSjZvK2IKOTRwcjRaU3pHZURzZkIzUVYzWHZFVEdNeDdhVTRSZHJSRHMreFFJREFRQUJBb0lCQVFDWEpXMTZEZEFjSDR3WQpxclVac0NSTUNTK1NEVVh1NWRhZm51YlZXUC9pYzlmN2R2VjgrOVN5dHF1ZFZoMStqcTJINGFHUnVjKzk2c0dVCkx5d0xVVU5HWXNLOGdabVB0QkVxNDdlcnd1TmZVd1dEb2ZjaWZxeG9hNFZsbVE2MTRSb1hXbWxvMzF6RUFKM3IKZXlyWlFmMGFlVHFhbnVINFNRNFo1Qmx3dDlXMXNxQlRnYVRmNVY5NjlHa3ROQzF2b2VBbXNCa21OQllBaGJvKwovL1VtTVQ2SzhzMnAxZlovSjRqaDJoOTg2b0h3MHNGR3YyTDBqeWIzVWRNbG9QU3VPam1YSHkwQlkybFFaM3luCjI0clExV3UyRHVuNTFHdFcxbmFsSGR3RXhaYzJYdzZoOU94eDF2SWlraStoRyt6cHNyeWEycnd5Y2IrZFV5OWMKR0gvYm4xVEJBb0dCQU9Xa2tna0s0RXhvekN2QzIrZTA2UnorUzlUdFlCenNJaFJuTHRIc3k3Z25JZmVJZWV3ZAoyaTRyZGF0ZnVoRWkwUElja2cyVURDMitkbHpBeWhhTitjaTB3ZEN2WmxzRkNaZjIrQlpnZUlvaC9LalNmOTNVCjFGa3JjV09LVHJJME5IUldGUWxhVnlTaDlJWDFUSC9YTVdiNDFtRWplczNWeW1qYWJ0MHE1MzM1QW9HQkFONlIKNmgxZlE4a0FkMW0yV2RkTjl2YVRBQTVsTEx0NFJ6V1BFMy83V3dRUlZTTHo4NFVUYkd1bElTdk9VUVFPL09obQpsaHZzRjVlTlNKc2ZTQU8yaFJlaGJ3alF4V0FsM3A4MTg3bVpETFQ2MG9iZlNtdUNVVnA0MFF0WFdSbXFnY0xRClNKZXRWVVY4Z3BRWWROczk5MGwybkF6MUpQQmhpVFBzbkwvbXFXb3RBb0dBQ09QREIzaVZVRC9xVDNOZW9leWQKN1pKbWl4cVpVdVZOT0c3NklBUkRxcUJSTDB6b00xekFlbk1TUGcwWm5kbzBMbnN1cURubjhzbGh1WnQ0OTBDTgp2OWhIZkhXZHg3NDlMZFhRcXNVWFJYbWxWeisyMVhhTXRkcjVxN25KN0JvYlFibW5YTkpUZDBhUnViSFNRVXlxClMrc3NHVnlQUDNLY1FFemNaOUZtWHJrQ2dZQlB4SHZqaXdFQVNPcDlmSjAyVFByMTVEbGc3MkhZem9LMjcxQk4KemdnUXJTV1dJVmhsbVZDQ1EreGZodElDWWx6QjdnSmVmMzcxRWUyenFzSmtra1dnOG5xWTdqbk8rOE9OekFoTgp2RXlSa0ZOamd5Tm81SXZEb1FsS3gwTm5yM1JTSGRQbWlIakhMcGlkK3lYbWJZN3pCVTlvVlhPbnMwMDVEdFFlCjhzeEZBUUtCZ1FEaDdkVGpzZDRueWlSRnFNVFVCM1lFcWFVMjBDQXh2b0xqOTRVWUYyWEo2RnNKMnpxRTBvc0IKdklsKzg4c3FUcmNzQkFETDUrZXB1REY5ckVjVm9rV2xuaFgxRUZYbHd0NFVOTE5JSjN5bHhsRTkrZkk1YWZOSgorejNPVG9OTVR2WDZiOUFBUGRTbVY2akphVjNXZ1lwa1FoSkh1SXR3SldZOGZSbnFtWWgxOGc9PQotLS0tLUVORCBSU0EgUFJJVkFURSBLRVktLS0tLQo=
  options:
    ip:     <ip_of_remote_px_node>
    port:   <port_of_remote_px_node_default_9001>
    token:  <token_from_step_3>
    mode: DisasterRecovery
status:
  remoteStorageId: ""
  schedulerStatus: ""
  storageStatus: ""
```

{{% content "portworx-install-with-kubernetes/disaster-recovery/shared/schedule-policy.md" %}}

### Scheduling a migration

Once a policy has been created, you can use it to schedule a migration. The spec for the MigrationSchedule spec contains the same fields as the Migration spec with the addition of the policy name. The MigrationSchedule object is namespaced like the Migration object.

Note that `startApplications` should be set to false in the spec. Otherwise, the first Migration will start the pods on the remote cluster and will succeed. But all subsequent migrations will fail since the volumes will be in use.

Continuing our previous example with `testpolicy`, here is how to create a `MigrationSchedule` object that schedules a migration:

```text
apiVersion: stork.libopenstorage.org/v1alpha1
kind: MigrationSchedule
metadata:
  name: mysqlmigrationschedule
  namespace: mysql
spec:
  template:
    spec:
      clusterPair: remotecluster
      includeResources: true
      startApplications: false
      namespaces:
      - mysql
  schedulePolicyName: testpolicy
```

If the policy name is missing or invalid there will be events logged against the schedule object. Success and failures of the migrations created by the schedule will also result in events being logged against the object. These events can be seen by running a `kubectl describe` on the object

The output of `kubectl describe` will also show the status of the migrations that were triggered for each of the policies along with the start and finish times. The statuses will be maintained for the last successful migration and any Failed or InProgress migrations for each policy type.

Let's now run `kubectl describe` and see how the output would look like:

```text
kubectl describe migrationschedules.stork.libopenstorage.org -n mysql
```

```
Name:         mysqlmigrationschedule

Namespace:    mysql
Labels:       <none>
Annotations:  kubectl.kubernetes.io/last-applied-configuration:
                {"apiVersion":"stork.libopenstorage.org/v1alpha1","kind":"MigrationSchedule","metadata":{"annotations":{},"name":"mysqlmigrationschedule",...
API Version:  stork.libopenstorage.org/v1alpha1
Kind:         MigrationSchedule
Metadata:
  Creation Timestamp:  2019-02-14T04:53:58Z
  Generation:          1
  Resource Version:    30206628
  Self Link:           /apis/stork.libopenstorage.org/v1alpha1/namespaces/mysql/migrationschedules/mysqlmigrationschedule
  UID:                 8a245c1d-3014-11e9-8d3e-0214683e8447
Spec:
  Schedule Policy Name:  daily
  Template:
    Spec:
      Cluster Pair:       remotecluster
      Include Resources:  true
      Namespaces:
        mysql
      Post Exec Rule:
      Pre Exec Rule:
      Selectors:           <nil>
      Start Applications:  false
Status:
  Items:
    Daily:
      Creation Timestamp:  2019-02-14T22:16:51Z
      Finish Timestamp:    2019-02-14T22:19:51Z
      Name:                mysqlmigrationschedule-daily-2019-02-14-221651
      Status:              Successful
    Interval:
      Creation Timestamp:  2019-02-16T00:40:52Z
      Finish Timestamp:    2019-02-16T00:41:52Z
      Name:                mysqlmigrationschedule-interval-2019-02-16-004052
      Status:              Successful
      Creation Timestamp:  2019-02-16T00:41:52Z
      Finish Timestamp:    <nil>
      Name:                mysqlmigrationschedule-interval-2019-02-16-004152
      Status:              InProgress
    Monthly:
      Creation Timestamp:  2019-02-14T20:05:41Z
      Finish Timestamp:    2019-02-14T20:07:41Z
      Name:                mysqlmigrationschedule-monthly-2019-02-14-200541
      Status:              Successful
    Weekly:
      Creation Timestamp:  2019-02-14T22:13:51Z
      Finish Timestamp:    2019-02-14T22:16:51Z
      Name:                mysqlmigrationschedule-weekly-2019-02-14-221351
      Status:              Successful
Events:
  Type    Reason      Age                    From   Message
  ----    ------      ----                   ----   -------
  Normal  Successful  4m55s (x53 over 164m)  stork  (combined from similar events): Scheduled migration (mysqlmigrationschedule-interval-2019-02-16-003652) completed successfully
```

Each migration is associated with a Migrations object. To get the most important information, type:

```
kubectl get migration -n mysql
```

```
NAME AGE
mysqlmigrationschedule-daily-2019-02-14-221651 1d
mysqlmigrationschedule-interval-2019-02-16-004052 5m
mysqlmigrationschedule-interval-2019-02-16-004152 4m
mysqlmigrationschedule-monthly-2019-02-14-200541 1d
mysqlmigrationschedule-weekly-2019-02-14-221351 1d
```

Once the MigrationSchedule object is deleted, all the associated Migration objects should also be deleted as well.