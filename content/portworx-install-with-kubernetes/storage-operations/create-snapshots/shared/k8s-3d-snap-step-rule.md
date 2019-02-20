---
title: Shared
hidden: true
description: Shared content for Kubernetes snapshots
keywords: portworx, kubernetes
---

For each of the snapshot types, Portworx supports specifying pre and post rules that are run on the application pods using the volumes being snapshotted. This allows users to quiesce the applications before the snapshot is taken and resume I/O after the snapshot is taken.

The high level workflow for configuring 3DSnaps involves creating rules and later on referencing the rules when creating the snapshots.

## Step 1: Create Rules

A Stork `Rule` is a Custom Resource Definition (CRD) that allows to define actions that get performed on pods matching selectors. Below are the supported fields:

* **podSelector**: The actions will get executed on pods that only match the label selectors given here.
* **actions**: This contains a list of actions to be performed. Below are supported fields under actions:
    * **type**: The type of action to run. Only type _command_ is supported.
    * **background**: If _true_, the action will run in background and will be terminated by Stork after the snapshot has been initiated. If false, the action will first complete and then the snapshot will get initiated.
      * If background is set to _true_, add `${WAIT_CMD}` as shown in the examples below. This is a placeholder and Stork will replace it with an appropriate command to wait for the command is done.
    * **value**: This is the actual action content. For example, the command to run.
    * **runInSinglePod**: If _true_, the action will be run on a single pod that matches the selectors.
    