---
title: Install chart reference
weight: 4
keywords: Install, PX-Central, On-prem, license, GUI, k8s, license server, monitoring service
description: Install charts reference
noicon: true
---

## PX-Central install chart reference

Parameter | Description | Default
--- | --- | ---
`persistentStorage.enabled` | Enables persistent storage for all PX-Central components | `false`
`persistentStorage.storageClassName` | Specifies the name of the storage class | `""`
`persistentStorage.mysqlVolumeSize` | MySQL volume size | `"100Gi"`
`persistentStorage.etcdVolumeSize` | ETCD volume size | `"64Gi"`
`persistentStorage.keycloakThemeVolumeSize` | Keycloak frontend theme volume size | `"5Gi"`
`persistentStorage.keycloakBackendVolumeSize` | Keycloak backend volume size | `"10Gi"`
`storkRequired` | Use this to set STORK as your scheduler | `false`
`pxcentralDBPassword` | PX-Central cluster store MySQL database password | `Password1`
`caCertsSecretName` | The name of the Kubernetes secret containing the CA Certificates. | `""`
`oidc` | Enables OIDC for PX-Central and PX-backup for RBAC | `""`
`oidc.centralOIDC` | PX-Central OIDC | `""`
`oidc.centralOIDC.enabled` | PX-Central OIDC | `true`
`oidc.centralOIDC.defaultUsername` | PX-Central OIDC username | `admin`
`oidc.centralOIDC.defaultPassword` | PX-Central OIDC admin user password | `admin`
`oidc.centralOIDC.defaultEmail` | PX-Central OIDC admin user email | `admin@portworx.com`
`oidc.centralOIDC.keyCloakBackendUserName` | Keycloak backend store username | `keycloak`
`oidc.centralOIDC.keyCloakBackendPassword` | Keycloak backend store password | `keycloak`
`oidc.centralOIDC.clientId` | PX-Central OIDC client ID | `pxcentral`
`oidc.externalOIDC.enabled` | Specifies whether PX-Central uses an external OIDC provider or not | `false`
`oidc.externalOIDC.clientID` | External OIDC client ID | `""`
`oidc.externalOIDC.clientSecret` | External OIDC client secret | `""`
`oidc.externalOIDC.endpoint` | External OIDC endpoint | `""`
`images` | PX-Backup deployment images | `""`
`pxbackup.enabled` | Enables PX-Backup | `true`
`pxbackup.orgName` | PX-Backup organization name | `default`
`securityContext` | Security context for the Pod | `{runAsUser: 1000, fsGroup: 1000, runAsNonRoot: true}`
`images.pullSecrets` | Image pull secrets | `docregistry-secret`
`images.pullPolicy` | Image pull policy | `Always`
`images.pxcentralApiServerImage.registry` | API server image registry | `docker.io`
`images.pxcentralApiServerImage.repo` | API server image repo | `portworx`
`images.pxcentralApiServerImage.imageName` | API server image name | `pxcentral-onprem-api`
`images.pxcentralApiServerImage.tag` | API server image tag | `1.0.4`
`images.pxcentralFrontendImage.registry` | PX-Central frontend image registry | `docker.io`
`images.pxcentralFrontendImage.repo` | PX-Central frontend image repo | `portworx`
`images.pxcentralFrontendImage.imageName` | PX-Central frontend image name | `pxcentral-onprem-ui-frontend`
`images.pxcentralFrontendImage.tag` | PX-Central frontend image tag | `1.1.2`
`images.pxcentralBackendImage.registry` | PX-Central backend image registry | `docker.io`
`images.pxcentralBackendImage.repo` | PX-Central backend image repo | `portworx`
`images.pxcentralBackendImage.imageName` | PX-Central backend image name | `pxcentral-onprem-ui-backend`
`images.pxcentralBackendImage.tag` | PX-Central backend image tag | `1.1.2`
`images.pxcentralMiddlewareImage.registry` | PX-Central middleware image registry | `docker.io`
`images.pxcentralMiddlewareImage.repo` | PX-Central middleware image repo | `portworx`
`images.pxcentralMiddlewareImage.imageName` | PX-Central middleware image name | `pxcentral-onprem-ui-lhbackend`
`images.pxcentralMiddlewareImage.tag`| PX-Central middleware image tag | `1.1.2`
`images.pxBackupImage.registry` | PX-Backup image registry | `docker.io`
`images.pxBackupImage.repo` | PX-Backup image repo | `portworx`
`images.pxBackupImage.imageName` | PX-Backup image name | `px-backup`
`images.pxBackupImage.tag` | PX-Backup image tag | `1.0.2`
`images.postInstallSetupImage.registry` | PX-Backup post install setup image registry | `docker.io`
`images.postInstallSetupImage.repo` | PX-Backup post install setup image repo | `portworx`
`images.postInstallSetupImage.imageName` | PX-Backup post install setup image name | `pxcentral-onprem-post-setup`
`images.postInstallSetupImage.tag` | PX-Backup post install setup image tag | `1.0.4`
`images.etcdImage.registry` | PX-Backup etcd image registry | `docker.io`
`images.etcdImage.repo` | PX-Backup etcd image repo | `bitnami`
`images.etcdImage.imageName` | PX-Backup etcd image name | `etcd`
`images.etcdImage.tag` | PX-Backup etcd image tag | `3.4.7-debian-10-r14`
`images.keycloakBackendImage.registry` | PX-Backup keycloak backend image registry | `docker.io`
`images.keycloakBackendImage.repo` | PX-Backup keycloak backend image repo | `bitnami`
`images.keycloakBackendImage.imageName` | PX-Backup keycloak backend image name | `postgresql`
`images.keycloakBackendImage.tag` | PX-Backup keycloak backend image tag | `11.7.0-debian-10-r9`
`images.keycloakFrontendImage.registry` | PX-Backup keycloak frontend image registry | `docker.io`
`images.keycloakFrontendImage.repo` | PX-Backup keycloak frontend image repo | `jboss`
`images.keycloakFrontendImage.imageName` | PX-Backup keycloak frontend image name | `keycloak`
`images.keycloakFrontendImage.tag` | PX-Backup keycloak frontend image tag | `9.0.2`
`images.keycloakLoginThemeImage.registry` | PX-Backup keycloak login theme image registry | `docker.io`
`images.keycloakLoginThemeImage.repo` | PX-Backup keycloak login theme image repo | `portworx`
`images.keycloakLoginThemeImage.imageName` | PX-Backup keycloak login theme image name | `keycloak-login-theme`
`images.keycloakLoginThemeImage.tag` | PX-Backup keycloak login theme image tag | `1.0.2`
`images.keycloakInitContainerImage.registry` | PX-Backup keycloak init container image registry | `docker.io`
`images.keycloakInitContainerImage.repo` | PX-Backup keycloak init container image repo | `library`
`images.keycloakInitContainerImage.imageName` | PX-Backup keycloak init container image name | `busybox`
`images.keycloakInitContainerImage.tag` | PX-Backup keycloak init container image tag | `1.31`
`images.mysqlImage.registry` | PX-Central cluster store MySQL image registry | `docker.io`
`images.mysqlImage.repo` | PX-Central cluster store MySQL image repo | `library`
`images.mysqlImage.imageName` | PX-Central cluster store MySQL image name | `mysql`
`images.mysqlImage.tag` | PX-Central cluster store MySQL image tag | `5.7.22` |


