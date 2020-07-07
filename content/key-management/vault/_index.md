---
title: Vault
logo: /logos/hashicorp-vault.png
keywords: Vault Key Management, Hashicorp, encryption keys, secrets, Volume Encryption, Cloud Credentials, secret store, passwords
description: Instructions on using Vault key management with Portworx
weight: 5
disableprevnext: true
series: key-management
noicon: true
---

Portworx can integrate with Vault to store your encryption keys/secrets, credentials or passwords. This guide will get a Portworx cluster connected to a Vault endpoint. The vault endpoint could be used to store secrets that will be used for encrypting volumes.

## Setting up Vault

Peruse [this section](https://www.vaultproject.io/docs/install) for help on setting up Vault in your setup. This includes installation, setting up policies and configuring secrets.

## Vault Credentials

Portworx requires the following Vault credentials to use its APIs


- **Vault Address [VAULT_ADDR]**

    Address of the Vault server expressed as a URL and port, for example: `https://192.168.11.11:8200`

- **Vault Token [VAULT_TOKEN]**

   Vault authentication token. Follow [this](https://www.vaultproject.io/docs/concepts/tokens) doc for more information about Vault Tokens. If you are using Vault's Kubernetes Auth method you won't need to provide the actual token to Portworx.

- **Vault Base Path [VAULT_BASE_PATH]**

    The base path under which Portworx has access to secrets.

- **Vault Backend Path [VAULT_BACKEND_PATH]**

    The custom backend path if different than the default `secret`

- **Vault CA Certificate [VAULT_CACERT]**

    Path to a PEM-encoded CA certificate file that needs to be present on all Portworx nodes. This file is used to verify the Vault server's SSL certificate.
    This variable takes precedence over `VAULT_CAPATH`.

- **Vault CA Path [VAULT_CAPATH]**

    Path to a directory of PEM-encoded CA certificate files that needs to be present on all Portworx nodes. These certificates are used to verify the Vault server's SSL certificate.

- **Vault Client Certificate [VAULT_CLIENT_CERT]**

    Path to a PEM-encoded client certificate that needs to be present on all Portworx nodes. This file is used for TLS communication with the Vault server.

- **Vault Client Key [VAULT_CLIENT_KEY]**

    Path to an unencrypted, PEM-encoded private key  which corresponds to the matching client certificate. This key file needs to be present on all Portworx nodes.

- **Vault TLS Server Name [VAULT_TLS_SERVER_NAME]**

    Name to use as the SNI host when connecting via TLS.

- **Vault Auth Method [VAULT_AUTH_METHOD]**

    Specifies the Auth method that Portworx should use while authenticating with Vault. Currently supported Auth Methods: "Kubernetes".

- **Vault Auth Kubernetes Role [VAULT_AUTH_KUBERNETES_ROLE]**

    Name of the Kubernetes Auth Role created in vault for Portworx. This field is set only when using Kubernetes Auth Method.



## Kubernetes users

### Step 1: Choose Vault Auth Method

Auth methods are responsible for authenticating Portworx with Vault. Based on your Vault configuration and the Auth method you choose, you must use one of the following two methods:

* **Using Token Auth:** In this method a static vault token will be provided to Portworx.
* **Using Kubernetes Auth:** In this method, Portworx will use Kubernetes service account to fetch and refresh Vault Tokens.

#### Using Token Auth Method

With this method, Portworx requires a Vault static token to be provided through a Kubernetes secret.

##### Step 1a: Provide Vault credentials to Portworx

Portworx reads the Vault credentials required to authenticate with Vault through a Kubernetes secret. Create a Kubernetes secret with the name `px-vault` in the `portworx` namespace. Following is an example kubernetes secret spec

```text
apiVersion: v1
kind: Secret
metadata:
  name: px-vault
  namespace: portworx
type: Opaque
data:
  VAULT_ADDR: <base64 encoded value of the vault endpoint address>
  VAULT_TOKEN: <base64 encoded value of the vault token>
  VAULT_BACKEND_PATH: <base64 encoded value of the custom backend path if different than the default "secret">
  VAULT_CACERT: <base64 encoded file path where the CA Certificate is present on all the nodes>
  VAULT_CAPATH: <base64 encoded file path where the Certificate Authority is present on all the nodes>
  VAULT_CLIENT_CERT: <base64 encoded file path where the Client Certificate is present on all the nodes>
  VAULT_CLIENT_KEY: <base64 encoded file path where the Client Key is present on all the nodes>
  VAULT_TLS_SERVER_NAME: <base64 encoded value of the TLS server name>
```

Portworx will look for this secret with name `px-vault` under the `portworx` namespace. While installing Portworx it creates a kubernetes role binding which grants access to reading kubernetes secrets only from the `portworx` namespace.

{{<info>}}
**NOTE:** If the VAULT_TOKEN provided in the secret above is refreshed, you must manually update this secret.
{{</info>}}

Now that you've configured Vault using the Vault auth method, proceed to [Step 2](#step-2-setup-vault-as-the-secrets-provider-for-portworx).

#### Using Kubernetes Auth Method

This method allows Portworx to authenticate with Vault using a Kubernetes service account token. You can find more information on how to setup Kubernetes Vault Auth in the [Vault documentation](https://www.vaultproject.io/docs/auth/kubernetes).

##### Step 1a: Create a ServiceAccount for vault auth delegation

Run the following `kubectl create` commands to create a ServiceAccount and ClusterRoleBinding. This ServiceAccount and its associated token is used by Vault to authenticate requests from Portworx. Vault uses the [Kubernetes TokenReview API](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#tokenreview-v1-authentication-k8s-io).

```text
kubectl create serviceaccount vault-auth -n kube-system
kubectl create clusterrolebinding vault-tokenreview-binding --clusterrole=system:auth-delegator --serviceaccount=kube-system:vault-auth
```

##### Step 1b: Enable Kubernetes Auth in Vault

Enter the following `vault auth` command to enable Kubernetes auth in Vault:

```text
vault auth enable kubernetes
```

##### Step 1c: Create a Kubernetes Auth Config in Vault

Enter the following `export` commands to get the Kubernetes ServiceAccount's JWT token and CA certificate:

```text
export VAULT_SA_NAME=$(kubectl get sa vault-auth -n kube-system \
     -o jsonpath="{.secrets[*]['name']}")

export SA_JWT_TOKEN=$(kubectl get secret $VAULT_SA_NAME -n kube-system \
     -o jsonpath="{.data.token}" | base64 --decode; echo)

export SA_CA_CRT=$(kubectl get secret $VAULT_SA_NAME -n kube-system \
     -o jsonpath="{.data['ca\.crt']}" | base64 --decode; echo)
```

Enter the following `vault write` command, replacing `<kubernetes-endpoint>` with your kubernetes api-server endpoint to write a Kubernetes Auth Config to Vault:

```text
vault write auth/kubernetes/config \
        token_reviewer_jwt="$SA_JWT_TOKEN" \
        kubernetes_host="<kubernetes-endpoint>" \
        kubernetes_ca_cert="$SA_CA_CRT"
```

##### Step 1d: Create a Kubernetes Auth Role for Portworx

Create a Kubernetes Auth Role called `portworx` in Vault:

```text
vault write auth/kubernetes/role/portworx \
        bound_service_account_names=px-account \
        bound_service_account_namespaces=kube-system \
        policies=portworx \
        ttl=<ttl>
```

##### Step 1e: Provide Vault credentials to Portworx

Portworx reads the Vault credentials required to authenticate with Vault through a Kubernetes secret. Create a Kubernetes secret with the name `px-vault` in the `portworx` namespace. You can refer to the following example Kubernetes secret spec when creating yours:

```text
apiVersion: v1
kind: Secret
metadata:
  name: px-vault
  namespace: portworx
type: Opaque
data:
  VAULT_ADDR: <base64 encoded value of the vault endpoint address>
  VAULT_BACKEND_PATH: <base64 encoded value of the custom backend path if different than the default "secret">
  VAULT_CACERT: <base64 encoded file path where the CA Certificate is present on all the nodes>
  VAULT_CAPATH: <base64 encoded file path where the Certificate Authority is present on all the nodes>
  VAULT_CLIENT_CERT: <base64 encoded file path where the Client Certificate is present on all the nodes>
  VAULT_CLIENT_KEY: <base64 encoded file path where the Client Key is present on all the nodes>
  VAULT_TLS_SERVER_NAME: <base64 encoded value of the TLS server name>
  VAULT_AUTH_METHOD: a3ViZXJuZXRlcw== // base64 encoded value of "kubernetes"
  VAULT_AUTH_KUBERNETES_ROLE: cG9ydHdvcng= // base64 encoded value of the kubernetes auth role "portworx"
```

{{<info>}}
**NOTE:** Set the value of VAULT_AUTH_KUBERNETES_ROLE to the base64 encoded value of the role created in Step 1d.
{{</info>}}

Portworx will look for this secret with name `px-vault` under the `portworx` namespace. While installing Portworx it creates a kubernetes role binding which grants access to reading kubernetes secrets only from the `portworx` namespace.

### Step 2: Setup Vault as the secrets provider for Portworx

#### New Installation

When generating the [Portworx Kubernetes spec file](https://central.portworx.com), select `Vault` from the "Secrets type" list.

#### Existing Installation

For an existing Portworx cluster follow these steps to configure Vault as the secrets provider

##### Step 2a: Add Permissions to access kubernetes secrets

Portworx needs permissions to access the `px-vault` secret created in Step 1. The following Kubernetes spec grants Portworx access to all the secrets defined under the `portworx` namespace

```text
cat <<EOF | kubectl apply -f -
# Namespace to store credentials
apiVersion: v1
kind: Namespace
metadata:
  name: portworx
---
# Role to access secrets under portworx namespace only
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: px-role
  namespace: portworx
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list", "create", "update", "patch"]
---
# Allow portworx service account to access the secrets under the portworx namespace
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: px-role-binding
  namespace: portworx
subjects:
- kind: ServiceAccount
  name: px-account
  namespace: kube-system
roleRef:
  kind: Role
  name: px-role
  apiGroup: rbac.authorization.k8s.io
EOF
```

##### Step 2b: Edit the Portworx Daemonset

Edit the Portworx daemonset `secret_type` field to `vault`, so that all the new Portworx nodes will also start using Vault.

```text
kubectl edit daemonset portworx -n kube-system
```

Add the `"-secret_type", "vault"` arguments to the `portworx` container in the daemonset. It should look something like this:
```text
containers:
  - args:
    - -c
    - testclusterid
    - -s
    - /dev/sdb
    - -x
    - kubernetes
    - -secret_type
    - vault
    name: portworx
```

Editing the DaemonSet will restart all the Portworx pods.

## Other users {#other-users}

### Step 1: Provide Vault credentials to Portworx.

Provide the following Vault credentials (key value pairs) as environment variables to Portworx


- [Required] VAULT_ADDR=<vault endpoint address>
- [Required] VAULT_TOKEN=<vault token>
- [Optional] VAULT_BASE_PATH=<vault base path>
- [Optional] VAULT_BACKEND_PATH=<custom backend path if different than the default "secret">
- [Optional] VAULT_CACERT=<file path where the CA Certificate is present on all the nodes>
- [Optional] VAULT_CAPATH=<file path where the Certificate Authority is present on all the nodes>
- [Optional] VAULT_CLIENT_CERT=<file path where the Client Certificate is present on all the nodes>
- [Optional] VAULT_CLIENT_KEY=<file path where the Client Key is present on all the nodes>
- [Optional] VAULT_TLS_SERVER_NAME=<TLS server name>


### Step 2: Set up Vault as the secrets provider for Portworx.

#### New installation

While installing Portworx set the input argument `-secret_type` to `vault`.

#### Existing installation

Based on your installation method provide the `-secret_type vault` input argument and restart Portworx on all the nodes.

## Vault security policies
If Vault is configured strictly with policies then the Vault Token provided to Portworx should follow one of the following policies:

 ```text
 # Read and List capabilities on mount to determine which version of kv backend is supported
 path "sys/mounts/*"
 {
 capabilities = ["read", "list"]
 }

 # V1 backends (Using default backend)
 # Provide full access to the portworx subkey
 # Provide -> VAULT_BASE_PATH=portworx to PX (optional)
 path "secret/portworx/*"
 {
 capabilities = ["create", "read", "update", "delete", "list"]
 }

 # V1 backends (Using custom backend)
 # Provide full access to the portworx subkey
 # Provide -> VAULT_BASE_PATH=portworx to PX (optional)
 # Provide -> VAULT_BACKEND_PATH=custom-backend (required)
 path "custom-backend/portworx/*"
 {
 capabilities = ["create", "read", "update", "delete", "list"]
 }


 # V2 backends (Using default backend )
 # Provide full access to the data/portworx subkey
 # Provide -> VAULT_BASE_PATH=portworx to PX (optional)
 path "secret/data/portworx/*"
 {
 capabilities = ["create", "read", "update", "delete", "list"]
 }

 # V2 backends (Using custom backend )
 # Provide full access to the data/portworx subkey
 # Provide -> VAULT_BASE_PATH=portworx to PX (optional)
 # Provide -> VAULT_BACKEND_PATH=custom-backend (required)
 path "custom-backend/data/portworx/*"
 {
 capabilities = ["create", "read", "update", "delete", "list"]
 }
 ```

{{<info>}}
**Note**: Portworx supports only the kv backend of Vault
{{</info>}}

All the above Vault related fields as well as the cluster secret key can be set using the Portworx CLI which is explained in the next section.


## Key generation with Vault

The following sections describe the key generation process with Portworx and Vault which can be used for encrypting volumes. More info about encrypted volumes [here](/reference/cli/encrypted-volumes)

### Setting cluster wide secret key

A cluster wide secret key is a common key that can be used to encrypt all your volumes. You can set the cluster secret key using the following command.

```text
pxctl secrets set-cluster-key --secret <cluster-wide-secret-key>
```

This command needs to be run just once for the cluster. If you have added the cluster secret key through the config.json, the above command will overwrite it. Even on subsequent Portworx restarts, the cluster secret key in config.json will be ignored for the one set through the CLI.

## \(Optional\) Authenticating with Vault using the Portworx CLI

If you do not wish to set Vault environment variables, you can authenticate Portworx with Vault using the Portworx CLI. Run the following command:

```text
pxctl secrets vault login \
  --vault-address <vault-endpoint-address> \
  --vault-token <vault-token>
```

{{<info>}}
**Important:**
You need to run this command on all Portworx nodes, so that you could create and mount encrypted volumes on all nodes.
{{</info>}}

{{<info>}}
**Important:**
Make sure that the secret key has been created in Vault.
{{</info>}}

If the CLI is used to authenticate with Vault, for every restart of the Portworx container it needs to be re-authenticated with Vault by running the `vault login` command.


## Using Vault with Portworx

{{<homelist series="vault-secret-uses">}}
