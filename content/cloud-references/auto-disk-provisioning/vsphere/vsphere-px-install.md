---
title: Portworx vSphere installation
description: Portworx vSphere installation
keywords: portworx, VMware, vSphere ASG
hidden: true
---

### Step 1: vCenter user for Portworx

You will need to provide Portworx with a vCenter server user that will need to either have the full Admin role or, for increased security, a custom-created role with the following minimum [vSphere privileges](https://docs.vmware.com/en/VMware-vSphere/6.7/com.vmware.vsphere.security.doc/GUID-FEAB5DF5-F7A2-412D-BF3D-7420A355AE8F.html):

- Datastore.Browse
- Datastore.FileManagement
- Host.Local.ReconfigVM
- VirtualMachine.Config.AddExistingDisk
- VirtualMachine.Config.AddNewDisk
- VirtualMachine.Config.AddRemoveDevice
- VirtualMachine.Config.AdvancedConfig
- VirtualMachine.Config.EditDevice
- VirtualMachine.Config.RemoveDisk
- VirtualMachine.Config.Settings

### Step 2: Create a Kubernetes secret with your vCenter user and password

{{% content "cloud-references/auto-disk-provisioning/vsphere/vsphere-secret.md" %}}

### Step 3: Generate rest of the specs

#### vSphere environment details

Export following env variables based on your vSphere environment.

```text
# Hostname of your vCenter server
export VSPHERE_VCENTER=myvcenter.net

# Prefix of your shared ESXi datastore(s) that Portworx will use for storage
export VSPHERE_DATASTORE_PREFIX=mydatastore-

# Change this to the port number vSphere services are running on if you have changed the default port 443
export VSPHERE_VCENTER_PORT=443
```

#### Disk templates

A disk template defines the VMDK properties that Portworx will use as a reference for creating the actual disks out of which Portworx will create the virtual volumes for your PVCs.

The template follows the following format:

```
"type=<vmdk type>,size=<size of the vmdk>"
```

- __type__: Following two types are supported
  - _thin_
  - _zeroedthick_
  - _eagerzeroedthick_
- __size__: This is the size of the VMDK

Export following variable with the disk template you would like. Following example will create a 150GB zeroed thick vmdk on each VM.

```text
export VSPHERE_DISK_TEMPLATE=type=zeroedthick,size=150
```

#### Generate the spec file

Now generate the spec with the following curl command. Run this from a machine which has kubectl access to your cluster.

{{<info>}}Observe how curl below uses the variables setup up above as query parameters.{{</info>}}

```text
VER=$(kubectl version --short | awk -Fv '/Server Version: /{print $3}')
curl -fsL -o px-spec.yaml "https://vsphere.install.portworx.com/?c=portworx-demo-cluster&b=true&csi=true&vsp=true&ds=$VSPHERE_DATASTORE_PREFIX&vc=$VSPHERE_VCENTER&s=%22$VSPHERE_DISK_TEMPLATE%22&md=zeroedthick,size=150"
```

{{% content "portworx-install-with-kubernetes/shared/4-apply-the-spec.md" %}}