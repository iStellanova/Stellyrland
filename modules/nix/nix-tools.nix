{

  flake.modules.homeManager.nix-tools =
    {
      host,
      ...
    }:
    {
      programs.zsh.shellAliases = {
        clean = "nh clean all --keep 20 --optimise";
        cdn = "cd $FLAKE";
        replace = "(cd $FLAKE && nix run .#write-tack)";
      };

      programs.zsh.initContent = ''
        if [[ -s "/run/secrets/github-token" ]]; then
          export GITHUB_TOKEN="$(cat /run/secrets/github-token)"
        elif [[ -s "$HOME/.config/github-token" ]]; then
          export GITHUB_TOKEN="$(cat "$HOME/.config/github-token")"
        fi
      '';

      programs.nh = {
        enable = true;
        clean.enable = true;
        clean.extraArgs = "--keep 20 --optimise";
        flake = host.flakePath;
      };

      # Use zsh sessionVariables (written into .zshrc) rather than
      # home.sessionVariables (written into ~/.profile, login shells only).
      programs.zsh.sessionVariables = {
        FLAKE = host.flakePath;
        NH_FLAKE = host.flakePath;
      };
    };
}