## License server install chart reference

|**Option**|**Description**|**Default value**|
| --- | --- | --- |
| `pxlicenseserver.internal.enabled` | Specifies whether the license server is enabled or not | `true` |
| `pxlicenseserver.internal.lsTypeAirgapped` | Indicates whether this is an air-gapped environment or not | `false` |
| `pxlicenseserver.external.enabled` | Specifies whether this deployment uses an external license server | `false` |
| `pxlicenseserver.mainNodeIP` | If an external license server is used, this option indicates the endpoints of the main node | |
| `pxlicenseserver.backupNodeIP` | If an external license server is used, this option indicates the endpoints of the backup node | |
| `pxlicenseserver.adminUserName` | Specifies the administrator account name | `admin` |
| `pxlicenseserver.adminUserPassword` | Specifies the password for the administrator account | `Password@1` |
| `securityContext` | Describes the security context for the Pod in which the license server component runs | `{runAsUser: 1000, fsGroup: 1000, runAsNonRoot: true}` |
| `images` | The list of Portworx images needed to install the license server component <!-- Not sure I got this right--> | |
| `images.pullSecrets` | Specifies the image pull secret | |
| `images.pullPolicy` | Specifies the image pull policy | `Always` |
| `images.licenseServerImage.registry` | Specifies the registry for the license server image | `docker` |
| `images.licenseServerImage.repo` | Specifies the repository for the license server image | `portworx` |
| `images.licenseServerImage.imageName` | Indicates the image name for the license server  | `px-els` |
| `images.licenseServerImage.tag` | The tag for the license server image | `1.0.0` |
| `images.pxLicenseHAConfigContainerImage.registry` | If you're running the license server in HA mode, this option indicates the registry for the configuration image <!-- Not sure I got this right--> | `docker.io` |
| `images.pxLicenseHAConfigContainerImage.repo` | If you're running the license server in HA mode, this option indicates the repository for the configuration image <!-- Not sure I got this right--> | `portworx` |
| `images.pxLicenseHAConfigContainerImage.imageName` | If you're running the license server in HA mode, this option indicates the name of the configuration image <!-- Not sure I got this right--> | `pxcentral-onprem-els-ha-setup` |
| `images.pxLicenseHAConfigContainerImage.tag` | If you're running the license server in HA mode, this option indicates the  tag for the license server configuration image | `1.0.2` |


