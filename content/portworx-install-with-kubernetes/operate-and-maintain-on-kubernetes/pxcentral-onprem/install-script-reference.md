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
| `--oidc` | Enable OIDC for PX-Central components | No |
| `--oidc-clientid` | OIDC client ID | Required if OIDC is enabled |
| `--oidc-secret` | OIDC secret | Required if OIDC is enabled |
| `--oidc-endpoint` | OIDC endpoint | Required if OIDC is enabled |
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
| `--cloud` | Provide this option if you're deploying PX-Central on a cloud. Currently supported K8s managed services: EKS, GKE and AKS, Custom k8s clusters on AWS, GCP and Azure. | Required for deployments on cloud-based clusters |
| `--cloudstorage` | Provide this option to instruct Portworx to provision required disks on cloud storage | Required for deployments on cloud-based clusters |
| `--aws-access-key` | AWS access key required to provision disks | Required for deployments on AWS |
| `--aws-secret-key` | AWS secret key required to provision disks | Required for deployments on AWS |
| `--disk-type` | Data disk type | No |
| `--disk-size` | Data disk size | No |
| `--azure-client-secret` | Azure client secret | Required for deployments on Azure |
| `--azure-client-id` | Azure client ID | Required for deployments on Azure |
| `--azure-tenant-id` | Azure tenant ID | Required for deployments on Azure | 
| `--managed` | Provide this option if you're deploying PX-Central onto a managed k8s service cluster type. | Required for deployments on managed Kubernetes clusters |
| `--openshift` | Provide this option if deploying PX-Central on OpenShift platform. | No |
| `--mini` | Deploy PX-Central on mini clusters, such as Minikube, K3s, and Microk8s. | No |
| `--all` | Install all the components of the PX-Central stack. <!-- more detail here would be helpful. -->| No |
| `--px-store` | Install PX-Enterprise. | No |
| `--px-backup` | Install PX-Backup. <!-- Doesn't the default install include PX-Backup? --> | No |
| `--px-backup-organization` | Organization ID for PX-Backup <!-- what is this? part of OIDC? --> | No |
| `--oidc-user-access-token` | Provide OIDC user access token required while adding cluster into backup. <!-- What is this? is it specific to backup? --> | No |
| `--px-metrics-store` | Install the PX-Metrics store and dashboard view. | No |
| `--px-license-server` | Install the license Server. | No |
| `--pxcentral-namespace` | The namespace in which to deploy your PX-Central on-prem cluster. | No |
| `--pks` | Specify this option if you're deploying PX-Central on-prem PKS. | No |
| `--pks-px-disk-type` | The type of disk PX-Enterprise uses during auto disk provisioning. | No |
| `--pks-px-disk-size` | The size of the disk PX-Enterprise uses during auto disk provisioning. | No |
| `--vsphere-vcenter-endpoint` | The vSphere vCenter endpoint. | No |
| `--vsphere-vcenter-port` | The vSphere Vcenter port. | No |
| `--vsphere-vcenter-datastore-prefix` | The vSphere vVenter datastore prefix. | No |
| `--vsphere-vcenter-install-mode` | The vSphere vCenter install mode. | No |
| `--vsphere-user` | The vSphere vCenter user. | No |
| `--vsphere-password` | The vSphere vCenter password. <!-- are some of these required if px central is installed on vsphere? --> | No |
| `--vsphere-insecure` | Deploy vSphere vCenter using an insecure endpoint. <!-- using an insecure endpoint? _to_ an insecure endpoint? need a more detailed understanding here--> | No |
| `--domain` | Domain to deploy and expose PX-Central services | No |

<!-- We need to create examples for PX-Backup that we can put on that page. We probably need: Default, Without OIDC, With OIDC, any helpful options (--px-backup, --px-backup-organization, --oidc-user-access-token ) -->

## Examples

* Deploy PX-Central without OIDC:

    ```text
    ./install.sh --license-password 'Adm1n!Ur'
    ```

* Deploy PX-Central with OIDC:

    ```text
    ./install.sh --oidc-clientid test --oidc-secret 0df8ca3d-7854-ndhr-b2a6-b6e4c970968b --oidc-endpoint X.X.X.X:Y --license-password 'Adm1n!Ur'
    ```

* Deploy PX-Central without OIDC with user input kubeconfig:

    ```text
    ./install.sh --license-password 'Adm1n!Ur' --kubeconfig /tmp/test.yaml
    ```

