#!/bin/bash
set -e

echo "🐧 Setting up Ubuntu packages..."

# Update package lists
sudo apt update

# Install APT packages
echo "📦 Installing APT packages..."
sudo apt install -y \
    vlc \
    curl \
    git \
    openssh-client

# Install Snap packages
echo "📱 Installing Snap packages..."
sudo snap install discord
sudo snap install obsidian --classic
sudo snap install code --classic
sudo snap install 1password --beta

echo "✅ Ubuntu packages installed!"
echo ""
echo "Note: Some GUI apps from your Brewfile don't have Ubuntu equivalents:"
echo "  - ghostty (terminal) → use gnome-terminal or install from source"
echo "  - alfred (launcher) → use gnome launcher or install ulauncher"
echo "  - adobe-creative-cloud → not available on Linux"
echo "  - bambu-studio → may need manual install"
echo "  - plex → use web client or install from Plex website"
echo "  - cleanmymac → use built-in disk cleanup tools"
echo "  - magnet (window manager) → use built-in tiling or install i3/sway"
echo "  - jetbrains-toolbox → download from JetBrains website"
echo "  - fantastical → use gnome-calendar or thunderbird"
echo "  - todoist → use web client or install via snap/flatpak"