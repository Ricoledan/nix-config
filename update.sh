#!/usr/bin/env bash

# Nix flake update automation script
# Updates flake inputs and commits changes

set -euo pipefail

echo "Updating Nix flake inputs..."

# Update all flake inputs
nix flake update

# Check if there are changes
if git diff --quiet flake.lock; then
    echo "No updates available"
    exit 0
fi

echo "Changes in flake.lock:"
git diff flake.lock

# Optionally create a commit
read -p "Would you like to commit these updates? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    git add flake.lock
    git commit -m "chore: update flake inputs

$(nix flake metadata --json | jq -r '.locks.nodes | to_entries[] | select(.key != "root") | "- \(.key): \(.value.locked.rev[0:7])"')"
    echo "Updates committed"
else
    echo "Skipping commit"
fi

# Optionally run checks
echo ""
echo "Running flake checks..."
if nix flake check; then
    echo "All checks passed"
else
    echo "Some checks failed - review the output above"
    exit 1
fi
