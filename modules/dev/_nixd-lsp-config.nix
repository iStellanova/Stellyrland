host: {
  nixpkgs.expr = "import (builtins.getFlake \"${host.flakePath}\").inputs.nixpkgs {}";
  options =
    if host.class == "nixos" then
      {
        nixos.expr = "(builtins.getFlake \"${host.flakePath}\").nixosConfigurations.${host.name}.options";
      }
    else
      {
        darwin.expr = "(builtins.getFlake \"${host.flakePath}\").darwinConfigurations.${host.name}.options";
      };
}
