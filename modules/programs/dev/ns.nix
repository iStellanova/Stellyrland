{
  lib,
  ...
}: {
  config = {
    # Home Manager Nix Search script Settings
    flake.modules.homeManager.default = {
      osConfig,
      pkgs,
      ...
    }:
      lib.mkIf (osConfig ? aspects.programs.ns && osConfig.aspects.programs.ns.enable) {
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
    flake.modules.nixos.default = {
      lib,
      ...
    }: {
      options.aspects.programs.ns.enable = lib.mkEnableOption "Nix Search script";
    };

    # Darwin Options Declaration
    flake.modules.darwin.default = {
      lib,
      ...
    }: {
      options.aspects.programs.ns.enable = lib.mkEnableOption "Nix Search script";
    };
  };
}
