{ sn, ... }: {
  sn.dev = {
    includes = [ sn.ns ];
  };

  sn.ns.homeManager = { pkgs, ... }: {
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
}
