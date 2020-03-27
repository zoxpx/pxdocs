---
title: lsctl
description: CLI reference for lsctl commands
keywords: lsctl, CLI, command line, command line tool, reference
weight: 1
hidden: true
---

`lsctl` is the license server command-line interface that allows you to control the Portworx license server independently from PX-Central. This cli is intended for advanced operations staff which may require custom license server implementations not achievable through the PX-Central UI and offers more options and provides more granular control of your Portworx license server than the PX-Central UI. You may need to use `lsctl` to perform certain actions that you cannot perform from the PX-Central UI.

<!-- In most cases, you won’t need to use `lsctl` or need to manually install/configure your license server. See the [PX-Central](/) documentation for information on operating the default license server implementation from the the PX-Central UI. -->

If you want to install the license server and administer it manually using the command line, follow the articles below in order:

1. [Manually install a Portworx license server](/reference/cli/lsctl/manual-install)
2. [(Recommended) Install a backup license server](/reference/cli/lsctl/install-backup-server)
3. [Add licenses to a license server using `lsctl`](/reference/cli/lsctl/add-licenses)
