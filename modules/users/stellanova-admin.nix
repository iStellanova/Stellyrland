# Reusable remote-admin aspect for hosts stellanova doesn't own (e.g. plasmapulsefinale).
# Key-only login, no password, elevation scoped to just this account.
{ self, ... }: {
  flake.modules.nixos.stellanova-admin = { pkgs, ... }: {
    users.users.stellanova = {
      isNormalUser = true;
      home = "/home/stellanova";
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = self.constants.sshKeys;
    };

    # cmdline's zsh aspect never sets programs.zsh.enable itself — usually
    # inherited from modules/users/<name>.nix, which we skip here since it'd
    # tie home.homeDirectory to host.homeDir (tan13's, not hers).
    home-manager.users.stellanova = {
      programs.zsh.enable = true;
      imports = with self.modules.homeManager; [
        base
        cmdline
      ];
    };

    # core.nix replaces sudo with run0 (polkit-based) — a sudo NOPASSWD rule
    # would be inert here, so grant elevation via the polkit action instead.
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (subject.user == "stellanova" && action.id == "org.freedesktop.systemd1.manage-units") {
          return polkit.Result.YES;
        }
      });
    '';
  };
}
