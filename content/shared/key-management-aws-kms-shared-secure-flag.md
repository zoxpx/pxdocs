---
title: Shared content for all AWS-KMS secret docs - secure flag
keywords: AWS, KMS, Amazon Web Services, Key Management Service, encryption
description: Shared content for all AWS-KMS secret docs - secure flag
hidden: true
---

Again, if your Storage Class does not have the `secure` flag set, but you want to encrypt the PVC using the same Storage Class, then add the annotation `px/secure: "true"` to the above PVC.
