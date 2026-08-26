{
  inputs,
  config,
  lib,
  ...
}:
let
  attrsOf =
    type:
    lib.mkOption {
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
  mkFinix = system: name: {
    ${name} =
      let
        sources = import "${inputs.finix}/lon.nix";
        finixLib = import "${sources.nixpkgs}/lib";
        eval = finixLib.evalModules {
          class = "finix";
          specialArgs = {
            inherit inputs;
            modules = inputs.finix.nixosModules;
            host = (config.flake.constants or { }) // config.flake.hosts.${name} // { inherit name; };
          };
          modules = [
            inputs.finix.nixosModules.default
            inputs.self.modules.finix.${name}
            {
              nixpkgs.pkgs = import sources.nixpkgs {
                inherit system;
                config.allowUnfree = true;
              };
            }
          ];
        };
      in
      eval // { inherit (eval._module.args) pkgs; };
  };
in
{
  options.flake = {
    darwinConfigurations = attrsOf lib.types.raw;
    finixConfigurations = attrsOf lib.types.raw;
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
    inherit mkFinix;
  };
}
