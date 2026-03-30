# Total Nix store size (using du for accuracy, even if slower than df)
STORE_SIZE=$(du -sh /nix/store 2>/dev/null | awk '{print $1}')

# Count system generations
GENS=$(ls -1d /nix/var/nix/profiles/system-*-link 2>/dev/null | wc -l)

# Get current generation number
CURRENT_GEN=$(readlink /nix/var/nix/profiles/system | grep -oP 'system-\K[0-9]+')

# Update check (only if requested, as it requires network)
UPDATES="Not checked"
if [[ "$1" == "--check-updates" ]]; then
    FLAKE_LOCK="/etc/nixos/flake.lock"
    
    if [[ -f "$FLAKE_LOCK" ]]; then
        # Try finding the correct nixpkgs input key from root.inputs
        MAIN_PKGS_KEY=$(jq -r '.nodes.root.inputs.nixpkgs' "$FLAKE_LOCK")
        
        if [[ -n "$MAIN_PKGS_KEY" && "$MAIN_PKGS_KEY" != "null" ]]; then
            CURRENT_REV=$(jq -r ".nodes[\"$MAIN_PKGS_KEY\"].locked.rev" "$FLAKE_LOCK")
            # Get the branch (ref), default to nixos-unstable if not found
            CURRENT_REF=$(jq -r ".nodes[\"$MAIN_PKGS_KEY\"].original.ref // \"nixos-unstable\"" "$FLAKE_LOCK")
            
            # Fetch the latest revision from the remote channel detected in flake.lock
            LATEST_REV=$(git ls-remote https://github.com/nixos/nixpkgs "$CURRENT_REF" 2>/dev/null | head -n1 | cut -f1)
            
            if [[ -n "$CURRENT_REV" && -n "$LATEST_REV" && "$LATEST_REV" != "null" ]]; then
                [[ "$CURRENT_REV" == "$LATEST_REV" ]] && UPDATES="Up to date" || UPDATES="Available"
            else
                UPDATES="Check Error"
            fi
        else
            UPDATES="Parse Error"
        fi
    else
        UPDATES="No flake.lock"
    fi
fi

# Output as single-line JSON for easy parsing
printf '{"store_size":"%s","generations":%d,"current_generation":%d,"updates":"%s","status":"OK"}\n' \
    "${STORE_SIZE:-0}" "${GENS:-0}" "${CURRENT_GEN:-0}" "$UPDATES"
