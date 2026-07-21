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
          # constants first so a host's own fields (e.g. sshKeys) can actually
          # override the shared default instead of being clobbered by it.
          host = (config.flake.constants or { }) // config.flake.hosts.${name} // { inherit name; };
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
          host = (config.flake.constants or { }) // config.flake.hosts.${name} // { inherit name; };
        };
        modules = [
          inputs.self.modules.darwin.${name}
          { nixpkgs.hostPlatform = lib.mkDefault system; }
        ];
      };
    };
  };

}
