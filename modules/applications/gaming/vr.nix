{
  flake.modules.nixos.vr =
    {
      lib,
      host,
      pkgs,
      ...
    }:
    let
      # Reconnect the Quest over USB using the explicit IPv4 endpoint.
      wivrnUsbConnect = pkgs.writeShellScriptBin "wivrn-usb-connect" ''
        set -euo pipefail
        ${pkgs.android-tools}/bin/adb reverse tcp:9757 tcp:9757
        ${pkgs.android-tools}/bin/adb shell am force-stop org.meumeu.wivrn
        ${pkgs.android-tools}/bin/adb shell am start \
          -a android.intent.action.VIEW \
          -d "wivrn+tcp://127.0.0.1:9757" \
          org.meumeu.wivrn
      '';
    in
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
        wivrnUsbConnect
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
