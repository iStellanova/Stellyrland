{
  inputs,
  config,
  lib,
  ...
}:
let
  attrsOf = type: lib.mkOption {
    type = lib.types.lazyAttrsOf type;
    default = { };
  };
  mkSystem = class: systemFn: system: name: {
    ${name} = systemFn {
      specialArgs = {
        inherit inputs;
        host = (config.flake.constants or { }) // config.flake.hosts.${name} // { inherit name; };
      };
      modules = [
        inputs.self.modules.${class}.${name}
        { nixpkgs.hostPlatform = lib.mkDefault system; }
      ];
    };
  };
in
{
  options.flake = {
    darwinConfigurations = attrsOf lib.types.raw;
    hosts = attrsOf lib.types.raw;
    lib = attrsOf lib.types.raw;
    factory = lib.mkOption {
      type = lib.types.attrsOf lib.types.unspecified;
      default = { };
    };
  };

  config.flake.lib = {
    mkNixos = mkSystem "nixos" inputs.nixpkgs.lib.nixosSystem;
    mkDarwin = mkSystem "darwin" inputs.darwin.lib.darwinSystem;
  };
}
