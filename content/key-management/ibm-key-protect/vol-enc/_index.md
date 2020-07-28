You can use one of the following methods to encrypt Portworx volumes with Google Cloud KMS, depending on how you provide the secret password to Portworx:

- [Encrypt volumes using per volume secrets](#encrypt-volumes-using-per-volume-secrets)
- [Encrypt volumes using a cluster-wide secret](#encrypt-volumes-using-a-cluster-wide-secret)


## Encrypt volumes using per volume secrets

Use per volume secrets to encrypt each volume with a different key. As a result, each volume uses its unique passphrase for encryption. Portworx uses IBM Key Protect APIs to generate a unique 256-bit passphrase.

1. Create a volume. Enter the `pxctl volume create` command specifying the `--secure` flag with the name of your encrypted volume (this example uses `enc_vol`)

    ```text
    pxctl volume create --secure  enc_vol
    ```

<!-- We should also add the commands that attach and mount a volume. I'm not sure if the user should pass `--secret_id` argument. -->

**Docker users:**

1. You can use the following command to create an encrypted volume named `enc_vol`:

    ```text
      docker volume create --volume-driver pxd secure=true,name=enc_vol
    ```

2. To attach and mount an encrypted volume, enter the following command:

    ```text
    docker run --rm -it -v secure=true,name=enc_vol:/mnt busybox
    ```

## Encrypt volumes using a cluster-wide secret

1. Set the cluster-wide secret key. Enter the following `pxctl secrets set-cluster-key` command specifying the `--secret` parameter with your secret passphrase (this example uses `mysecretpassphrase`):

    ```text
    pxctl secrets set-cluster-key --secret mysecretpassphrase
    ```

    ```output
    Successfully set cluster secret key!
    ```
    {{<info>}}
**WARNING:** You must set the cluster-wide secret only once. If you overwrite the cluster-wide secret, the volumes encrypted with the old secret will become unusable.
    {{</info>}}

    If you've specified your cluster wide secret key in the `config.json` file, the `pxctl secrets set-cluster-key` command will overwrite it. Even if you restart your cluster, Portworx will use the key you passed as an argument to the `pxctl secrets set-cluster-key` command.


2. Create a new encrypted volume. Enter the `pxctl volume create` command, specifying the following arguments:
  * `--secure`
  * `--secret-key` with the `default` value
  * the name of the encrypted volume (this example uses `enc_vol`)

    ```text
    pxctl volume create --secure --secret_key default enc_vol
    ```

    ```
    Volume successfully created: 374663852714325215
    ```

    **Docker users:**
    You can use the following example command to create an encrypted volume named `enc_vol`:

    ```text
    docker volume create --volume-driver pxd secret_key=default,name=enc_vol
    ```

3. Enter the `pxctl volume list` command to list your volumes:

    ```text
    pxctl volume list
    ```

    ```output
    ID                      NAME        SIZE    HA SHARED   ENCRYPTED   IO_PRIORITY SCALE   STATUS
    822124500500459627   enc_vol   10 GiB  1    no yes     LOW     1   up - detached
    ```

2. Attach your volume by entering the `pxctl host attach` command with the following arguments:

    * The name of your encrypted volume (this example uses `enc_vol`)
    * The `--secret-key` flag with the `default` vaule


    ```text
    pxctl host attach enc_vol --secret_key default
    ```

    ```output
    Volume successfully attached at: /dev/mapper/pxd-enc822124500500459627
    ```

3. Mount the volume by entering the `pxctl host mount` command with the following parameters:

    * The name of your encrypted volume (this example uses `enc_vol`)
    * The mount point (this example uses `mnt`)

    ```text
    pxctl host mount enc_vol /mnt
    ```

    ```output
    Volume enc_vol successfully mounted at /mnt
    ```

    **Docker users:**
    Enter the following example command to attach and mount an encrypted volume:

    ```text
    docker run --rm -it -v secure=true,secret_key=default,name=enc_vol:/mnt busybox
    ```

If you want to migrate encrypted volumes created through this method between two different Portworx clusters, then you must:

  1. Create a secret with the same name. You can use the `--secret-id` flag to specify the name of your secret, as shown in step 1.
  2. Make sure you provide the same **passphrase** while generating the secret.
