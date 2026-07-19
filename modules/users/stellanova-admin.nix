# Reusable remote-admin aspect for hosts stellanova doesn't own/use as a
# desktop (e.g. onitop). Distinct from modules/users/stellanova.nix, which is
# the full desktop-user factory profile for her own hosts. Key-only login, no
# password set at all, passwordless elevation scoped to just this account —
# nothing of hers beyond a public key ever needs to land on a host she
# doesn't control.
{ self, ... }: {
  flake.modules.nixos.stellanova-admin = { pkgs, ... }: {
    users.users.stellanova = {
      isNormalUser = true;
      home = "/home/stellanova";
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = self.constants.sshKeys;
    };

    # Same CLI tooling bundle as oni's profile (modules/hosts/onitop/users/oni.nix) —
    # p10k, fastfetch, kitty, btop, etc. No desktop-specific pieces since this
    # account never runs a graphical session.
    #
    # system-cli's zsh aspect configures oh-my-zsh/plugins/p10k but never sets
    # programs.zsh.enable itself — for oni that flag comes from
    # modules/users/oni.nix's own per-user homeManager profile, which this
    # account deliberately doesn't import (it ties home.homeDirectory to
    # host.homeDir, which on onitop resolves to oni's home, not hers). Set it
    # directly here instead.
    home-manager.users.stellanova = {
      programs.zsh.enable = true;
      imports = with self.modules.homeManager; [
        system-cli
      ];
    };

    # core.nix replaces sudo with systemd's run0, which authorizes via
    # polkit rather than sudoers — a security.sudo.extraRules NOPASSWD entry
    # would be silently inert here. Grant passwordless run0 elevation
    # directly via the polkit action run0 actually checks.
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (subject.user == "stellanova" && action.id == "org.freedesktop.systemd1.manage-units") {
          return polkit.Result.YES;
        }
      });
    '';
  };
}
