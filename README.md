# talos-boot-assets

This repository contains a [GitHub Actions](https://docs.github.com/en/actions) workflow that runs on a cronjob every hour to check and see if a new official [Talos Linux](https://github.com/siderolabs/talos) release has been pushed.

If it detects a newer version is available _(compared to the tag(s) in this repo)_ it will use [Talos Imager](https://github.com/siderolabs/talos/tree/main/pkg/imager) to build new [Boot Assets](https://www.talos.dev/v1.5/talos-guides/install/boot-assets/) used in my [homelab cluster](https://github.com/jfroy/flatops).

## Customizations

### Kernel

The workflow includes [patches](./patches/pkgs) to the [Talos kernel](https://github.com/siderolabs/pkgs/tree/main/kernel).

- Update version to latest stable [upstream kernel](https://kernel.org/).
- Optimized amd64 kernel configuration for my use cases:
  - no xen support
  - no hyperv support
  - AMD extensions: SEV, IOMMU, etc
  - only Intel and Mellanox network drivers
  - only basic EFI fb graphics drivers
  - no legacy SATA/PATA/ATA support
  - no legacy network protocols
  - netkit (for cilium)
  - INET diag w/ destroy (for cilium socket lb)

The final build artifact is a signed [Unified Kernel Image](https://wiki.archlinux.org/title/Unified_kernel_image).

### Nvidia drivers

The workflow builds the latest stable Nvidia open kernel kernel modules and packages the matching userspace components, replacing the Siderolabs Nvidia system extension.

### Secure boot

The workflow builds a secure boot installer container image and ISO. I manage my own secure boot chain of trust which the workflow uses to sign the kernel UKI and the expected TPM PCR measurements for disk encryption.
