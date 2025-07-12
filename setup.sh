#!/bin/bash
set -e

echo "🔧 Setting up development environment..."

# Detect operating system
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macOS"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="Linux"
else
    echo "❌ Unsupported OS: $OSTYPE"
    exit 1
fi

echo "🖥️  Detected OS: $OS"

echo "📦 Installing Nix packages..."
nix develop --command echo "Nix environment ready"

# Install platform-specific packages
if [[ "$OS" == "macOS" ]]; then
    echo "🍺 Installing Homebrew packages..."
    brew bundle
elif [[ "$OS" == "Linux" ]]; then
    echo "🐧 Installing Ubuntu packages..."
    if [[ -f "install-ubuntu.sh" ]]; then
        ./install-ubuntu.sh
    else
        echo "⚠️  install-ubuntu.sh not found, skipping Linux packages"
    fi
fi

echo "✅ Setup complete!"
echo ""
echo "Usage:"
echo "  nix develop    # Enter Nix dev shell"
if [[ "$OS" == "macOS" ]]; then
    echo "  brew bundle    # Install/update Homebrew apps"
else
    echo "  ./install-ubuntu.sh    # Install/update Ubuntu packages"
fi