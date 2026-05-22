{
  config,
  lib,
  pkgs,
  identity,
  isDarwin,
  ...
}: {
  options.aspects.programs.ai-tools.enable = lib.mkEnableOption "AI Agent Tools";

  config = lib.mkIf config.aspects.programs.ai-tools.enable (lib.mkMerge [
    {
      home-manager.users.${identity.name} = {
        # Prefer claude, but if claude has an outage, gemini is the backup.
        home.packages = with pkgs; [
          claude-code
          gemini-cli
        ];
      };
    }

    (lib.optionalAttrs isDarwin {
      homebrew.casks = ["claude"];
    })
  ]);
}
