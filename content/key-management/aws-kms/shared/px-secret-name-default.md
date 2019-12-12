---
hidden: true
---

Take a note of the annotation `px/secret-name: default`. This specific annotation indicates Portworx to use the default secret to encrypt the volume. In this case, it will **NOT**  create a new passphrase for this volume and NOT use per volume encryption. If the annotation is not provided then Portworx will use the per volume encryption workflow as described in the previous section
