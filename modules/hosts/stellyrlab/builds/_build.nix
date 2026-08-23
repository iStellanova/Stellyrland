{
  host,
  pkgs,
  lib,
  stateDir,
}:
pkgs.writeShellScript "nix-fleet-build" ''
  set -euo pipefail
  state_dir=${lib.escapeShellArg stateDir}
  run_dir=$(${pkgs.coreutils}/bin/mktemp -d)
  trap '${pkgs.coreutils}/bin/rm -rf "''${run_dir}"' EXIT
  ${pkgs.coreutils}/bin/mkdir -p "$state_dir"

  if [ -e "$state_dir/lock.json" ]; then
    ${pkgs.coreutils}/bin/cp "$state_dir/lock.json" "$run_dir/previous-lock.json"
  fi
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
