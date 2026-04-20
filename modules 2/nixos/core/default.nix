{ pkgs, inputs, ... }:

{
  # Use GRUB EFI boot loader.
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = true;
  };
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use CachyOS kernel with Zen 5 (v4) optimizations
  boot.kernelPackages = pkgs.linuxPackagesFor inputs.nix-cachyos-kernel.packages.${pkgs.stdenv.hostPlatform.system}."linux-cachyos-latest-lto-x86_64-v4";

  boot.kernelParams = [
    "pcie_aspm=off"          # WiFi stability
    "amd_pstate=active"      # Zen 5 Preferred Core ranking
    "preempt=full"           # Low latency
    "split_lock_detect=off"  # Smooth gaming
    "transparent_hugepage=madvise" # Smart memory usage
    "amdgpu.dcdebugmask=0x10"
    "amdgpu.ppfeaturemask=0xffffffff" # GPU tuning
    "amdgpu.ignore_min_pcap=1"        # Uncap power limits
    "init=/sbin/finit"                # Finix Migration
  ];

  # Sched-ext (scx) - Manual finit migration required
  services.scx.enable = false;

  # SSD Maintenance - Manual finit migration required
  services.fstrim.enable = false;

  # Set your time zone.
  time.timeZone = "America/Indianapolis";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Nix Settings
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    log-lines = 25;
    auto-optimise-store = true;
    warn-dirty = false;
    min-free = 2147483648; # 2GB
    max-free = 5368709120; # 5GB
    builders-use-substitutes = true;
  };

  security.sudo-rs = {
    enable = true;
    extraConfig = ''
      Defaults pwfeedback
    '';
  };

  # NH cleaner - Systemd-based cleaning disabled for finit
  programs.nh = {
    enable = true;
    clean.enable = false;
    flake = "/etc/nixos";
  };

  environment.variables = {
    FLAKE = "/etc/nixos";
    NIXOS_OZONE_WL = "1";
  };

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.11"; # Don't Change, for Compat.
}
