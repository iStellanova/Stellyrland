{ inputs, lib, ... }:
{
  flake-file.inputs.deploy-rs = {
    url = "github:serokell/deploy-rs";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.deploy.nodes.stellyrland = {
    hostname = "deploy-stellyrland";
    sshUser = "stellanova";
    user = "root";
    interactiveSudo = true;
    profiles.system.path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.stellyrland;
  };

  perSystem =
    { system, ... }:
    lib.optionalAttrs (system == "x86_64-linux") {
      packages.deploy-rs = inputs.deploy-rs.packages.${system}.default;
      checks = inputs.deploy-rs.lib.${system}.deployChecks inputs.self.deploy;
    };
}
