---
title: 1. Prepare your platform
weight: 1
---

Portworx supports Openshift 3.7 and above.

### Add Portworx service accounts to the privileged security context

```text
oc adm policy add-scc-to-user privileged system:serviceaccount:kube-system:px-account
oc adm policy add-scc-to-user privileged system:serviceaccount:kube-system:portworx-pvc-controller-account
oc adm policy add-scc-to-user anyuid system:serviceaccount:default:default
```

### Prepare a docker-registry credentials secret

Create a Red Hat account if you don't already have one \([register here](https://www.redhat.com/wapps/ugc/register.html)\).

Configure a [Kubernetes secret](https://kubernetes.io/docs/concepts/containers/images/#creating-a-secret-with-a-docker-config) with username/password credentials:

```text
# confirm the username/password works  (e.g. user:john-rhel, passwd:s3cret)
docker login -u john-rhel -p s3cret registry.connect.redhat.com
> Login Succeeded

# configure username/password as a kubernetes "docker-registry" secret  (e.g. "regcred")
oc create secret docker-registry regcred --docker-server=registry.connect.redhat.com \
  --docker-username=john-rhel --docker-password=s3cret --docker-email=test@acme.org \
  -n kube-system
```