* Deploy PX-Central with OIDC, custom registry with user input kubeconfig:

    ```text
    ./install.sh  --license-password 'Adm1n!Ur' --oidc-clientid test --oidc-secret 0df8ca3d-7854-ndhr-b2a6-b6e4c970968b  --oidc-endpoint X.X.X.X:Y --custom-registry xyz.amazonaws.com --image-repo-name pxcentral-onprem --image-pull-secret docregistry-secret --kubeconfig /tmp/test.yaml
    ```

* Deploy PX-Central with custom registry:

    ```text
    ./install.sh  --license-password 'Adm1n!Ur' --custom-registry xyz.amazonaws.com --image-repo-name pxcentral-onprem --image-pull-secret docregistry-secret
    ```

* Deploy PX-Central with custom registry with user input kubeconfig:

    ```text
    ./install.sh  --license-password 'Adm1n!Ur' --custom-registry xyz.amazonaws.com --image-repo-name pxcentral-onprem --image-pull-secret docregistry-secret --kubeconfig /tmp/test.yaml
    ```

* Deploy PX-Central on openshift on onprem

    ```text
    ./install.sh  --license-password 'Adm1n!Ur' --openshift 
    ```

* Deploy PX-Central on openshift on cloud

    ```text
    ./install.sh  --license-password 'Adm1n!Ur' --openshift --cloud <aws|gcp|azure> --pxcentral-endpoint X.X.X.X
    ```

* Deploy PX-Central on cloud with external public IP

    ```text
    ./install.sh --license-password 'Adm1n!Ur' --pxcentral-endpoint X.X.X.X
    ```

* Deploy PX-Central on air-gapped environment

    ```text
    ./install.sh  --license-password 'Adm1n!Ur' --air-gapped --custom-registry test.ecr.us-east-1.amazonaws.com --image-repo-name pxcentral-onprem --image-pull-secret docregistry-secret
    ```

* Deploy PX-Central on air-gapped environment with oidc

    ```text
    ./install.sh  --license-password 'Adm1n!Ur' --oidc-clientid test --oidc-secret 87348ca3d-1a73-907db-b2a6-87356538  --oidc-endpoint X.X.X.X:Y --custom-registry test.ecr.us-east-1.amazonaws.com --image-repo-name pxcentral-onprem --image-pull-secret docregistry-secret
    ```

* Deploy PX-Central on aws without auto disk provision

    ```text
    ./install.sh  --license-password 'Adm1n!Ur' --cloud aws --pxcentral-endpoint X.X.X.X
    ```

* Deploy PX-Central on aws with auto disk provision

    ```text
    ./install.sh  --license-password 'Adm1n!Ur' --cloud aws --pxcentral-endpoint X.X.X.X --cloudstorage --aws-access-key <AWS_ACCESS_KEY_ID> --aws-secret-key <AWS_SECRET_ACCESS_KEY>
    ```

* Deploy PX-Central on aws with auto disk provision with different disk type and disk size

    ```text
    ./install.sh  --license-password 'Adm1n!Ur' --cloud aws --disk-type gp2 --disk-size 200 --pxcentral-endpoint X.X.X.X --cloudstorage --aws-access-key <AWS_ACCESS_KEY_ID> --aws-secret-key <AWS_SECRET_ACCESS_KEY>
    ```

* Deploy PX-Central on gcp without auto disk provision

    ```text
    ./install.sh  --license-password 'Adm1n!Ur' --cloud gcp --pxcentral-endpoint X.X.X.X
    ```

* Deploy PX-Central on gcp with auto disk provision

    ```text
    ./install.sh  --license-password 'Adm1n!Ur' --cloud gcp --pxcentral-endpoint X.X.X.X --cloudstorage
    ```

* Deploy PX-Central on gcp with auto disk provision with different disk type and disk size

    ```text
    ./install.sh  --license-password 'Adm1n!Ur' --cloud gcp --pxcentral-endpoint X.X.X.X --cloudstorage --disk-type pd-standard --disk-size 200
    ```

* Deploy PX-Central on azure without auto disk provision

    ```text
    ./install.sh  --license-password 'Adm1n!Ur' --cloud azure --pxcentral-endpoint X.X.X.X
    ```

