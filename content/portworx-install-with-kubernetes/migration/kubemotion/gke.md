---
title: "Kubemotion with Stork on GKE"
keywords: migration, migrate, PX-Motion, GKE, Google Kubernetes Engine, k8s, gcloud, Stork, cloud
description: How to migrate stateful appliations to GKE
hidden: true
---

Pairing with a GKE cluster requires the following additional steps because you also need to
pass in your Google Cloud credentials which will be used to generate access
tokens.

## Create a service account
Use [the guide from Google Cloud to generate a service-account key](https://cloud.google.com/iam/docs/creating-managing-service-account-keys)
and save it as gcs-key.json. You can also create this using the following command:

```text
gcloud iam service-accounts keys create gcs-key.json --iam-account <your_iam_account>
```

## Create a Secret from the service-account key
On the source cluster, create a secret in kube-system namespace with
the service account json created in the previous step:

```text
kubectl create secret  generic --from-file=gcs-key.json -n kube-system gke-creds
```

```output
secret/gke-creds created
```

## Pass the Secret to Stork
Mount the secret created above in the Stork deployment. Run `kubectl edit deployment -n kube-system stork` and make the following updates:

* Add the following under spec.template.spec:

```text
volumes:
- name: gke-creds
  secret:
     secretName: gke-creds
```

* Add the following under spec.template.spec.containers

```text
volumeMounts:
- mountPath: /root/.gke/
  name: gke-creds
  readOnly: true
```

* Add the following under spec.template.spec.containers

```text
env:
- name: CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE
  value: /root/.gke/gcs-key.json
```

Save the changes and wait for all the Stork pods to be in running state after applying the
changes:

```text
kubectl get pods -n kube-system -l name=stork
```

## Update ClusterRoleBinding

Create a clusterrolebinding to give your account the cluster-admin role

```text
kubectl create clusterrolebinding stork-cluster-admin-binding --clusterrole=cluster-admin --user=<your_iam_account>
```
