{
  inputs,
  self,
  lib,
  ...
}:
let
  mkSystem = class: systemFn: system: name: {
    ${name} = systemFn {
      specialArgs = {
        inherit inputs;
        host = (self.constants or { }) // self.hosts.${name} // { inherit name; };
      };
      modules = [
        inputs.self.modules.${class}.${name}
        { nixpkgs.hostPlatform = lib.mkDefault system; }
      ];
    };
  };
in
{
  flake.lib = {
    mkNixos = mkSystem "nixos" inputs.nixpkgs.lib.nixosSystem;
    mkDarwin = mkSystem "darwin" inputs.darwin.lib.darwinSystem;
  };
}
