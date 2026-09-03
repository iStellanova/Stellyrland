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
    { inputs, ... }:
    {
      imports = [ inputs.hermes-agent.homeManagerModules.default ];
      programs.hermes-agent.desktop.enable = true;
    };
}
