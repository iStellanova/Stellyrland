{
  flake.modules.nixos.vr =
    {
      lib,
      host,
      pkgs,
      ...
    }:
    let
      # Run after each USB reconnect, then select the saved localhost server in WiVRn.
      wivrnUsbConnect = pkgs.writeShellScriptBin "wivrn-usb-connect" ''
        set -euo pipefail
        ${pkgs.android-tools}/bin/adb reverse tcp:9757 tcp:9757
      '';
    in
    {
      hardware.steam-hardware.enable = true;
      services.wivrn = {
        enable = true;
        autoStart = true;
        steam.enable = true;
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
        wivrnUsbConnect
        xrizer
      ];

      imports = lib.optional (host.persistence or false) {
        preservation.preserveAt."/persist".users.${host.username}.directories = [
          ".config/openvr"
          ".config/wivrn"
          ".config/motoc"
          ".config/openxr"
          ".android"
        ];
      };
    };
}
