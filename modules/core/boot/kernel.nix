_: {
  # NixOS Custom Kernel Settings
  flake.modules.nixos.kernel = {
    lib,
    pkgs,
    ...
  }: {
    config = {
      # ─────────────────────────────────────────────────────────────────────────
      # Kernel Package: CachyOS BORE + LTO (Branded)
      # ─────────────────────────────────────────────────────────────────────────
      boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto.extend (
        _lp-self: lp-super: {
          kernel =
            (lp-super.kernel.override {
              # Use .override to set the "Expected" version before the build starts
              modDirVersion = "${lib.head (lib.splitString "-" lp-super.kernel.version)}-stellyrkernel";
            }).overrideAttrs (old: rec {
              pname = "linux";
              version = "${lib.head (lib.splitString "-" old.version)}-stellyrkernel";
              __intentionallyOverridingVersion = true;
            });
        }
      );

      boot.kernelPatches = [
        {
          name = "stellyrland-super-kernel";
          patch = null;
          structuredExtraConfig = with lib.kernel; {
            # ── Wine/Proton NT Sync ───────────────────────────────────────────
            NTSYNC = module;

            # ── Scheduler & Performance ───────────────────────────────────────
            # use the expected name here to pass the check, but rename in postInstall
            LOCALVERSION = lib.mkForce (freeform "-stellyrkernel");
            LOCALVERSION_AUTO = lib.mkForce no;
            SCHED_BORE = yes;
            SCHED_CLASS_EXT = yes;
            X86_AMD_PSTATE = yes;
            AMD_PMC = module;
            X86_AMD_FREQ_SENSITIVITY = module;
            ZRAM = module;
            CRYPTO_ZSTD = yes;
            CRYPTO_LZ4 = module;
            CRYPTO_LZ4HC = module;

            # ── Hardware Baseline (Verified Targets) ──────────────────────────

            # GPU: AMDGPU (Navi 31 + Zen 5 iGPU)
            DRM = yes;
            DRM_AMDGPU = module;
            AMDGPU_USERPTR = yes;
            DRM_AMD_DC = yes;
            DRM_AMD_DC_FP = yes;
            HSA_AMD = yes;
            DRM_TTM = yes;

            # Storage: PCIe5/4 NVMe + Btrfs
            BLK_DEV_NVME = module;
            NVME_MULTIPATH = yes;
            FS_BTRFS = yes;
            BTRFS_FS_POSIX_ACL = yes;
            FS_EXT4 = yes;
            SATA_AHCI = module;
            BLK_DEV_SD = module;

            # Network: Realtek 2.5G + MediaTek 6E
            R8169 = module;
            WLAN_VENDOR_MEDIATEK = yes;
            MT7921E = module;
            MT7921_COMMON = module;
            MT792x_LIB = module;
            MT76_CONNAC_LIB = module;
            MT76_CORE = module;
            MAC80211 = module;
            CFG80211 = module;
            RFKILL = yes;
            TUN = module; # Tailscale

            # Sound & USB
            SND_HDA_INTEL = module;
            SND_HDA_CODEC_REALTEK = module;
            SND_HDA_CODEC_HDMI = module;
            SND_USB_AUDIO = module; # Focusrite
            USB_XHCI_HCD = module;
            USB_XHCI_PCI = module;
            USB_ACM = module;
            USB_HID = module;
            HID_GENERIC = module;
            HID_LOGITECH = module;
            HID_LOGITECH_DJ = module;
            HID_LOGITECH_HIDPP = module;

            # Bluetooth & I2C
            BT = module;
            BT_HCIUSB = module;
            BT_MTK = module;
            I2C_PIIX4 = module; # FCH SMBus
            I2C_DEV = module; # OpenRGB
            GIGABYTE_WMI = module;
            SENSORS_K10TEMP = module;
            SENSORS_NCT6775 = module; # Mainboard sensors

            # ── THE GREAT PRUNING (Exhaustive & Consolidated) ────────────────

            # 1. Platform & Graphics Purge (No Intel/Nvidia/Legacy/Cloud)
            DRM_AMDGPU_CIK = lib.mkForce no;
            DRM_AMDGPU_SI = lib.mkForce no;
            DRM_AST = lib.mkForce no;
            DRM_I915 = lib.mkForce no;
            DRM_MGAG200 = lib.mkForce no;
            DRM_NOUVEAU = lib.mkForce no;
            DRM_QXL = lib.mkForce no;
            DRM_RADEON = lib.mkForce no;
            DRM_VGEM = lib.mkForce no;
            DRM_VIRTIO_GPU = lib.mkForce no;
            DRM_VKMS = lib.mkForce no;
            HYPERV = lib.mkForce no;
            HYPERVISOR_GUEST = lib.mkForce no;
            KVM_INTEL = lib.mkForce no;
            XEN = lib.mkForce no;

            # 2. Enterprise & Server Networking (No 100G/FibreChannel)
            NET_VENDOR_ADAPTEC = lib.mkForce no;
            NET_VENDOR_ALTEON = lib.mkForce no;
            NET_VENDOR_AMAZON = lib.mkForce no;
            NET_VENDOR_CISCO = lib.mkForce no;
            NET_VENDOR_DEC = lib.mkForce no;
            NET_VENDOR_DLINK = lib.mkForce no;
            NET_VENDOR_FUNGIBLE = lib.mkForce no;
            NET_VENDOR_GOOGLE = lib.mkForce no;
            NET_VENDOR_HP = lib.mkForce no;
            NET_VENDOR_MELLANOX = lib.mkForce no;
            NET_VENDOR_MICROSOFT = lib.mkForce no;
            NET_VENDOR_NI = lib.mkForce no;
            NET_VENDOR_PENSANDO = lib.mkForce no;
            NET_VENDOR_QLOGIC = lib.mkForce no;
            NET_VENDOR_SGI = lib.mkForce no;
            NET_VENDOR_SUN = lib.mkForce no;
            NET_VENDOR_VIA = lib.mkForce no;
            VIRTIO_NET = lib.mkForce no;
            E1000 = lib.mkForce no;
            E1000E = lib.mkForce no;
            IGB = lib.mkForce no;
            IXGBE = lib.mkForce no;
            I40E = lib.mkForce no;
            ICE = lib.mkForce no;
            MLX4_EN = lib.mkForce no;
            MLX5_CORE = lib.mkForce no;

            # 3. Wireless Vendor Purge (All except MediaTek)
            WLAN_VENDOR_ADM8211 = lib.mkForce no;
            WLAN_VENDOR_ATH = lib.mkForce no;
            WLAN_VENDOR_ATMEL = lib.mkForce no;
            WLAN_VENDOR_BROADCOM = lib.mkForce no;
            WLAN_VENDOR_INTEL = lib.mkForce no;
            WLAN_VENDOR_INTERSIL = lib.mkForce no;
            WLAN_VENDOR_MARVELL = lib.mkForce no;
            WLAN_VENDOR_MICROCHIP = lib.mkForce no;
            WLAN_VENDOR_PURELIFI = lib.mkForce no;
            WLAN_VENDOR_QUANTENNA = lib.mkForce no;
            WLAN_VENDOR_RALINK = lib.mkForce no;
            WLAN_VENDOR_REALTEK = lib.mkForce no;
            WLAN_VENDOR_RSI = lib.mkForce no;
            WLAN_VENDOR_ST = lib.mkForce no;
            WLAN_VENDOR_TI = lib.mkForce no;
            WLAN_VENDOR_ZYDAS = lib.mkForce no;
            ATH9K = lib.mkForce no;
            ATH10K = lib.mkForce no;
            BRCMFMAC = lib.mkForce no;
            MWIFIEX = lib.mkForce no;
            RTW88 = lib.mkForce no;
            RTW89 = lib.mkForce no;
            RTL8XXXU = lib.mkForce no;

            # 4. Multimedia, TV & Audio Purge
            SND_SOC = lib.mkForce no;
            SND_SOC_ALL_CODECS = lib.mkForce no;
            SND_SOC_AMD_ACP3x = lib.mkForce no;
            SND_SOC_AMD_PS = lib.mkForce no;
            SND_SOC_AMD_RENOIR = lib.mkForce no;
            SND_SOC_INTEL_AVS = lib.mkForce no;
            SND_SOC_INTEL_SOF = lib.mkForce no;
            DVB_CORE = lib.mkForce no;
            MEDIA_DIGITAL_TV_SUPPORT = lib.mkForce no;
            MEDIA_RADIO_SUPPORT = lib.mkForce no;
            MEDIA_SDR_SUPPORT = lib.mkForce no;
            MEDIA_TEST_SUPPORT = lib.mkForce no;
            VIDEO_IR_I2C = lib.mkForce no;
            VIDEO_PWC = lib.mkForce no;
            USB_GSPCA = lib.mkForce no;
            V4L_PLATFORM_DRIVERS = lib.mkForce no;
            V4L_MEM2MEM_DRIVERS = lib.mkForce no;

            # 5. Enterprise Storage & Legacy Purge
            SCSI_AACRAID = lib.mkForce no;
            SCSI_AIC7XXX = lib.mkForce no;
            SCSI_AIC94XX = lib.mkForce no;
            SCSI_HPSA = lib.mkForce no;
            SCSI_MEGARAID_SAS = lib.mkForce no;
            SCSI_UFSHCD = lib.mkForce no;
            FUSION = lib.mkForce no;
            INFINIBAND = lib.mkForce no;
            PATA_LEGACY = lib.mkForce no;
            ATA_GENERIC = lib.mkForce no;
            BLK_DEV_SR = lib.mkForce no;
            CHR_DEV_ST = lib.mkForce no;

            # 6. Legacy Peripherals & Obscure Silicon
            USB_OHCI_HCD = lib.mkForce no;
            USB_UHCI_HCD = lib.mkForce no;
            USB_EHCI_HCD = lib.mkForce no;
            USB_SERIAL = lib.mkForce no;
            USB_NET_DRIVERS = lib.mkForce no;
            FIREWIRE = lib.mkForce no;
            PCCARD = lib.mkForce no;
            RAPIDIO = lib.mkForce no;
            COMEDI = lib.mkForce no;
            IIO = lib.mkForce no;
            MTD = lib.mkForce no;
            FSI = lib.mkForce no;
            MISC_RP1 = lib.mkForce no;
            IP_PNP = lib.mkForce no;
            HAMRADIO = lib.mkForce no;
            CAN = lib.mkForce no;
            NFC = lib.mkForce no;
            STAGING = lib.mkForce no;

            # 7. Laptop & Mobile Purge
            X86_PLATFORM_DRIVERS_DELL = lib.mkForce no;
            X86_PLATFORM_DRIVERS_HP = lib.mkForce no;
            X86_PLATFORM_DRIVERS_LENOVO = lib.mkForce no;
            SAMSUNG_LAPTOP = lib.mkForce no;
            ASUS_WMI = lib.mkForce no;
            ACER_WMI = lib.mkForce no;
            INPUT_TOUCHSCREEN = lib.mkForce no;
            CHROME_PLATFORMS = lib.mkForce no;
            MFD_CROS_EC = lib.mkForce no;
            REGULATOR = lib.mkForce module; # Dependency requirement

            # 8. Obscure Input & HID Purge
            HID_PICOLCD = lib.mkForce no;
            HID_PLANTRONICS = lib.mkForce no;
            HID_PRIMAX = lib.mkForce no;
            HID_SPEEDLINK = lib.mkForce no;
            HID_TIVO = lib.mkForce no;
            HID_WIIMOTE = lib.mkForce no;
            MOUSE_APPLETOUCH = lib.mkForce no;
            MOUSE_BCM5974 = lib.mkForce no;
            MOUSE_CYAPA = lib.mkForce no;
            MOUSE_PS2_SENTELIC = lib.mkForce no;
            INPUT_MISC = lib.mkForce no;

            # 9. Filesystem Purge
            ADFS_FS = lib.mkForce no;
            AFS_FS = lib.mkForce no;
            CIFS = lib.mkForce no;
            GFS2_FS = lib.mkForce no;
            JFS_FS = lib.mkForce no;
            NFS_FS = lib.mkForce no;
            OCFS2_FS = lib.mkForce no;
            ORANGEFS_FS = lib.mkForce no;
            REISERFS_FS = lib.mkForce no;
            XFS_FS = lib.mkForce no;

            # 10. Sensor Purge (Keep K10TEMP/NCT6775)
            SENSORS_ABITUGURU = lib.mkForce no;
            SENSORS_ADM1021 = lib.mkForce no;
            SENSORS_ADM1025 = lib.mkForce no;
            SENSORS_ADT7410 = lib.mkForce no;
            SENSORS_F71805F = lib.mkForce no;
            SENSORS_ITE = lib.mkForce no;
            SENSORS_MAXIM = lib.mkForce no;
            # 11. Shadow Purge (The "Hidden 74" found during audit)
            DRM_XE = lib.mkForce no;
            DRM_GPUSVM = lib.mkForce no;
            DRM_GPUVM = lib.mkForce no;
            INTEL_MEI = lib.mkForce no;
            INTEL_MEI_GSC = lib.mkForce no;
            INTEL_MEI_PXP = lib.mkForce no;
            FB_VGA16 = lib.mkForce no;
            FB_VESA = lib.mkForce no;
            FCOE = lib.mkForce no;
            LIBFC = lib.mkForce no;
            ATA_PIIX = lib.mkForce no;
            IT87_WDT = lib.mkForce no;
            LAN743X = lib.mkForce no;
            LAN865X = lib.mkForce no;
            LAN966X_SWITCH = lib.mkForce no;
            NET_VENDOR_NETRONOME = lib.mkForce no;
            "9P_FS" = lib.mkForce no;
          };
        }
      ];

      # ── Initrd Fix ──────────────────────────────────────────────────
      boot.initrd.includeDefaultModules = lib.mkForce false;
      boot.initrd.availableKernelModules = lib.mkForce [
        "nvme"
        "xhci_pci"
        "ahci"
        "usbhid"
        "usb_storage"
        "sd_mod"
        # LUKS/crypto: must be explicit because includeDefaultModules = false
        # strips the modules NixOS would normally add for encrypted-devices.
        "dm_mod"
        "dm_crypt"
        "aesni_intel" # hardware AES-NI (AMD Zen 5 + Intel); loaded before dm_crypt
        "xts" # XTS block cipher mode used by the LUKS container
        "cryptd" # async crypto daemon; required by aesni_intel
      ];
    };
  };
}
