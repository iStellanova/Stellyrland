{
  host,
  pkgs,
  lib,
  nix,
  nixStore,
  jq,
  git,
  stateDir,
  notify,
}:
pkgs.writeShellScript "nix-fleet-build-report" ''
  set -euo pipefail
  state_dir=${lib.escapeShellArg stateDir}
  report=$(${pkgs.coreutils}/bin/mktemp)
  trap '${pkgs.coreutils}/bin/rm -f "''${report}"' EXIT

  {
    printf '%s\n' '✅ Stellyrland fleet build: SUCCESS'
    printf '\nCheckout: %s\n' "$(${git} -C ${lib.escapeShellArg host.flakePath} rev-parse --short HEAD)"
    printf '\n%s\n' '📦 Package changes'

    ${pkgs.coreutils}/bin/mkdir -p "$state_dir/hosts"
    while IFS=$'\t' read -r name new_path; do
      [ -n "$name" ] || continue
      old_link="$state_dir/hosts/$name"
      printf '\n### %s\n' "$name"
      if [ -e "$old_link" ]; then
        diff=$(${nix} store diff-closures "$(readlink -f "$old_link")" "$new_path")
        if [ -n "$diff" ]; then
          printf '%s\n' "$diff"
        else
          printf '%s\n' '  • No package changes'
        fi
      else
        printf '%s\n' '  • Baseline unavailable (first successful run)'
      fi
      ${nixStore} --add-root "$old_link" --indirect --realise "$new_path" >/dev/null
    done < <(${jq} -r '.results[] | select(.type == "BUILD" and .success == true and .outputs.out != null) | [.attr, .outputs.out] | @tsv' "$state_dir/results.json" | ${pkgs.coreutils}/bin/sort -u)

    printf '\n%s\n' '🔗 Input changes'
    if [ -e "$state_dir/previous-lock.json" ]; then
      declare -A old_rev new_rev
      while IFS=$'\t' read -r name rev; do old_rev["$name"]=$rev; done < <(${jq} -r '. as $lock | $lock.nodes.root.inputs | to_entries[] | .key as $name | .value as $ref | ($ref | if type == "string" then . else .[0] end) as $node | [$name, ($lock.nodes[$node].locked.rev // $lock.nodes[$node].locked.lastModified // "")] | @tsv' "$state_dir/previous-lock.json")
      while IFS=$'\t' read -r name rev; do new_rev["$name"]=$rev; done < <(${jq} -r '. as $lock | $lock.nodes.root.inputs | to_entries[] | .key as $name | .value as $ref | ($ref | if type == "string" then . else .[0] end) as $node | [$name, ($lock.nodes[$node].locked.rev // $lock.nodes[$node].locked.lastModified // "")] | @tsv' "$state_dir/lock.json")
      changed=0
      while IFS= read -r name; do
        old=''${old_rev[$name]-}
        new=''${new_rev[$name]-}
        if [ -z "$old" ]; then
          printf '  • Added: %s @ %s\n' "$name" "$new"
          changed=1
        elif [ -z "$new" ]; then
          printf '  • Removed: %s @ %s\n' "$name" "$old"
          changed=1
        elif [ "$old" != "$new" ]; then
          printf '  • Updated: %s\n    old: %s\n    new: %s\n' "$name" "$old" "$new"
          changed=1
        fi
      done < <(printf '%s\n' "''${!old_rev[@]}" "''${!new_rev[@]}" | ${pkgs.coreutils}/bin/sort -u)
      [ "$changed" = 1 ] || printf '%s\n' '  • No input changes'
    else
      printf '%s\n' '  • Baseline unavailable (first successful run)'
    fi
  } >"$report"

  ${notify} "$report"
''
