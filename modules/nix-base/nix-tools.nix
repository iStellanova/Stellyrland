{ sn, ... }: {
  sn.nix-base = {
    includes = [ sn.nix-tools ];
  };

  sn.nix-tools.homeManager =
    {
      host,
      pkgs,
      ...
    }:
    {
      programs.zsh.shellAliases = {
        clean = "nh clean all --keep 20";
        cdn = "cd $FLAKE";
        nixinfo = "nh os info";
        replace = "(cd $FLAKE && nix run .#write-tack)";
        nix-list = "nix profile list --profile ~/.local/state/nix/profiles/scratch";
        nix-clear = "rm -rf ~/.local/state/nix/profiles/scratch && nh clean all --keep 20";
      };

      programs.zsh.initContent = ''
        export GITHUB_TOKEN="$(cat /run/secrets/github-token 2>/dev/null)"

        _nix_prep() {
          git -C "$FLAKE" add . && (cd "$FLAKE" && nix fmt) && git -C "$FLAKE" add .
        }

        rebuild() {
          if [[ "$1" == "check" ]]; then
            _nix_prep && ${
              if pkgs.stdenv.isDarwin then
                "nh darwin build $FLAKE && rm -f ./result"
              else
                "nh os build $FLAKE --diff always && rm -f ./result"
            }
          else
            _nix_prep && ${
              if pkgs.stdenv.isDarwin then "nh darwin switch $FLAKE" else "nh os switch $FLAKE"
            }
          fi
        }

        upgrade() {
          if [[ "$1" == "check" ]]; then
            (cd "$FLAKE" && nix run .#write-tack) && _nix_prep && ${
              if pkgs.stdenv.isDarwin then
                "nh darwin build $FLAKE && rm -f ./result"
              else
                "nh os build $FLAKE --diff always && rm -f ./result"
            }
          else
            (cd "$FLAKE" && nix run .#write-tack) && _nix_prep && ${
              if pkgs.stdenv.isDarwin then "nh darwin switch $FLAKE" else "nh os switch $FLAKE"
            }
          fi
        }

        nix-add() { local profile="$HOME/.local/state/nix/profiles/scratch"; NIXPKGS_ALLOW_UNFREE=1 nix profile add --profile "$profile" --impure nixpkgs#$1; }
        nix-remove() {
          if [[ ! -d ~/.local/state/nix/profiles/scratch ]]; then echo "Scratch profile doesn't exist"; return 1; fi
          nix profile remove --profile ~/.local/state/nix/profiles/scratch $1
        }
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
