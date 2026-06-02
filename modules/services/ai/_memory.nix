{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.ai;
in {
  # Qdrant — vector store for Letta archival memory
  services.qdrant = {
    enable = true;
    settings.service = {
      host = "127.0.0.1";
      http_port = cfg.qdrant.port;
      grpc_port = cfg.qdrant.port + 1;
    };
  };

  # PostgreSQL — Letta recall memory (letta DB) and pgvector extension
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16.withPackages (ps: [ps.pgvector]);
    settings.listen_addresses = "localhost";
    ensureDatabases = [cfg.postgresql.databaseName "letta"];
    ensureUsers = [
      {
        name = cfg.user;
        ensureDBOwnership = false;
      }
    ];
    authentication = ''
      local all all trust
      host all all 127.0.0.1/32 trust
      host all all ::1/128 trust
    '';
  };

  systemd.services.ai-db-init = {
    description = "Initialize AI Behavioral Schema";
    after = ["postgresql.service"];
    requires = ["postgresql.service"];
    wantedBy =
      if cfg.onDemand
      then []
      else ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
      ExecStart = pkgs.writeShellScript "ai-db-init" ''
        PSQL="${pkgs.postgresql_16}/bin/psql -d ${cfg.postgresql.databaseName}"
        $PSQL -c "ALTER DATABASE ${cfg.postgresql.databaseName} OWNER TO ${cfg.user};"
        # Letta uses its own database — grant full access and install pgvector
        ${pkgs.postgresql_16}/bin/psql -d letta -c "ALTER DATABASE letta OWNER TO ${cfg.user};"
        ${pkgs.postgresql_16}/bin/psql -d letta -c "GRANT ALL ON SCHEMA public TO ${cfg.user};"
        ${pkgs.postgresql_16}/bin/psql -d letta -c "CREATE EXTENSION IF NOT EXISTS vector;"
        $PSQL -c "
          CREATE EXTENSION IF NOT EXISTS vector;
          GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ${cfg.user};
          GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO ${cfg.user};
        "
      '';
      RemainAfterExit = true;
    };
  };

  systemd.services.qdrant.wantedBy = lib.mkIf cfg.onDemand (lib.mkForce []);
  systemd.services.postgresql.wantedBy = lib.mkIf cfg.onDemand (lib.mkForce []);
}
