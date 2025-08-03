#!/usr/bin/env bash

# Dynamic Home Manager switch script
# Works for any user without modification

set -e

SYSTEM=$(nix eval --impure --expr 'builtins.currentSystem' --raw)

echo "Home Manager Switch"
echo "-------------------"
echo "  User: $USER"
echo "  Home: $HOME"
echo "  System: $SYSTEM"
echo ""

# The key is using --impure to allow environment variable access
if command -v home-manager &> /dev/null; then
    echo "Using installed home-manager..."
    home-manager switch --flake ".#user@${SYSTEM}" --impure
else
    echo "Bootstrapping home-manager..."
    nix run home-manager/master -- switch --flake ".#user@${SYSTEM}" --impure
fi

echo ""
echo "Configuration applied successfully!"