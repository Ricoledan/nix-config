#!/usr/bin/env bash
# Podman Setup Script for Nix on macOS
# This script sets up Podman for rootless operation with Docker compatibility

set -e

echo "🐳 Setting up Podman environment..."
echo ""

# Get the actual Podman path from Nix
PODMAN_PATH=$(which podman)
if [ -z "$PODMAN_PATH" ]; then
    echo "❌ Podman not found in PATH. Please run 'home-manager switch' first."
    exit 1
fi
echo "Found Podman at: $PODMAN_PATH"

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "⚠️  This script is designed for macOS. Exiting."
    exit 1
fi

# Create symlinks for Podman Desktop detection
echo ""
echo "📁 Creating symlinks for Podman Desktop..."
echo "This requires sudo access."

# Option 1: Create dedicated directory (recommended)
sudo mkdir -p /opt/podman/bin
sudo ln -sf "$PODMAN_PATH" /opt/podman/bin/podman
sudo ln -sf "$(dirname "$PODMAN_PATH")/podman-remote" /opt/podman/bin/podman-remote 2>/dev/null || true
sudo ln -sf "$(dirname "$PODMAN_PATH")/gvproxy" /opt/podman/bin/gvproxy 2>/dev/null || true

echo "✅ Symlinks created in /opt/podman/bin"

# Initialize Podman machine
echo ""
echo "🔧 Initializing Podman machine..."
if ! podman machine list | grep -q "podman-machine-default"; then
    echo "Creating new Podman machine..."
    podman machine init --cpus 2 --memory 2048 --disk-size 20
else
    echo "Podman machine already exists"
fi

# Start Podman machine
echo ""
echo "🚀 Starting Podman machine..."
if ! podman machine list | grep -q "Running"; then
    podman machine start
else
    echo "Podman machine is already running"
fi

# Verify Docker compatibility
echo ""
echo "🔍 Checking Docker compatibility..."
if [ -n "$DOCKER_HOST" ]; then
    echo "DOCKER_HOST is set to: $DOCKER_HOST"
    echo "Docker commands should work with Podman"
else
    echo "⚠️  DOCKER_HOST is not set. You may need to restart your shell."
fi

# Configure container registries
echo ""
echo "📦 Configuring container registries..."
mkdir -p ~/.config/containers

# Create registries.conf if it doesn't exist
if [ ! -f ~/.config/containers/registries.conf ]; then
    cat > ~/.config/containers/registries.conf << 'EOF'
# Container registries configuration
unqualified-search-registries = ["docker.io", "quay.io", "ghcr.io"]

[[registry]]
location = "docker.io"
insecure = false

[[registry]]
location = "quay.io"
insecure = false

[[registry]]
location = "ghcr.io"
insecure = false
EOF
    echo "✅ Created registries configuration"
else
    echo "ℹ️  Registries configuration already exists"
fi

# Create storage configuration for better performance
if [ ! -f ~/.config/containers/storage.conf ]; then
    cat > ~/.config/containers/storage.conf << 'EOF'
[storage]
driver = "overlay"
runroot = "/run/user/1000"
graphroot = "/var/lib/containers/storage"

[storage.options]
# Improve layer caching and performance
mount_program = "/usr/bin/fuse-overlayfs"
EOF
    echo "✅ Created storage configuration"
else
    echo "ℹ️  Storage configuration already exists"
fi

# Create Docker compatibility alias
echo ""
echo "🐋 Setting up Docker compatibility..."
if ! command -v docker &> /dev/null; then
    echo "Creating docker alias..."
    mkdir -p ~/.local/bin
    cat > ~/.local/bin/docker << 'EOF'
#!/bin/sh
exec podman "$@"
EOF
    chmod +x ~/.local/bin/docker
    echo "✅ Docker alias created"
else
    echo "ℹ️  Docker command already exists"
fi

# Test Podman
echo ""
echo "🧪 Testing Podman..."
podman version
echo ""
podman info --format "rootless: {{.Host.Security.Rootless}}"

# Show machine status
echo ""
echo "📊 Podman machine status:"
podman machine list

echo ""
echo "✅ Podman setup complete!"
echo ""
echo "Next steps:"
echo "1. Restart your terminal to ensure all environment variables are loaded"
echo "2. Test with: podman run --rm hello-world"
echo "3. For Docker compatibility, use: docker run --rm hello-world"
echo "4. Open Podman Desktop (use 'podman-desktop-wrapped' command)"
echo ""
echo "Additional commands:"
echo "  podman machine stop     # Stop the VM to save resources"
echo "  podman machine start    # Start the VM when needed"
echo "  podman system prune -a  # Clean up unused images and containers"
