_: {
  # Home Manager Nix Search script Settings
  flake.modules.homeManager.ns = {pkgs, ...}: {
    home.packages = [
      (pkgs.writeShellApplication {
        name = "ns";
        runtimeInputs = with pkgs; [
          fzf
          nix-search-tv
          xdg-utils
        ];
        text = builtins.readFile "${pkgs.nix-search-tv.src}/nixpkgs.sh";
      })
    ];
  };

  # NixOS Options Declaration
  flake.modules.nixos.ns = _: {
  };

  # Darwin Options Declaration
  flake.modules.darwin.ns = _: {
  };
}
