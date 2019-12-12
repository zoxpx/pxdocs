---
hidden: true
---

From **Portworx version 2.1** support for cluster-wide secrets has been deprecated. If you have volumes (using cluster-wide secret) that were created using older Portworx versions, those volumes will still seamlessly work with newer Portworx versions.

However, if you wish to use your previous cluster-wide secret, then you will need to pass its name as shown in the previous Named secrets section.

For example,

Lets say your generated KMS data key was called `portworx_secret` and you had set it as a your cluster-wide secret using the command `pxctl secrets set-cluster-key portworx_secret`.

To create new volumes using that same secret you will need to follow the previous Named secret section and provide the name `portworx_secret` as show above.

Again, existing volumes created with cluster wide, will still work without providing `portworx_secret`.

{{<info>}}
**NOTE**: For newer volumes if you do not provide any secret key, they will use per volume encryption and will **NOT** default to using cluster wide secret
{{</info>}}


{{<info>}}
{{% content "key-management/aws-kms/shared/warning-note.md" %}}
{{</info>}}