* Deploy PX-Central on azure with auto disk provision

    ```text
    ./install.sh  --license-password 'Adm1n!Ur' --cloud azure --pxcentral-endpoint X.X.X.X --cloudstorage --azure-client-secret <AZURE_CLIENT_SECRET> --azure-client-id <AZURE_CLIENT_ID> --azure-tenant-id <AZURE_TENANT_ID>
    ```

* Deploy PX-Central on azure with auto disk provision with different disk type and disk size

    ```text
    ./install.sh  --license-password 'Adm1n!Ur' --cloud azure --pxcentral-endpoint X.X.X.X --cloudstorage --azure-client-secret <AZURE_CLIENT_SECRET> --azure-client-id <AZURE_CLIENT_ID> --azure-tenant-id <AZURE_TENANT_ID> --disk-type Standard_LRS --disk-size 200
    ```

* Deploy PX-Central-Onprem with existing disks on EKS

    ```text
    ./install.sh  --license-password 'Adm1n!Ur' --cloud aws --managed --pxcentral-endpoint X.X.X.X
    ```

* Deploy PX-Central-Onprem with auto disk provision on EKS

    ```text
    ./install.sh  --license-password 'Adm1n!Ur' --cloud aws --managed --disk-type gp2 --disk-size 200 --pxcentral-endpoint X.X.X.X --cloudstorage --aws-access-key <AWS_ACCESS_KEY_ID> --aws-secret-key <AWS_SECRET_ACCESS_KEY>
    ```

* Deploy PX-Central-Onprem with existing disks on GKE

    ```text
    ./install.sh  --license-password 'Adm1n!Ur' --cloud gcp --managed --pxcentral-endpoint X.X.X.X
    ```

* Deploy PX-Central-Onprem with auto disk provision on GKE

    ```text
    ./install.sh  --license-password 'Adm1n!Ur' --cloud gcp --managed --pxcentral-endpoint X.X.X.X --cloudstorage
    ```

* Deploy PX-Central-Onprem with existing disks on AKS

    ```text
    ./install.sh  --license-password 'Adm1n!Ur' --cloud azure --managed  --pxcentral-endpoint X.X.X.X
    ```

* Deploy PX-Central-Onprem with auto disk provision on AKS

    ```text
    ./install.sh  --license-password 'Adm1n!Ur' --cloud azure --managed --pxcentral-endpoint X.X.X.X --cloudstorage --azure-client-secret <AZURE_CLIENT_SECRET> --azure-client-id <AZURE_CLIENT_ID> --azure-tenant-id <AZURE_TENANT_ID>
    ```

* Deploy PX-Central on mini k8s cluster

    ```text
    ./install.sh --mini
    ```

* Deploy PX-Central on mini k8s cluster with external OIDC

    ```text
    ./install.sh --mini --oidc-clientid test --oidc-secret 0df8ca3d-7854-ndhr-b2a6-b6e4c970968b --oidc-endpoint X.X.X.X:Y
    ```

* Deploy PX-Central on mini k8s cluster with PX-Central OIDC

    ```text
    ./install.sh --mini --oidc --admin-user pxadmin --admin-password Password2 --admin-email  pxadmin@portworx.com
    ```

* Deploy PX-Central with selected components

    ```text
    ./install.sh --px-store --px-metrics-store --px-backup --px-license-server --license-password 'Adm1n!Ur'
    ```

* Deploy PX-Central on PKS on vsphere cloud with existing disks for Portworx

    ```text
    ./install.sh --license-password 'Adm1n!Ur' --cloud vsphere --pks --pxcentral-endpoint X.X.X.X
    ```

* Deploy PX-Central on openshift on vsphere cloud with existing disks for Portworx

    ```text
    ./install.sh --license-password 'Adm1n!Ur' --cloud vsphere --openshift --pxcentral-endpoint X.X.X.X
    ```

* Deploy PX-Central on PKS on vsphere cloud with existing disks for Portworx with central OIDC

    ```text
    ./install.sh --license-password 'Adm1n!Ur' --cloud vsphere --pks --oidc --admin-user pxadmin --admin-password Password2 --admin-email  pxadmin@portworx.com --pxcentral-endpoint X.X.X.X
    ```

* Deploy PX-Central on PKS on vsphere cloud with existing disks for Portworx with external OIDC

    ```text
    ./install.sh --license-password 'Adm1n!Ur' --cloud vsphere --pks --oidc-clientid test --oidc-secret 0df8ca3d-7854-ndhr-b2a6-b6e4c970968b --oidc-endpoint X.X.X.X:Y --pxcentral-endpoint X.X.X.X
    ```

