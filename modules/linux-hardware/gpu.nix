{sn, ...}: {
  sn.linux-hardware = {includes = [sn.gpu];};

  sn.gpu.nixos = {pkgs, ...}: {
    environment.systemPackages = [pkgs.usbutils];

    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        rocmPackages.clr.icd
        rocmPackages.clr
      ];
    };
  };
}
