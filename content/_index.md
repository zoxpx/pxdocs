---
title: Portworx Documentation
description: Find out more about Portworx, the persistent storage solution for containers. Come check us out for step-by-step guides and tips!
keywords: portworx, kurbernetes, containers, storage
weight: 1
hidesections: true
disableprevnext: true
scrollspy-container: false
---
<ul class="list-series">
<li class="list-series__item mdl-card mdl-shadow--2dp">
<a href="https://backup.docs.portworx.com">
    <div class="mdl-card__title">
    <homelistseriestitle class="mdl-card__title-text">
        PX-Backup documentation
    </homelistseriestitle>
    </div>
    <div class="mdl-card__supporting-text">
        <p>PX-Backup is a Kubernetes backup solution that allows you to back up and restore applications and their data across multiple clusters.</p>
    </div>
    <i class="material-icons">arrow_forward_ios</i>
</a>
</li>
</ul>

{{<info>}}
**ADVISORIES:** 

* **All customers should upgrade their Stork version**   

    For customers running 2.5.x versions of Stork, please upgrade to 2.6.x or later.

    These releases provide a critical fix related to PX-Motion and Portworx DR. Without this fix, there is a high risk that you will encounter unexpected results when OCP objects are restored on the destination. This could result in a loss of connectivity to core OCP services.

    Pure Storage is committed to ensuring your upgrade is successful. Please reach out to the Customer Success team support@portworx.com to schedule an upgrade or request the upgrade procedure for your environment.
    
* **Looking to upgrade to OpenShift 4.3?** 

    See the [Preparing Portworx to upgrade to OpenShift 4.3 using the Operator](/portworx-install-with-kubernetes/openshift/operator/openshift-upgrade/) article for instructions.
{{</info>}}

Portworx is a software defined storage overlay that allows you to

* Run containerized stateful applications that are highly-available (HA) across multiple nodes, cloud instances, regions, data centers or even clouds
* Migrate workflows between multiple clusters running across same or hybrid clouds
* Run hyperconverged workloads where the data resides on the same host as the applications
* Have programmatic control on your storage resources

Based on your environment, proceed to one of the below sections.
{{<homelist series="top">}}
