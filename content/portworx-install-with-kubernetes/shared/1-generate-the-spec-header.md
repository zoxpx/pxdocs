---
title: Shared
hidden: true
---

To install Portworx with Kubernetes, you will first generate a Daemonset Spec file that tells Kubernetes what parameters to use.

You can generate the spec either by using the GUI wizard \(the preferred method\) or via the command line. When generating the spec, be mindful of the parameter notes below.

## Parameter Notes

### Specify the HTTP and HTTPS proxy in the environment variables parameter

The Portworx installation will require Internet access to fetch the kernel headers, if they are not available locally. If your cluster runs behind an HTTP or HTTPS proxy, you must specify the proxy server\(s\) in the DaemonSet spec. To do this using the GUI wizard, add the string `PX_HTTP_PROXY=<http-proxy>,PX_HTTPS_PROXY=<https-proxy>` to the **List of environment variables** section. Or if using the command line to generate the spec, specify `PX_HTTP_PROXY=<http-proxy>,PX_HTTPS_PROXY=<https-proxy>` using the `e` parameter.
