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
    brew bundle --no-upgrade
elif [[ "$OS" == "Linux" ]]; then
    echo "🐧 Installing Ubuntu packages..."
    if [[ -f "install-ubuntu.sh" ]]; then
        ./install-ubuntu.sh
    else
        echo "⚠️  install-ubuntu.sh not found, skipping Linux packages"
    fi
fi

# Setup Podman if available
if command -v podman &> /dev/null; then
    echo ""
    echo "🐳 Found Podman installation, running setup..."
    if [[ -f "scripts/setup-podman.sh" ]]; then
        chmod +x scripts/setup-podman.sh
        echo "Run './scripts/setup-podman.sh' to complete Podman setup (requires sudo)"
    fi
fi

echo "✅ Setup complete!"
echo ""
echo "Usage:"
echo "  nix develop    # Enter Nix dev shell"
if [[ "$OS" == "macOS" ]]; then
    echo "  brew bundle --no-upgrade    # Install Homebrew apps without upgrading"
else
    echo "  ./install-ubuntu.sh    # Install/update Ubuntu packages"
fi
if command -v podman &> /dev/null; then
    echo "  ./scripts/setup-podman.sh    # Complete Podman setup (requires sudo)"
fi
