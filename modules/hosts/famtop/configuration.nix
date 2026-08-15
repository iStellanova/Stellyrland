{ self, ... }: {
  flake.hosts.famtop = {
    class = "nixos";
    # user1's real name lives only in the git-crypt encrypted _identity.nix —
    # same role tan13 plays on plasmapulsefinale: real daily user, admin on

    username = "user1";
    homeDir = "/home/user1";
    flakePath = "/home/user1/Projects/stellyrland";
    passwordSecret = "user1psswd";

  };

  flake.modules.nixos.famtop = {
    imports = with self.modules.nixos; [
      # Base
      base
      cmdline

      # Desktop-Adjacent
      services-base
      system-tools
      xdg

      # Desktop
      gnome
      flatpak
      fonts
      pipewire
      librewolf
      media

      # Apple Silicon hardware/kernel/bootloader
      asahi

      # Real name for user1 (git-crypt encrypted, see .gitattributes). The
      # underscore prefix means import-tree won't auto-load it, hence the
      # explicit import here.
      ./_identity.nix

      # Host Specific Config
      famtop-host
    ];
  };
}
