---
title: "Operating and Troubleshooting Autopilot"
linkTitle: "Operating and Troubleshooting"
keywords: troubleshoot, autopilot
description: Instructions on common operating procedures and troubleshooting for Autopilot
weight: 300
---

This section provides common operational procedures for monitoring and troubleshooting your autopilot installation.

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
