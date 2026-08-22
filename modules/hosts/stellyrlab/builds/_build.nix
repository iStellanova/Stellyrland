{
  host,
  pkgs,
  lib,
  nix,
  nixStore,
  git,
  jq,
  stateDir,
  notify,
}:
pkgs.writeShellScript "nix-fleet-build" ''
  set -euo pipefail
  cd ${lib.escapeShellArg host.flakePath}

  if [ "$(${git} branch --show-current)" != main ] || [ -n "$(${git} status --porcelain)" ]; then
    printf '%s\n' 'Skipped fleet build: checkout must be clean on main.' >&2
    exit 77
  fi

  if [ -r /run/secrets/github-token ]; then
    export GITHUB_TOKEN="$(${pkgs.coreutils}/bin/cat /run/secrets/github-token)"
  fi

  run_dir=$(${pkgs.coreutils}/bin/mktemp -d)
  trap '${pkgs.coreutils}/bin/rm -rf "''${run_dir}"' EXIT
  before_lock="$run_dir/before-lock.json"
  ${git} show HEAD:flake.lock >"$before_lock"
  ${nix} flake update

  hosts_file=$(${pkgs.coreutils}/bin/mktemp)
  trap '${pkgs.coreutils}/bin/rm -f "''${hosts_file}" "''${run_dir}"/before-lock.json; ${pkgs.coreutils}/bin/rm -rf "''${run_dir}"' EXIT
  if ! ${nix} eval --impure --raw --no-write-lock-file --expr '
      let
        flake = builtins.getFlake (toString ./.);
        hosts = builtins.attrNames flake.nixosConfigurations;
      in
        builtins.concatStringsSep "\n" (builtins.filter (name:
          flake.nixosConfigurations.''${name}.config.nixpkgs.hostPlatform.system == "x86_64-linux"
        ) hosts)
    ' >"$hosts_file"; then
    printf '%s\n' 'Unable to discover x86_64-linux NixOS hosts.' >&2
    exit 1
  fi
  mapfile -t hosts <"$hosts_file"

  if ((''${#hosts[@]} == 0)); then
    printf '%s\n' 'No x86_64-linux NixOS hosts found.' >&2
    exit 1
  fi

  ${pkgs.coreutils}/bin/mkdir -p ${lib.escapeShellArg stateDir}/hosts
  report="$run_dir/report"
  {
    printf '%s\n' '✅ Stellyrland fleet build: SUCCESS'
    printf '\nCheckout: %s\n\n' "$(${git} rev-parse --short HEAD)"
    printf '%s\n' '📦 Package changes'
  } >"$report"

  for name in "''${hosts[@]}"; do
    new_path=$(${nix} build --no-link --print-out-paths --no-write-lock-file \
      ".#nixosConfigurations.$name.config.system.build.toplevel")
    old_link=${lib.escapeShellArg stateDir}/hosts/$name
    {
      printf '\n%s\n' "### $name"
      if [ -e "$old_link" ]; then
        diff=$(${nix} store diff-closures "$(readlink -f "$old_link")" "$new_path")
        if [ -z "$diff" ]; then
          printf '%s\n' '  • No package changes'
        else
          added=()
          updated=()
          removed=()
          while IFS= read -r line; do
            case "$line" in
              *': ∅ → '*) added+=("$line") ;;
              *' → ∅'*) removed+=("$line") ;;
              *) updated+=("$line") ;;
            esac
          done <<<"$diff"
          for group in added updated removed; do
            case "$group" in
              added) entries=("''${added[@]}"); title='Added' ;;
              updated) entries=("''${updated[@]}"); title='Updated' ;;
              removed) entries=("''${removed[@]}"); title='Removed' ;;
            esac
            if ((''${#entries[@]})); then
              printf '  %s\n' "$title"
              printf '  • %s\n' "''${entries[@]}"
            fi
          done
        fi
      else
        printf '%s\n' '  • Baseline unavailable (first successful run)'
      fi
    } >>"$report"
    printf '%s\n' "$new_path" >"$run_dir/$name.path"
  done

  declare -A old_rev new_rev
  while IFS=$'\t' read -r name rev; do old_rev["$name"]=$rev; done < <(${jq} -r '. as $lock | $lock.nodes.root.inputs | to_entries[] | .key as $name | .value as $ref | ($ref | if type == "string" then . else .[0] end) as $node | [$name, ($lock.nodes[$node].locked.rev // $lock.nodes[$node].locked.lastModified // "")] | @tsv' "$before_lock")
  while IFS=$'\t' read -r name rev; do new_rev["$name"]=$rev; done < <(${jq} -r '. as $lock | $lock.nodes.root.inputs | to_entries[] | .key as $name | .value as $ref | ($ref | if type == "string" then . else .[0] end) as $node | [$name, ($lock.nodes[$node].locked.rev // $lock.nodes[$node].locked.lastModified // "")] | @tsv' flake.lock)
  names=$(${pkgs.coreutils}/bin/mktemp)
  trap '${pkgs.coreutils}/bin/rm -f "''${hosts_file}" "''${names}"; ${pkgs.coreutils}/bin/rm -rf "''${run_dir}"' EXIT
  printf '%s\n' "''${!old_rev[@]}" "''${!new_rev[@]}" | ${pkgs.coreutils}/bin/sort -u >"$names"
  {
    printf '\n%s\n' '🔗 Input changes'
    input_added=0
    input_updated=0
    input_removed=0
    for name in $(<"$names"); do
      old=''${old_rev[$name]-}
      new=''${new_rev[$name]-}
      if [ -z "$old" ]; then
        if [ "$input_added" = 0 ]; then printf '%s\n' '  Added'; fi
        printf '  • %s @ %s\n' "$name" "$new"
        input_added=1
      elif [ -z "$new" ]; then
        if [ "$input_removed" = 0 ]; then printf '%s\n' '  Removed'; fi
        printf '  • %s @ %s\n' "$name" "$old"
        input_removed=1
      elif [ "$old" != "$new" ]; then
        if [ "$input_updated" = 0 ]; then printf '%s\n' '  Updated'; fi
        printf '  • %s\n    old: %s\n    new: %s\n' "$name" "$old" "$new"
        input_updated=1
      fi
    done
    if [ "$input_added$input_updated$input_removed" = 000 ]; then
      printf '%s\n' '  • No input changes'
    fi
  } >>"$report"

  mapfile -t changed < <(${git} status --porcelain)
  for change in "''${changed[@]}"; do
    case "''${change:3}" in
      flake.lock) ;;
      *)
        printf 'Unexpected working-tree change after fleet build: %s\n' "$change" >&2
        exit 1
        ;;
    esac
  done

  if ((''${#changed[@]})); then
    ${git} add flake.lock
    ${git} diff --cached --check
    ${git} -c user.name='Stellxie[bot]' \
      -c user.email='313256644+Stellxie@users.noreply.github.com' \
      -c user.signingkey='/run/secrets/stellxie-github-signing' \
      -c gpg.format=ssh \
      -c commit.gpgsign=true \
      commit -S \
      --author='stellanova <iStellanova@users.noreply.github.com>' \
      -m 'chore(flake): update inputs' \
      -m $'Refresh flake inputs and lock data.\n\nCo-authored-by: Stellxie[bot] <313256644+Stellxie@users.noreply.github.com>'
  fi

  for name in "''${hosts[@]}"; do
    new_path=$(${pkgs.coreutils}/bin/cat "$run_dir/$name.path")
    ${nixStore} --add-root ${lib.escapeShellArg stateDir}/hosts/$name --indirect --realise "$new_path"
  done

  printf '\n%s\n' 'Result: build completed successfully.' >>"$report"
  if ! ${notify} "$report"; then
    printf '%s\n' 'Fleet build succeeded but Discord notification failed.' >&2
  fi
''
