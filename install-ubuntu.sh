#!/bin/bash
set -e

# This script installs GUI applications and system-level dependencies on Ubuntu.
# CLI tools (git, curl, openssh, etc.) are managed by Nix via home-manager.
# Run this AFTER setting up Nix and running ./sync-hm.sh

echo "🐧 Setting up Ubuntu system packages..."

sudo apt update

echo "📦 Installing system-level APT packages..."
sudo apt install -y \
  vlc

# Note: The following tools are managed by Nix (in home/modules/packages.nix):
# - git, curl, openssh (CLI tools)
# - Development tools and runtimes

echo "📱 Installing GUI applications via Snap..."
# Note: These could be moved to Nix for better reproducibility
# but are kept as snap for convenience and auto-updates
sudo snap install discord
sudo snap install obsidian --classic
sudo snap install code --classic
sudo snap install 1password --beta

echo ""
echo "✅ Ubuntu system packages installed!"
echo ""
echo "Next steps:"
echo "  1. Ensure Nix is installed with flakes enabled"
echo "  2. Run: ./sync-hm.sh  (to install Nix-managed packages)"
echo "  3. Start zsh and configure as needed"
echo ""
