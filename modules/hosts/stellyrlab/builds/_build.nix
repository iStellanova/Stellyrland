{
  host,
  pkgs,
  lib,
  nix,
  git,
  flock,
  stateDir,
}:
pkgs.writeShellScript "nix-fleet-build" ''
  set -euo pipefail
  state_dir=${lib.escapeShellArg stateDir}
  if [ "''${FLEET_BUILD_LOCK_HELD:-}" != 1 ]; then
    ${pkgs.coreutils}/bin/mkdir -p "$state_dir"
    exec ${flock} -n "$state_dir/build.lock" env FLEET_BUILD_LOCK_HELD=1 "$0" "$@"
  fi

  checkout=${lib.escapeShellArg host.flakePath}
  run_dir=$(${pkgs.coreutils}/bin/mktemp -d)
  source_dir=
  cleanup() {
    cd /
    if [ -n "$source_dir" ] && [ "$source_dir" != "$checkout" ]; then
      ${git} -C "$checkout" worktree remove --force "$source_dir" >/dev/null 2>&1 || true
    fi
    ${pkgs.coreutils}/bin/rm -rf "$run_dir"
  }
  trap cleanup EXIT

  if [ -e "$state_dir/retry" ]; then
    source_dir="$checkout"
    ${pkgs.coreutils}/bin/rm -f "$state_dir/retry"
  else
    if [ "$(${git} -C "$checkout" branch --show-current)" != main ] || [ -n "$(${git} -C "$checkout" status --porcelain)" ]; then
      printf '%s\n' 'Skipped fleet build: checkout must be clean on main.' >&2
      exit 1
    fi
    source_dir="$run_dir/source"
    ${git} -C "$checkout" worktree add --detach "$source_dir" HEAD >/dev/null
  fi

  if [ -e "$state_dir/lock.json" ]; then
    ${pkgs.coreutils}/bin/cp "$state_dir/lock.json" "$run_dir/previous-lock.json"
  fi

  if [ -r /run/secrets/github-token ]; then
    export GITHUB_TOKEN="$(${pkgs.coreutils}/bin/cat /run/secrets/github-token)"
  fi
  cd "$source_dir"
  ${nix} flake update

  ${pkgs.coreutils}/bin/cp "$source_dir/flake.lock" "$run_dir/lock.json"

  build_log="$state_dir/build.log"
  : >"$build_log"
  set +e
  ${pkgs.nix-fast-build}/bin/nix-fast-build \
    --flake "$source_dir#nixosConfigurations" \
    --systems x86_64-linux \
    --no-link \
    --result-file "$run_dir/results.json" \
    --select 'configs: builtins.mapAttrs (name: config: config.config.system.build.toplevel) configs' \
    2>&1 | ${pkgs.coreutils}/bin/tee "$build_log"
  build_status=''${PIPESTATUS[0]}
  set -e
  if [ "$build_status" != 0 ]; then
    failure_log="$state_dir/failure.log"
    ${pkgs.gnugrep}/bin/grep -E -C 30 '(^|[[:space:]])error:|ERROR:nix_fast_build|Failed attributes|No such file or directory' "$build_log" >"$failure_log" || true
    exit "$build_status"
  fi

  ${pkgs.coreutils}/bin/cp "$run_dir/results.json" "$state_dir/results.json"
  ${pkgs.coreutils}/bin/cp "$run_dir/lock.json" "$state_dir/lock.json"
  if [ -e "$run_dir/previous-lock.json" ]; then
    ${pkgs.coreutils}/bin/cp "$run_dir/previous-lock.json" "$state_dir/previous-lock.json"
  else
    ${pkgs.coreutils}/bin/rm -f "$state_dir/previous-lock.json"
  fi
''
