1. Export your registry location:

    ```text
    export REGISTRY=myregistry.net:5443
    ```
{{<info>}} The registry location above can be a registry and it's port (e.g _myregistry.net:5443_) or it could include your own repository in the registry (e.g _myregistry.net:5443/px-images_).
{{</info>}}

2. Push it to the above registry.

    ```text
    # Trim trailing slashes:
    REGISTRY=${$(echo $REGISTRY | tr -s /)%/}
    # re-tag and push into custom/local registry defined previously
    # Check if using custom registry+repository (e.g. `REGISTRY=myregistry.net:5443/px-images`)
    # or just the registry (e.g. `REGISTRY=myregistry.net:5443`)
    echo $REGISTRY | grep -q /
    if [ $? -eq 0 ]; then
        # registry + repo are used -- we'll strip original image repositories
        for i in $PX_IMGS $PX_ENT; do tg="$REGISTRY/$(basename $i)" ; docker pull $i; docker tag $i $tg ; docker push $tg ; done
    else
        # only registry used -- we'll keep original image repositories
        for i in $PX_IMGS $PX_ENT; do tg="$REGISTRY/$i" ; docker pull $i; docker tag $i $tg ; docker push $tg ; done
    fi
    ```