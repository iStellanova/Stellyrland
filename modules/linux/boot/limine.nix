{
  flake.modules.finix.limine = { modules, ... }: {
    imports = [ modules.limine ];

    boot.loader.efi.canTouchEfiVariables = true;
    programs.limine = {
      enable = true;
      maxGenerations = 15;
      secureBoot.enable = true;
    };
  };
}
