{
  inputs,
  config,
  lib,
  ...
}:
{
  config.flake.lib = {
    mkNixos = system: name: {
      ${name} = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          host = config.flake.hosts.${name} // (config.flake.constants or { }) // { inherit name; };
        };
        modules = [
          inputs.self.modules.nixos.${name}
          { nixpkgs.hostPlatform = lib.mkDefault system; }
        ];
      };
    };

    mkDarwin = system: name: {
      ${name} = inputs.darwin.lib.darwinSystem {
        specialArgs = {
          inherit inputs;
          host = config.flake.hosts.${name} // (config.flake.constants or { }) // { inherit name; };
        };
        modules = [
          inputs.self.modules.darwin.${name}
          { nixpkgs.hostPlatform = lib.mkDefault system; }
        ];
      };
    };
  };

}
