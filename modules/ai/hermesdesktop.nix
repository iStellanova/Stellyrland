_: {
  flake-file.inputs.hermes-agent = {
    url = "github:NousResearch/hermes-agent";
  };

  flake.modules.nixos.hermes-desktop =
    { lib, host, ... }:
    {
      imports = lib.optional (host.persistence or false) {
        preservation.preserveAt."/persist".users.${host.username}.directories = [
          ".hermes"
        ];
      };
    };

  flake.modules.darwin.hermes-desktop = {
    nix.settings = {
      substituters = [ "https://hermes-agent.cachix.org" ];
      trusted-public-keys = [
        "hermes-agent.cachix.org-1:jN3pjR50Mxi4SESKC/FIMNM6/LCosvPk2VUwzVvebzU="
      ];
    };
  };

  flake.modules.homeManager.hermes-desktop =
    {
      inputs,
      pkgs,
      ...
    }:
    let
      hermesPackage = inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default;
      hermesPackageWithDesktop =
        if pkgs.stdenv.hostPlatform.isDarwin then
          let
            # TODO(hermes-agent): remove when upstream refreshes the Electron header hash.
            patchedHermesSource = pkgs.runCommand "hermes-agent-patched-source" { } ''
              cp -r ${inputs.hermes-agent} "$out"
              substituteInPlace "$out/nix/desktop.nix" --replace-fail 'sha256-f8bSbLRmtbP93CJAvEBs+sHWDZ1xP2bcpLhC1EnOmZU=' 'sha256-CyzcARd1+GhWr8ED7HBYW2MYD+tgetqZFMkaivaGvw0='
            '';
            hermesDesktop = pkgs.callPackage "${patchedHermesSource}/nix/desktop.nix" {
              hermesAgent = hermesPackage;
              inherit (hermesPackage) hermesNpmLib;
            };
          in
          hermesPackage.overrideAttrs (old: {
            passthru = (old.passthru or { }) // {
              inherit hermesDesktop;
            };
          })
        else
          hermesPackage;
    in
    {
      imports = [ inputs.hermes-agent.homeManagerModules.default ];
      programs.hermes-agent = {
        enable = true;
        package = hermesPackageWithDesktop;
        desktop.enable = true;
      };
    };
}
