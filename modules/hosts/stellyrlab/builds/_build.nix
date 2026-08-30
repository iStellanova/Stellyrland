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
  ${pkgs.coreutils}/bin/mkdir -p "$state_dir"

  if [ -e "$state_dir/retry" ]; then
    ${pkgs.coreutils}/bin/rm -f "$state_dir/retry"
    attempt=$(${pkgs.coreutils}/bin/cat "$state_dir/attempt" 2>/dev/null || printf '1')
    attempt=$((attempt + 1))
  else
    attempt=1
    if [ "$(${git} -C "$checkout" branch --show-current)" != main ] || [ -n "$(${git} -C "$checkout" status --porcelain)" ]; then
      printf '%s\n' 'Skipped fleet build: checkout must be clean on main.' >&2
      exit 1
    fi
    if [ -e "$state_dir/lock.json" ]; then
      ${pkgs.coreutils}/bin/cp "$state_dir/lock.json" "$state_dir/previous-lock.json"
    else
      ${pkgs.coreutils}/bin/rm -f "$state_dir/previous-lock.json"
    fi

    if [ -r /run/secrets/github-token ]; then
      export GITHUB_TOKEN="$(${pkgs.coreutils}/bin/cat /run/secrets/github-token)"
    fi
    cd "$checkout"
    ${nix} flake update
    ${pkgs.coreutils}/bin/cp flake.lock "$state_dir/lock.json"
  fi

  printf '%s\n' "$attempt" >"$state_dir/attempt"
  if [ "$attempt" -gt 7 ]; then
    printf 'Fleet build stopped after 7 attempts.\n' >&2
    exit 1
  fi

  cd "$checkout"

  build_log="$state_dir/build.log"
  : >"$build_log"
  set +e
  ${pkgs.nix-fast-build}/bin/nix-fast-build \
    --flake "$checkout#nixosConfigurations" \
    --systems x86_64-linux \
    --no-link \
    --result-file "$state_dir/results.json" \
    --select 'configs: builtins.mapAttrs (name: config: config.config.system.build.toplevel) configs' \
    2>&1 | ${pkgs.coreutils}/bin/tee "$build_log"
  build_status=''${PIPESTATUS[0]}
  set -e
  if [ "$build_status" != 0 ]; then
    failure_log="$state_dir/failure.log"
    ${pkgs.gnugrep}/bin/grep -E -C 30 '(^|[[:space:]])error:|ERROR:nix_fast_build|Failed attributes|No such file or directory' "$build_log" >"$failure_log" || true
    exit "$build_status"
  fi
''
