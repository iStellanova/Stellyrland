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
    let
      rpcBridge = pkgs.stdenvNoCC.mkDerivation {
        pname = "rpc-bridge";
        version = "1.4.1.3";
        src = pkgs.fetchurl {
          url = "https://github.com/enderice2/rpc-bridge/releases/download/v1.4.1.3/bridge.zip";
          hash = "sha256-LjSLhRtUqZtuBiKJvbH1vEyG78se8rPnSO4p8P3RQ+c=";
        };
        nativeBuildInputs = [ pkgs.unzip ];
        dontUnpack = true;
        dontBuild = true;
        installPhase = ''
          mkdir source
          unzip "$src" -d source
          install -Dm755 source/bridge.exe $out/bin/bridge.exe
          install -Dm755 source/bridge.sh $out/bin/bridge.sh
        '';
        meta = {
          description = "Discord Rich Presence bridge for Wine and Proton";
          homepage = "https://github.com/EnderIce2/rpc-bridge";
          license = lib.licenses.mit;
          platforms = [ "x86_64-linux" ];
        };
      };
    in
    {
      environment.systemPackages = with pkgs; [
        prismlauncher
        r2modman
      ] ++ lib.optional (pkgs.stdenv.hostPlatform.system == "x86_64-linux") rpcBridge;

      imports = lib.optional (host.persistence or false) {
        preservation.preserveAt."/persist".users.${host.username}.directories = [
          ".local/share/Paradox Interactive"
          ".local/share/PrismLauncher"
          ".local/share/r2modman"
          ".config/r2modman"
          ".config/r2modmanPlus-local"
        ];
      };
    };

  flake.modules.darwin.game-launchers = osShared;
}