* Deploy PX-Central on PKS on vsphere cloud with auto disk provision option

    ```text
    ./install.sh --license-password 'Adm1n!Ur' --cloud vsphere --pks --cloudstorage --vsphere-vcenter-endpoint <VCENTER_ENDPOINT> --vsphere-vcenter-port <VCENTER_PORT> --vsphere-vcenter-datastore-prefix "Phy-" --vsphere-vcenter-install-mode <INSTALL_MODE> --vsphere-insecure --vsphere-user <VCENTER_USER> --vsphere-password <VCENTER_PASSWORD> --pxcentral-endpoint X.X.X.X
    ```

* Deploy PX-Central on PKS on vsphere cloud with central OIDC with auto disk provision option

    ```text
    ./install.sh --license-password 'Adm1n!Ur' --oidc --admin-user pxadmin --admin-password Password2 --admin-email  pxadmin@portworx.com --cloud vsphere --pks --cloudstorage --vsphere-vcenter-endpoint <VCENTER_ENDPOINT> --vsphere-vcenter-port <VCENTER_PORT> --vsphere-vcenter-datastore-prefix "Phy-" --vsphere-vcenter-install-mode <INSTALL_MODE> --vsphere-insecure --vsphere-user <VCENTER_USER> --vsphere-password <VCENTER_PASSWORD> --pxcentral-endpoint X.X.X.X
    ```

* Deploy PX-Central on PKS on vsphere cloud with external OIDC with auto disk provision option

    ```text
    ./install.sh --license-password 'Adm1n!Ur' --oidc-clientid test --oidc-secret 0df8ca3d-7854-ndhr-b2a6-b6e4c970968b --oidc-endpoint X.X.X.X:Y --cloud vsphere --pks --cloudstorage --vsphere-vcenter-endpoint <VCENTER_ENDPOINT> --vsphere-vcenter-port <VCENTER_PORT> --vsphere-vcenter-datastore-prefix "Phy-" --vsphere-vcenter-install-mode <INSTALL_MODE> --vsphere-insecure --vsphere-user <VCENTER_USER> --vsphere-password <VCENTER_PASSWORD> --pxcentral-endpoint X.X.X.X
    ```

* Deploy PX-Central on openshift on vsphere cloud with auto disk provision option

    ```text
    ./install.sh --license-password 'Adm1n!Ur' --cloud vsphere --openshift --cloudstorage --vsphere-vcenter-endpoint <VCENTER_ENDPOINT> --vsphere-vcenter-port <VCENTER_PORT> --vsphere-vcenter-datastore-prefix "Phy-" --vsphere-vcenter-install-mode <INSTALL_MODE> --vsphere-insecure --vsphere-user <VCENTER_USER> --vsphere-password <VCENTER_PASSWORD> --pxcentral-endpoint X.X.X.X
    ```

* Deploy PX-Central on openshift on vsphere cloud with central OIDC with auto disk provision option

    ```text
    ./install.sh --license-password 'Adm1n!Ur' --cloud vsphere --openshift --cloudstorage --vsphere-vcenter-endpoint <VCENTER_ENDPOINT> --vsphere-vcenter-port <VCENTER_PORT> --vsphere-vcenter-datastore-prefix "Phy-" --vsphere-vcenter-install-mode <INSTALL_MODE> --vsphere-insecure --vsphere-user <VCENTER_USER> --vsphere-password <VCENTER_PASSWORD> --oidc --admin-user pxadmin --admin-password Password2 --admin-email  pxadmin@portworx.com 
    ```

* Deploy PX-Central on openshift on vsphere cloud with external OIDC with auto disk provision option

    ```text
    ./install.sh --license-password 'Adm1n!Ur' --cloud vsphere --openshift --cloudstorage --vsphere-vcenter-endpoint <VCENTER_ENDPOINT> --vsphere-vcenter-port <VCENTER_PORT> --vsphere-vcenter-datastore-prefix "Phy-" --vsphere-vcenter-install-mode <INSTALL_MODE> --vsphere-insecure --vsphere-user <VCENTER_USER> --vsphere-password <VCENTER_PASSWORD> --oidc-clientid test --oidc-secret 0df8ca3d-7854-ndhr-b2a6-b6e4c970968b --oidc-endpoint X.X.X.X:Y  --pxcentral-endpoint X.X.X.X
    ```
