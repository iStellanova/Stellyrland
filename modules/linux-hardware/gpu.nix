_: {
  flake.modules.nixos.gpu = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.usbutils ];

    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        rocmPackages.clr.icd
        rocmPackages.clr
      ];
    };
  };
}
