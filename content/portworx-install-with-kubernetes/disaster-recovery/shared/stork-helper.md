The following steps can be used to run `storkctl`:

1.  After Portworx has been installed in your Kubernetes cluster, determine the name of the stork pods:
    ```text
    kubectl -n kube-system get pods -l name=stork
    ```
    ```
    NAME                     READY   STATUS    RESTARTS   AGE
    stork-797db76cc4-4tmc7   1/1     Running   0          23h
    stork-797db76cc4-gllml   1/1     Running   3          23h
    stork-797db76cc4-mqtmz   1/1     Running   3          23h
    ```
2.  Run `storkctl` from one of these pods:
    ```text
    kubectl -n kube-system exec -ti stork-797db76cc4-4tmc7 -- /storkctl/linux/storkctl help
    ```
