{
  flake.modules.nixos.vr =
    {
      lib,
      host,
      pkgs,
      ...
    }:
    {
      hardware.steam-hardware.enable = true;
      services.wivrn = {
        enable = true;
        autoStart = true;
        steam.importOXRRuntimes = true;

        config.enable = true;
        config.json = {
          "use-steamvr-lh" = true;
          codec = "h265";
        };
      };

      environment.systemPackages = with pkgs; [
        android-tools
        motoc
        xrizer
      ];

      imports = lib.optional (host.persistence or false) {
        preservation.preserveAt."/persist".users.${host.username}.directories = [
          ".config/openvr"
          ".config/wivrn"
          ".config/motoc"
          ".android"
        ];
      };
    };
}
