_: {
  # No darwin stanza: Planify is GTK/GNOME-only. Mac task management is
  # handled by a separate app outside this config.
  flake.modules.nixos.planify = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.planify ];
  };
}
