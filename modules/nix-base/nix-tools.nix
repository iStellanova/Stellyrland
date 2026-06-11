{sn, ...}: {
  sn.nix-base = {includes = [sn.nix-tools];};

  sn.nix-tools.homeManager = {
    host,
    pkgs,
    ...
  }: {
    programs.zsh.shellAliases = {
      clean = "nh clean all --keep 20";
      cdn = "cd $FLAKE";
      nixinfo = "nh os info";
      replace = "(cd $FLAKE && nix run .#write-flake)";
      nix-list = "nix profile list --profile ~/.local/state/nix/profiles/scratch";
      nix-clear = "rm -rf ~/.local/state/nix/profiles/scratch && nh clean all --keep 20";
    };

    programs.zsh.initContent = ''
      rebuild() {
        if [[ "$1" == "check" ]]; then
          (cd $FLAKE && nix run .#write-flake && nix fmt) && git -C $FLAKE add . && ${
        if pkgs.stdenv.isDarwin
        then "nh darwin build $FLAKE && rm ./result"
        else "nh os build --diff always && rm ./result"
      }
        else
          (cd $FLAKE && nix run .#write-flake && nix fmt) && git -C $FLAKE add . && ${
        if pkgs.stdenv.isDarwin
        then "nh darwin switch $FLAKE"
        else "nh os switch"
      }
        fi
      }

      upgrade() {
        if [[ "$1" == "check" ]]; then
          (cd $FLAKE && nix run .#write-flake && nix fmt) && git -C $FLAKE add . && ${
        if pkgs.stdenv.isDarwin
        then "nix flake update $FLAKE && nh darwin build $FLAKE && rm ./result"
        else "nh os build --update --diff always && rm ./result"
      }
        else
          (cd $FLAKE && nix run .#write-flake && nix fmt) && git -C $FLAKE add . && ${
        if pkgs.stdenv.isDarwin
        then "nh darwin switch --update $FLAKE"
        else "nh os switch --update"
      }
        fi
      }

      nix-add() { local profile="$HOME/.local/state/nix/profiles/scratch"; NIXPKGS_ALLOW_UNFREE=1 nix profile add --profile "$profile" --impure nixpkgs#$1; }
      nix-remove() {
        if [[ ! -d ~/.local/state/nix/profiles/scratch ]]; then echo "Scratch profile doesn't exist"; return 1; fi
        nix profile remove --profile ~/.local/state/nix/profiles/scratch $1
      }
    '';

    # FLAKE env var is set by each OS body pointing to the host-specific path.
    # nh.flake mirrors it so nh commands find the flake without a flag.
    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep 20 --optimise";
      flake = host.flakePath;
    };

    home.sessionVariables.FLAKE = host.flakePath;
  };
}
