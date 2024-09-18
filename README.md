# talos-boot-assets

This repository contains a [GitHub Actions](https://docs.github.com/en/actions) workflow that will build a custom Talos release, using forks of the SideroLabs repos (pkgs, extensions, Talos). It outputs a secure boot ISO and installer container image that can be used to install Talos on a new system or upgrade an existing node.

## Customizations

### Kernel

The pkgs fork upgrades the kernel to the latest stable release and provides a custom configuration with the following changes compared to the SideroLabs configuration:

- no xen support
- no hyperv support
- AMD support (SEV, IOMMU, etc)
- only Intel and Mellanox network drivers
- only basic EFI fb graphics drivers
- no legacy SATA/PATA/ATA support
- no legacy network protocols
- netkit (for cilium)
- INET diag w/ destroy (for cilium socket lb)

support for nvidia gpu operator:

- module unloading
- ACPI TAD, PROC AGG, PCI SLOT, HOTPLUG MEM, BGRT, APEI MEM FAIL,
  EXTLOG, CONFIGFS, PFRUT, FHH
- memory hotplug and hotremove
- memory failure
- zone and device private
- pci p2pdma
- virtio mem

The final build artifact is a signed [Unified Kernel Image](https://wiki.archlinux.org/title/Unified_kernel_image).

### Nvidia drivers

The workflow builds the latest production Nvidia open kernel kernel modules as part of the pkgs build (to use the ephemeral kernel module signing key). The workflow then builds a custom NVIDIA driver container to bundle the kernel modules with the userspace components. Driver containers are managed by the [NVIDIA gpu-operator](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/index.html).

### Talos extensions

The workflow builds my custom glibc extension to support the NVIDIA gpu-operator and driver containers. Only [CDI mode](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/cdi.html) will work, as the legacy runtime hook will not have the required system libraries to work.
