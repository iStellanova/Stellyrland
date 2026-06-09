{inputs, ...}: {
  den.aspects.nix-software-center.homeManager = {pkgs, ...}: {
    home.packages = [
      inputs.nix-software-center.packages."${pkgs.stdenv.hostPlatform.system}".default
    ];
  };
}
