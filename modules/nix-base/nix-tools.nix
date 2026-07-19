_: {

  flake.modules.homeManager.nix-tools =
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
                if [[ -s "/run/secrets/github-token" ]]; then
                  export GITHUB_TOKEN="$(cat /run/secrets/github-token)"
                elif [[ -s "$HOME/.config/github-token" ]]; then
                  export GITHUB_TOKEN="$(cat "$HOME/.config/github-token")"
                fi

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

                notify_remote() {
          if [[ -z "$1" ]]; then
            echo "Usage: notify_remote <host> [title] [message]"
            return 1
          fi
          local target="$1"
          local title="''${2:-System Update}"
          local msg="''${3:-Done! Deployment finished successfully.}"
          ssh -n -o ConnectTimeout=4 "stellanova@$target" \
            "BUS=\$(sudo find /run/user -maxdepth 2 -name bus 2>/dev/null | grep -v \"/run/user/\$(id -u)/\" | head -n 1); \
             if [[ -z \"\$BUS\" ]]; then \
               BUS=\$(sudo find /run/user -maxdepth 2 -name bus 2>/dev/null | head -n 1); \
             fi; \
             if [[ -n \"\$BUS\" ]]; then \
               UID_VAL=\$(echo \"\$BUS\" | cut -d'/' -f4); \
               sudo systemd-run --quiet --uid=\"\$UID_VAL\" --setenv=DBUS_SESSION_BUS_ADDRESS=\"unix:path=\$BUS\" notify-send -i system-software-update \"$title\" \"$msg\" 2>/dev/null || true; \
             fi" 2>/dev/null || true
        }

                deploy() {
                  if [[ -z "$1" ]]; then
                    echo "Usage: deploy <host> [check|extra-args...]"
                    return 1
                  fi
                  local target="$1"
                  shift
                  if [[ "$1" == "check" ]]; then
                    shift
                    _nix_prep && nh os build "$FLAKE" -H "$target" --target-host "stellanova@$target" --diff always "$@" && rm -f ./result
                  else
                    if _nix_prep && nh os switch "$FLAKE" -H "$target" --target-host "stellanova@$target" "$@"; then
                      notify_remote "$target" "System Update" "Done! Deployment finished successfully."
                    fi
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
