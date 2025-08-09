#!/bin/bash
set -e

echo "🐧 Setting up Ubuntu packages..."

sudo apt update

echo "📦 Installing APT packages..."
sudo apt install -y \
vlc \
curl \
git \
openssh-client

echo "📱 Installing Snap packages..."
sudo snap install discord
sudo snap install obsidian --classic
sudo snap install code --classic
sudo snap install 1password --beta

echo "✅ Ubuntu packages installed!"
