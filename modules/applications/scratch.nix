{ inputs, ... }:
{
  pins.nix-flatpak.url = "https://github.com/gmodena/nix-flatpak";

  modules.nixos.scratch = {
    imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];
    services.flatpak = {
      enable = true;
      update.onActivation = true;
      packages = [ "edu.mit.Scratch" ];
    };
  };

  modules.darwin.scratch = {
    homebrew.casks = [ "scratch" ];
  };
}