{sn, ...}: {
  sn.productivity = {includes = [sn.planify];};

  # No darwin stanza: Planify is GTK/GNOME-only. Mac task management is
  # handled by a separate app outside this config.
  sn.planify.nixos = {pkgs, ...}: {
    environment.systemPackages = [pkgs.planify];
  };
}
