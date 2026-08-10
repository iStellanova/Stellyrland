#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
nix build --no-link --no-write-lock-file --accept-flake-config '.#nixosConfigurations.stellyrlab.config.home-manager.users.stellanova.home.file."./.zshrc".source'
zshrc=$(nix eval --no-write-lock-file --accept-flake-config --raw '.#nixosConfigurations.stellyrlab.config.home-manager.users.stellanova.home.file."./.zshrc".source')
grep -Fq 'typeset -A _deployment_types' "$zshrc"
grep -Fq 'stellyrland nixos' "$zshrc"
grep -Fq 'stellyrtop darwin' "$zshrc"
grep -Fq 'case "$deployment_type" in' "$zshrc"
grep -Fq 'darwin-rebuild switch --flake' "$zshrc"
grep -Fq 'git+ssh://git@github.com/iStellanova/Stellyrland.git?rev=' "$zshrc"
! grep -Fq 'stellyrtop)' "$zshrc"
zsh -n "$zshrc"
