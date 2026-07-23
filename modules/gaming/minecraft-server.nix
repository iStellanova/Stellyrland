# Stellacraft — Paper 1.21.8 Minecraft server, tunneled through playit.gg
{ inputs, ... }:
{
  flake-file.inputs.nix-minecraft = {
    url = "github:Infinidoge/nix-minecraft";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake-file.inputs.playit-nixos-module = {
    url = "github:pedorich-n/playit-nixos-module";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.minecraft-server =
    { config, pkgs, ... }:
    {
      imports = [
        inputs.nix-minecraft.nixosModules.minecraft-servers
        inputs.playit-nixos-module.nixosModules.default
      ];
      nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];
      users.users.minecraft.uid = 996;
      users.groups.minecraft.gid = 994;

      services.minecraft-servers = {
        enable = true;
        eula = true;
        openFirewall = false; # ingress is via playit.gg's outbound tunnel, nothing needs to listen publicly
        managementSystem = {
          tmux.enable = false;
          systemd-socket.enable = true;
        };

        servers.stellacraft = {
          enable = true;
          package = pkgs.paperServers.paper-1_21_8;

          # Aikar's flags — standard G1GC tuning for Paper. https://docs.papermc.io/paper/aikars-flags
          jvmOpts = [
            "-Xmx6G"
            "-Xms6G"
            "-XX:+UseG1GC"
            "-XX:+ParallelRefProcEnabled"
            "-XX:MaxGCPauseMillis=200"
            "-XX:+UnlockExperimentalVMOptions"
            "-XX:+DisableExplicitGC"
            "-XX:+AlwaysPreTouch"
            "-XX:G1NewSizePercent=30"
            "-XX:G1MaxNewSizePercent=40"
            "-XX:G1HeapRegionSize=8M"
            "-XX:G1ReservePercent=20"
            "-XX:G1HeapWastePercent=5"
            "-XX:G1MixedGCCountTarget=4"
            "-XX:InitiatingHeapOccupancyPercent=15"
            "-XX:G1MixedGCLiveThresholdPercent=90"
            "-XX:G1RSetUpdatingPauseTimePercent=5"
            "-XX:SurvivorRatio=32"
            "-XX:+PerfDisableSharedMem"
            "-XX:MaxTenuringThreshold=1"
            "-Dusing.aikars.flags=https://mcflags.emc.gs"
            "-Dio.netty.tryReflectionSetAccessible=true"
          ];

          serverProperties = {
            accepts-transfers = false;
            allow-flight = false;
            allow-nether = true;
            broadcast-console-to-ops = true;
            broadcast-rcon-to-ops = true;
            bug-report-link = "";
            debug = false;
            difficulty = "hard";
            enable-command-block = false;
            enable-jmx-monitoring = false;
            enable-query = false;
            enable-rcon = false;
            enable-status = true;
            enforce-secure-profile = false;
            enforce-whitelist = true;
            entity-broadcast-range-percentage = 100;
            force-gamemode = false;
            function-permission-level = 2;
            gamemode = "survival";
            generate-structures = true;
            generator-settings = "{}";
            hardcore = false;
            hide-online-players = false;
            initial-disabled-packs = "";
            initial-enabled-packs = "vanilla";
            level-name = "world";
            level-seed = "";
            level-type = "minecraft:normal";
            log-ips = true;
            max-chained-neighbor-updates = 1000000;
            max-players = 20;
            max-tick-time = 60000;
            max-world-size = 29999984;
            motd = "Stellaplex";
            network-compression-threshold = 256;
            online-mode = true;
            op-permission-level = 4;
            pause-when-empty-seconds = -1;
            player-idle-timeout = 0;
            prevent-proxy-connections = false;
            pvp = true;
            "query.port" = 9035;
            rate-limit = 0;
            region-file-compression = "deflate";
            require-resource-pack = false;
            resource-pack = "";
            resource-pack-id = "";
            resource-pack-prompt = "";
            resource-pack-sha1 = "";
            "rcon.password" = "";
            "rcon.port" = 25575;
            server-ip = "";
            server-port = 9035;
            simulation-distance = 10;
            spawn-animals = true;
            spawn-monsters = true;
            spawn-npcs = true;
            spawn-protection = 0;
            sync-chunk-writes = true;
            text-filtering-config = "";
            text-filtering-version = 0;
            use-native-transport = true;
            view-distance = 10;
            white-list = true;
          };

          whitelist = {
            Sofuretu = "4b8b1b9c-0b48-4938-b124-7b7aca28d5bc";
            R4kshasa = "ce6e0bcf-86dc-4cad-a545-9045593c44db";
            Charles_Edith = "58ef941c-6ba9-49ae-a33f-a1cdcac0d186";
            Critical_Byte = "4044ba40-f064-4820-bfa8-e4f8f46801d7";
            Bribed_Officer = "98c6d18f-7fb9-47a2-822c-b68f60a0ec08";
            Souperchicken06 = "95e94710-7014-41cd-a780-be740a50aaaa";
            Jeweledbutton = "c2771511-d415-4baf-8560-b74716b33b06";
            atlaszoidac = "2accc9b1-bca3-45ee-b773-8a63c83e69e2";
            iFazwolf = "92dbab14-8637-45af-9adc-36aca319e1a2";
            CaffeineDrinker = "d36ed0bb-3620-459e-83f0-e9aef3999197";
            ".iFazwolf" = "00000000-0000-0000-0009-01f552b0e5a6";
          };
          operators = {
            iFazwolf = "92dbab14-8637-45af-9adc-36aca319e1a2";
          };

          # Plugin jars
          symlinks = {
            "plugins/Backuper-3.4.5.jar" = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/7cMAqMND/versions/ej6KCtki/Backuper-3.4.5.jar";
              sha256 = "19pbfwjmbrzk9j4z16nxirphk9f7vb0kcdxqpsxmc1yvkfzm6bk6";
            };
            "plugins/Chunky-Bukkit-1.4.40.jar" = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/fALzjamp/versions/P3y2MXnd/Chunky-Bukkit-1.4.40.jar";
              sha256 = "08cpq11i83rc949b33dj4dvf2dmqpr6y676ybbhi447ph3y7fm1a";
            };
            "plugins/minimotd-paper-2.2.1.jar" = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/16vhQOQN/versions/3cAWtXZF/minimotd-paper-2.2.1.jar";
              sha256 = "10s4m56spxhn9i2jq8vw7al72pq8ij63i8fgxlx9v0faqk3l0qdz";
            };
            "plugins/tabtps-paper-1.3.29.jar" = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/cUhi3iB2/versions/OW7YKtaI/tabtps-paper-1.3.29.jar";
              sha256 = "1l6wm60h2yr1n2al11ip4zpa2lm4qy92n6959n1s8cvz9bqpgap5";
            };
            "plugins/veinminer-paper-2.5.1.jar" = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/OhduvhIc/versions/qO1MV511/veinminer-paper-2.5.1.jar";
              sha256 = "03ahs6g79j35ljk85c6zlmpsd0k97pc5xbyd182dr5mqp94xdpgb";
            };
            # Filename says 2.3.0 but the jar's actual fabric.mod.json reports 2.5.0 — the
            # file was updated in place upstream without a rename.
            "plugins/veinminer-enchant-2.3.0.jar" = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/4sP0LXxp/versions/h5oKcjvq/veinminer-enchant-2.3.0.jar";
              sha256 = "057zljji9nl8h88ypi5x56m4ra11ylx2xgid6f48yz37iyqsgw9n";
            };
            "plugins/voicechat-bukkit-2.6.6.jar" = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/9eGKb6K1/versions/ps3C3lpD/voicechat-bukkit-2.6.6.jar";
              sha256 = "0d9dfm7aivwy8bj2sni6mbxdqmyg0931n80kv9jylw838mh4m2p4";
            };
            # GeyserMC's own build archive
            "plugins/Geyser-Spigot.jar" = pkgs.fetchurl {
              url = "https://download.geysermc.org/v2/projects/geyser/versions/2.9.0/builds/971/downloads/spigot";
              sha256 = "06gv768n94bvv31h5bdr73c670v2fr9z8wc17fly46xwzxpqw654";
            };
            "plugins/floodgate-spigot.jar" = pkgs.fetchurl {
              url = "https://download.geysermc.org/v2/projects/floodgate/versions/2.2.5/builds/121/downloads/spigot";
              sha256 = "1dhfh42rx9pc407kfjs8xa3ajh03p9132vyiyp6awbrnkc3pg4vk";
            };
            "plugins/forcexaerofairplay-2.2.0.jar" = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/CI6phJXg/versions/5KW0E3uO/forcexaerofairplay-2.2.0.jar";
              sha256 = "1inyn3j7i8sdsyagf7hygd56gar7q2pnisyazwcjc35wj1r76sqc";
            };
            "plugins/namecolor-bukkit-1.11.jar" = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/fDTjzia9/versions/HecwZPmW/namecolor-bukkit-1.11.jar";
              sha256 = "0hmfbn8yrd00l2nxibq083w7hj0nv6srzvaa1c91zv1wi98jp4gv";
            };
            "plugins/TAB v5.3.2.jar" = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/gG7VFbG0/versions/njaHNTiW/TAB%20v5.3.2.jar";
              sha256 = "0lg2izr2h6225v9dakqh17kqm06kkyqnz8jclrqi55q9wwn1x019";
            };
            "plugins/ViaVersion-5.5.2-SNAPSHOT.jar" = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/P1OZGk5p/versions/b7fitAW8/ViaVersion-5.5.2-SNAPSHOT.jar";
              sha256 = "1krik7yv3prix69af82z2a8qsfm76174hmxah7cwncszyaaibwdk";
            };
          };

          # World saves, datapacks, and the Paper/Bukkit yaml configs are plain files under datadir.
        };
      };
      sops.secrets.playit-secret-key = { };
      sops.templates.playit-secret.content = ''
        secret_key = "${config.sops.placeholder.playit-secret-key}"
      '';

      services.playit = {
        enable = true;
        secretPath = config.sops.templates.playit-secret.path;
      };
      systemd.services.playit.after = [ "minecraft-server-stellacraft.service" ];
    };
}
