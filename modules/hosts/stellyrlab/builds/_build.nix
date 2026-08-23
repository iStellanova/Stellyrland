{
  host,
  pkgs,
  lib,
  nix,
  git,
  stateDir,
}:
pkgs.writeShellScript "nix-fleet-build" ''
  set -euo pipefail
  flake=${lib.escapeShellArg host.flakePath}
  state_dir=${lib.escapeShellArg stateDir}
  run_dir=$(${pkgs.coreutils}/bin/mktemp -d)
  trap '${pkgs.coreutils}/bin/rm -rf "''${run_dir}"' EXIT

  if [ "$(${git} -C "$flake" branch --show-current)" != main ] || [ -n "$(${git} -C "$flake" status --porcelain)" ]; then
    printf '%s\n' 'Skipped fleet build: checkout must be clean on main.' >&2
    exit 1
  fi

  ${pkgs.coreutils}/bin/mkdir -p "$state_dir"

  if [ -e "$state_dir/lock.json" ]; then
    ${pkgs.coreutils}/bin/cp "$state_dir/lock.json" "$run_dir/previous-lock.json"
  fi

  if [ -r /run/secrets/github-token ]; then
    export GITHUB_TOKEN="$(${pkgs.coreutils}/bin/cat /run/secrets/github-token)"
  fi
  cd "$flake"
  ${nix} flake update

  ${pkgs.coreutils}/bin/cp ${lib.escapeShellArg "${host.flakePath}/flake.lock"} "$run_dir/lock.json"

  ${pkgs.nix-fast-build}/bin/nix-fast-build \
    --flake ${lib.escapeShellArg "${host.flakePath}#nixosConfigurations"} \
    --systems x86_64-linux \
    --no-link \
    --result-file "$run_dir/results.json" \
    --select 'configs: builtins.mapAttrs (name: config: config.config.system.build.toplevel) configs'

  ${pkgs.coreutils}/bin/cp "$run_dir/results.json" "$state_dir/results.json"
  ${pkgs.coreutils}/bin/cp "$run_dir/lock.json" "$state_dir/lock.json"
  if [ -e "$run_dir/previous-lock.json" ]; then
    ${pkgs.coreutils}/bin/cp "$run_dir/previous-lock.json" "$state_dir/previous-lock.json"
  else
    ${pkgs.coreutils}/bin/rm -f "$state_dir/previous-lock.json"
  fi
''
