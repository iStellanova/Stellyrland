_: {
  flake.modules.nixos.vr =
    { pkgs, ... }:
    let
      # USB-only setup (no wireless streaming): the headset never touches the
      # LAN, so there's no discovery step. This tunnel doesn't survive
      # unplugging, so it needs re-running on every fresh USB connection —
      # after that, open WiVRn on the headset and tap the saved "localhost"
      # server entry.
      wivrnUsbConnect = pkgs.writeShellScriptBin "wivrn-usb-connect" ''
        set -euo pipefail
        ${pkgs.android-tools}/bin/adb reverse tcp:9757 tcp:9757
      '';
    in
    {
      # Valve/HTC udev rules for Index controllers and Vive trackers.
      # Base stations are not USB devices and need no udev rules.
      hardware.steam-hardware.enable = true;

      services.wivrn = {
        enable = true;
        # Default is off; without this the server never launches on its own.
        autoStart = true;
        # Whitelists xrizer/OpenComposite in openvrpaths.vrpath and lets
        # Steam's sandboxed pressure-vessel runtime discover the WiVRn
        # OpenXR runtime (PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES).
        steam.enable = true;
        steam.importOXRRuntimes = true;

        config.enable = true;
        config.json = {
          # nixpkgs' wivrn is built with WIVRN_FEATURE_STEAMVR_LIGHTHOUSE,
          # so this loads the lighthouse driver for the Index base stations,
          # controllers, and Vive trackers alongside the headset's own
          # tracking origin. The two origins are then aligned at runtime
          # with motoc (WiVRn's equivalent of OpenVR Space Calibrator).
          "use-steamvr-lh" = true;
          "codec" = "h265";
        };
      };

      environment.systemPackages = with pkgs; [
        android-tools
        motoc
        wivrnUsbConnect
        # WiVRn only speaks OpenXR; OpenVR-only titles need one of these to
        # translate. Docs don't pick a winner between them, so keep both.
        xrizer
        opencomposite
      ];
    };
}
