---
title: Set up login redirects
weight: 6
keywords: Install, PX-Central, On-prem, license, GUI, k8s, Okta, Auth0
description: See how you can integrate PX-Central with Okta and Auth0.
noicon: true
---

If you configure PX-Central to use an external OIDC provider, then you must manually configure the redirect URI in your OIDC provider.

## Prerequisites

You must use certificates signed by a trusted certificate authority.

## Configure a login redirect URI in Okta

Perform the following steps to configure a login redirect URI in Okta:

1. From the **Applications** tab in your Okta dashboard, select the **Add Application** button.
2. From the **Create New Application** page, select the **Web** tile, and then select **Next**.
3. In the **Login redirect URIs** box, enter your login redirect URI, and then select **Add URI**.

## Configure a login redirect URI in Auth0

Perform the following steps to configure a login redirect URI in Auth0:

1. In the left sidebar of your Auth0 dashboard, select **Applications**, then select the **CREATE APPLICATION** button.
2. On the **Create application** page, enter the name of your application and choose **Regular Web Applications**, then select **CREATE**.
3. On your newly created applicaiton page, select the **Settings** tab.
4. In the **Allowed Callback URLs** box, enter your login redirect URI.
