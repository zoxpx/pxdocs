---
title: Shared
hidden: true
---

After you have generated the spec file, deploy Portworx:

```text
kubectl apply -f px-spec.yaml
```

Monitor the portworx pods:

```text
kubectl get pods -o wide -n kube-system -l name=portworx
```

Monitor Portworx cluster status:

```text
PX_POD=$(kubectl get pods -l name=portworx -n kube-system -o jsonpath='{.items[0].metadata.name}')
kubectl exec $PX_POD -n kube-system -- /opt/pwx/bin/pxctl status
```

You are now ready to install an application that uses Portworx. This is discussed in the next topic.


{{< widelink url="/portworx-install-with-kubernetes/application-install-with-kubernetes" >}}Stateful applications on Kubernetes{{</widelink>}}