Status: **Solved**

# Boot Loss
## Problem Definition

I experienced a loss in my bootloader after a BIOS update. This was during my attempts to fix the gpu-whitescreen issue documented elsewhere. As a result, I could no longer boot into my NixOS system.

## How it was Solved
I had a NixOS live USB on hand. I used this to save the system. First, I booted into the live environment. Then, using the TTY, I mounted the partitions to my live environment from the boot disk, as it was still intact. After doing so, I ran EFI and GRUB bootloader commands in order to restore the visibility to my motherboard. Here's how it was done in detail:

1. **Mounted the Partitions:** I mounted the nix, boot, efi, and home partitions to the live environment in order to see the filesystem data.
2. **Identified the EFI Partition:** Identifying the EFI files, I focused there.
3. **Running bootmgr:** Using `efibootmgr`, I was able to create a new entry point that directed the system to the GRUB EFI binary on its own partition. It was already there, the BIOS just had no idea where it went after the update wiped it.

Easy fix, was simply unexpected.
