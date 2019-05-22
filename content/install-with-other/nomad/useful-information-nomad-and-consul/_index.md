---
title: Nomad and consul
linkTitle: Nomad and consul
keywords: portworx, container, Nomad, storage, consul
description: Nomad and consul.
weight: 2
series: px-nomad-useful-information
noicon: true
hidden: true
---

Nomad has a very natural alignment with `consul`. Therefore, having _Portworx_ use `consul` as the clustered `kvdb` when deployed through Nomad makes common sense. When doing so, `consul` can be referenced locally on all nodes, as with `127.0.0.1:8500`