## Monitoring service install chart reference

|**Option**|**Description**|**Default value**|
| --- | --- | --- |
| `pxmonitor.enabled` | Specifies whether the monitoring service is enabled or not | `true` |
| `pxmonitor.pxCentralEndpoint` | Indicates the PX-Central UI access endpoint. You can specify this as `IP:PORT `or hostname. | |
| `pxmonitor.sslEnabled` | Use this option to enable or disable HTTPS | `false` | `pxmonitor.oidcClientID` | The client ID for your OIDC provider <!-- Not sure I got this right--> | |
| `pxmonitor.oidcClientSecret` | The client secret for your OIDC provider. | |
| `installCRDs` | Use this flag for new Kubernetes clusters, where you must install and register all required CRDs | `false` |
| `storkRequired` | Use this to set STORK as your scheduler | `false` |
| `clusterDomain` | Indicates the domain of your cluster | `cluster.local` |
| `cassandraUsername` | Specifies your Cassandra user name | `cassandra` |
| `cassandraPassword` | Specifies your Cassandra password | `cassandra` |
| `persistentStorage.enabled` | Enables persistent storage | `true` |
| `persistentStorage.storageClassName` | Specifies the name of the storage class | |
| `persistentStorage.cassandra.storage` | Cassandra volume size | `50Gi` |
| `persistentStorage.grafana.storage` | Grafana volume size | `20Gi` |
| `persistentStorage.consul.storage` | Consul volumes size | `8Gi` |
| `securityContext` | Describes the security context for the Pod in which the license server component runs | `{runAsUser: 1000, fsGroup: 1000, runAsNonRoot: true}` |
| `images.pullSecrets` | Specifies the image pull secret | |
| `images.pullPolicy` | Specifies the image pull policy | `Always` |


### Example

The following example configures your Ingress controller to expose Grafana and Cortex:

```text
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: nginx
  name: px-backup-ui-ingress
  namespace: px-backup
spec:
  rules:
  - http:
      paths:
      - backend:
          serviceName: px-backup-ui
          servicePort: 80
        path: /
      - backend:
          serviceName: pxcentral-keycloak-http
          servicePort: 80
        path: /auth
      - backend:
          serviceName: pxcentral-grafana
          servicePort: 3000
        path: /grafana(/|$)(.*)
      - backend:
          serviceName: pxcentral-cortex-nginx
          servicePort: 80
        path: /cortex(/|$)(.*)
```