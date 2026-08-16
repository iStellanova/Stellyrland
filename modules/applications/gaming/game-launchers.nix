_:
let
  osShared = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      prismlauncher
    ];
  };
in
{
  flake.modules.nixos.game-launchers =
    {
      lib,
      host,
      pkgs,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        prismlauncher
        r2modman
      ];

      imports = lib.optional (host.persistence or false) {
        preservation.preserveAt."/persist".users.${host.username}.directories = [
          ".local/share/Paradox Interactive"
          ".local/share/PrismLauncher"
          ".local/share/r2modman"
          ".config/r2modman"
        ];
      };
    };

  flake.modules.darwin.game-launchers = osShared;
}
