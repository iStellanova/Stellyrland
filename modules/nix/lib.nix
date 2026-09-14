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
        host = self.hosts.${name} // {
          inherit name;
        };
      };
      modules = [
        self.modules.${class}.${name}
        { nixpkgs.hostPlatform = lib.mkDefault system; }
      ];
    };
  };
in
{
  lib = {
    mkNixos = mkSystem "nixos" inputs.nixpkgs.lib.nixosSystem;
    mkDarwin = mkSystem "darwin" inputs.darwin.lib.darwinSystem;
  };
}
