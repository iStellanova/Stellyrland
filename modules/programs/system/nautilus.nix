_: {
  config = {
    flake.modules.nixos.nautilus = {
      config,
      lib,
      pkgs,
      ...
    }: {
      options.aspects.programs.nautilus.enable = lib.mkEnableOption "Nautilus file manager";

      config = lib.mkIf config.aspects.programs.nautilus.enable {
        environment.systemPackages = with pkgs; [
          nautilus
          sushi
        ];

        services.gnome.tinysparql.enable = true;
        services.gnome.localsearch.enable = true;
      };
    };
  };
}
