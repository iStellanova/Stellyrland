{

  flake.modules.homeManager.nix-tools =
    {
      host,
      ...
    }:
    {
      programs = {
        zsh = {
          shellAliases = {
            clean = "nh clean all --keep 20 --optimise";
            cdn = "cd $FLAKE";
          };

          initContent = ''
            if [[ -s "/run/secrets/github-token" ]]; then
              export GITHUB_TOKEN="$(cat /run/secrets/github-token)"
            elif [[ -s "$HOME/.config/github-token" ]]; then
              export GITHUB_TOKEN="$(cat "$HOME/.config/github-token")"
            fi
          '';

          # Use zsh sessionVariables (written into .zshrc) rather than
          # home.sessionVariables (written into ~/.profile, login shells only).
          sessionVariables = {
            FLAKE = host.flakePath;
            NH_FLAKE = host.flakePath;
          };
        };

        nh = {
          enable = true;
          clean = {
            enable = true;
            extraArgs = "--keep 20 --optimise";
          };
          flake = host.flakePath;
        };
      };
    };
}
