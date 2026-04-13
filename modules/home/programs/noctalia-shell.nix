{ inputs, pkgs, ... }:

{
  imports = [
    inputs.noctalia-shell.homeModules.default
  ];

  # These dependencies are still needed for the nix-monitor plugin
  home.packages = with pkgs; [
    nh
    jq
    curl
  ];

  programs.noctalia-shell = {
    enable = true;
    systemd.enable = true;
    # settings = { ... }; // Removed to allow local management
  };

  # Link ONLY the nixos-monitor plugin so it is available to Noctalia.
  # We use force = true to ensure it overwrites any existing local version
  # with the one from the flake.
  xdg.configFile."noctalia/plugins/nixos-monitor" = {
    source = inputs.noctalia-nix-monitor;
    force = true;
  };

  # Note: All other files (settings.json, plugins.json, colors.json, templates/)
  # are no longer managed by Nix/Home Manager and can be managed by Noctalia locally.
}
