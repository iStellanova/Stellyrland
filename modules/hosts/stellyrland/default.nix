{ inputs, ... }:
{
  flake-file.inputs.cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

  flake.modules.nixos.stellyrland-host =
    {
      host,
      pkgs,
      ...
    }:
    {
      imports = [
        ./_hardware-configuration.nix
        ./_disko-config.nix
        ./_lact-config.nix
        ./_coolercontrol-config.nix
        ./_boot.nix
        ./_storage.nix
        ./_desktop.nix
      ];

      networking.hostName = host.name;

      systemd.tmpfiles.rules = [
        "w /sys/bus/platform/drivers/amd_x3d_vcache/AMDI0101:00/amd_x3d_mode - - - - cache"
      ];

      hardware.amdgpu.initrd.enable = false;
      hardware.enableRedistributableFirmware = true;
      hardware.cpu.amd.updateMicrocode = true;
      environment.systemPackages = [ pkgs.usbutils ];
      hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [
          rocmPackages.clr.icd
          rocmPackages.clr
        ];
      };

      zramSwap = {
        enable = true;
        algorithm = "zstd";
        swapDevices = 1;
        priority = 100;
        memoryPercent = 100;
      };

      services.irqbalance.enable = true;

      services.ananicy = {
        enable = true;
        # Remove when an ananicy-cpp release includes these standard headers.
        package = pkgs.ananicy-cpp.overrideAttrs (old: {
          postPatch = (old.postPatch or "") + ''
            sed -i '1i#include <cstdint>' src/platform/linux/backtrace.cpp
            sed -i '1i#include <cstring>' src/utility/argument_parsing/argument.cpp
            sed -i '1i#include <cstring>' src/platform/linux/singleton_process.cpp
          '';
        });
        rulesProvider = pkgs.ananicy-rules-cachyos;
      };

      services.scx = {
        enable = true;
        # LAVD favors latency-sensitive threads on the X3D CCD.
        scheduler = "scx_lavd";
      };
    };
}
