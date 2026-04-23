#!/usr/bin/env bash
# Run once after cloning this repo on a new machine.
# Activates the gitleaks pre-commit hook and warns if gitleaks is missing.

set -euo pipefail

cd "$(dirname "$0")"

git config core.hooksPath .githooks
echo "gitleaks pre-commit hook activated (core.hooksPath=.githooks)"

if ! command -v gitleaks >/dev/null 2>&1; then
  cat <<'EOF'
gitleaks not installed — the hook will no-op until you install it:
  macOS:  brew install gitleaks
  Arch:   pacman -S gitleaks
  NixOS:  nix-env -iA nixpkgs.gitleaks
EOF
fi
