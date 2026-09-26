{
  modules.nixos.backup-host =
    { lib, config, ... }:
    let
      cfg = config.backup.host;
    in
    {
      options.backup.host = {
        root = lib.mkOption {
          type = lib.types.str;
          default = "/srv/backups";
        };

        repositories = lib.mkOption {
          default = { };
          type = lib.types.attrsOf (
            lib.types.submodule {
              options = {
                authorizedKeys = lib.mkOption {
                  type = lib.types.listOf lib.types.str;
                  default = [ ];
                };
                authorizedKeysAppendOnly = lib.mkOption {
                  type = lib.types.listOf lib.types.str;
                  default = [ ];
                };
                quota = lib.mkOption {
                  type = lib.types.nullOr lib.types.str;
                  default = null;
                };
              };
            }
          );
        };
      };

      config.services.borgbackup.repos = lib.mapAttrs (name: repository: {
        path = "${cfg.root}/${name}";
        inherit (repository) authorizedKeys authorizedKeysAppendOnly quota;
      }) cfg.repositories;
    };
}
