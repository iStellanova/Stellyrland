_: {
  system.stateVersion = 5;

  # Networking
  networking.computerName = "Stellyrtop";
  networking.hostName = "stellyrtop";
  networking.localHostName = "stellyrtop";

  # Enabled Aspects
  aspects = {
    darwin = {
      system.enable = true;
      homebrew.enable = true;
    };
    core = {
      enable = true;
      fonts.enable = true;
      nix-settings.enable = true;
      networking.enable = true;
    };
    programs = {
      aerospace.enable = true;
      aesthetic.enable = true;
      browser.enable = true;
      background-sounds.enable = true;
      maintenance.enable = true;
      finance.enable = true;
      school.enable = true;
      writing.enable = true;
      cloud-storage.enable = true;
      virtual-machines.enable = true;
      media.enable = true;
      media-editing.enable = true;
      btop.enable = true;
      cava.enable = true;
      cli.enable = true;
      fastfetch.enable = true;
      gaming.enable = true;
      git.enable = true;
      kitty.enable = true;
      nix-index.enable = true;
      ns.enable = true;
      yazi.enable = true;
      zsh.enable = true;
      nixvim.enable = true;
      ai-tools.enable = true;
      bitwarden.enable = true;
      discord-music-rpc.enable = true;
      ide-suite.enable = true;
      office-suite.enable = true;
      vesktop.enable = true;
      utils.enable = true;
      zed.enable = true;
    };
  };
}
