---
title: Air gapped installs - push to local
keywords: Install, on-premise, kubernetes, k8s, air gapped
description: Air gapped installs - push to local
hidden: true
---

1. Export your registry location:

    ```text 
    export REGISTRY=<YOUR_REGISTRY_LOCATION>
    ```

    Note that the registry location can be:

    - a registry and its port:

    ```text
    export REGISTRY=myregistry.net:5443
    ```

    or

    - it could include your own repository:

    ```text
    export REGISTRY=_myregistry.net:5443/px-images
    ```

2. Push the images to the registry:

    ```text
    # Trim trailing slashes:
    REGISTRY=${REGISTRY%/}
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
