---
title: PX-Central install script reference
weight: 6
keywords: Install, PX-Central, On-prem, license, GUI, k8s
description: See the options available for the PX-Central install script.
noicon: true
---

 ```text
 ./px-central-install.sh [options] '[arguments...]'
 ```

{{<info>}}
**NOTE:** The script name `px-central-install.sh` reflects the default name specified in the installation instructions, but can be whatever you named the script file when you downloaded it.
{{</info>}}

## Options

|**Option**|**Description**|**Required?**|
|----|----|----|
| `--license-password` | License server admin user password. You must use at least one special symbol and numeric value. Supported special symbols are: [!@#$%] | Yes |
| `--oidc-clientid` | OIDC client ID | No |
| `--oidc-secret` | OIDC secret | No |
| `--oidc-endpoint` | OIDC endpoint | No |
| `--cluster-name` | PX-Central Cluster Name | No |
| `--admin-user` | Admin user for PX-Central and Grafana | No |
| `--admin-password` | Admin user password | No |
| `--admin-email` | Admin user email address | No |
| `--kubeconfig` | Kubeconfig file | No |
| `--custom-registry` | Custom image registry path | No |
| `--image-repo-name` | Image repository name | No |
| `--image-pull-secret` | Image pull secret for custom registry | No |
| `--air-gapped` | Provide this option if you're installing onto an air-gapped environment. | No |
| `--pxcentral-endpoint` | Any one of the master or worker node IP of current k8s cluster. If you're deploying PX-Central on a cloud, specify an elastic IP, public IP, or your load balancer as as the endpoint. | No |
| `--cloud` | Provide this option if you're deploying PX-Central on a cloud. | No |
| `--openshift` | Provide this option if deploying PX-Central on OpenShift platform. | No |

## Examples

* Deploy PX-Central without OIDC:

    ```text
    ./install.sh --license-password 'examplePassword'
    ```

* Deploy PX-Central with OIDC:

    ```text
    ./install.sh --oidc-clientid test --oidc-secret abc0123d-9876-zyxw-m1n2-i1j2k345678l --oidc-endpoint X.X.X.X:Y --license-password 'examplePassword'
    ```

* Deploy PX-Central without OIDC with user input kubeconfig:

    ```text  
    ./install.sh --license-password 'examplePassword' --kubeconfig /tmp/test.yaml
    ```

* Deploy PX-Central with OIDC, custom registry with user input kubeconfig:

    ```text
    ./install.sh  --license-password 'examplePassword' --oidc-clientid test --oidc-secret abc0123d-9876-zyxw-m1n2-i1j2k345678l  --oidc-endpoint X.X.X.X:Y --custom-registry xyz.amazonaws.com --image-repo-name pxcentral-onprem --image-pull-secret docregistry-secret --kubeconfig /tmp/test.yaml
    ```

* Deploy PX-Central with custom registry:

    ```text
    ./install.sh  --license-password 'examplePassword' --custom-registry xyz.amazonaws.com --image-repo-name pxcentral-onprem --image-pull-secret docregistry-secret
    ```

* Deploy PX-Central with custom registry with user input kubeconfig:

    ```text
    ./install.sh  --license-password 'examplePassword' --custom-registry xyz.amazonaws.com --image-repo-name pxcentral-onprem --image-pull-secret docregistry-secret --kubeconfig /tmp/test.yaml
    ```

* Deploy PX-Central on OpenShift:

    ```text
    ./install.sh  --license-password 'examplePassword' --openshift
    ```

* Deploy PX-Central on openshift on AWS with a load balancer:

    ```text
    ./install.sh  --license-password 'examplePassword' --openshift --cloud --pxcentral-endpoint abcxyz.us-east-1.elb.amazonaws.com
    ```

* Deploy PX-Central on openshift on AWS with an elastic IP `192.0.2.0`:

    ```text
    ./install.sh  --license-password 'examplePassword' --openshift --cloud --pxcentral-endpoint 192.0.2.0
    ```

* Deploy PX-Central on an air-gapped environment:

    ```text
    ./install.sh  --license-password 'examplePassword' --air-gapped --custom-registry test.ecr.us-east-1.amazonaws.com --image-repo-name pxcentral-onprem --image-pull-secret docregistry-secret
    ```

* Deploy PX-Central on air-gapped environment with OIDC:

    ```text
    ./install.sh  --license-password 'examplePassword' --oidc-clientid test --oidc-secret abc0123d-9876-zyxw-m1n2-i1j2k345678l  --oidc-endpoint X.X.X.X:Y --custom-registry test.ecr.us-east-1.amazonaws.com --image-repo-name pxcentral-onprem --image-pull-secret docregistry-secret
    ```
