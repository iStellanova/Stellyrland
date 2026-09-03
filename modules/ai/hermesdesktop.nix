_: {
  flake-file.inputs.hermes-agent = {
    url = "github:NousResearch/hermes-agent";
    inputs.nixpkgs.follows = "nixpkgs";
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

  flake.modules.homeManager.hermes-desktop =
    { inputs, ... }:
    {
      imports = [ inputs.hermes-agent.homeManagerModules.default ];
      programs.hermes-agent.desktop.enable = true;
    };
}
