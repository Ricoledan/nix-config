# Podman Configuration Guide

## Why Homebrew for Podman on macOS?

After extensive testing, we've decided to manage Podman and Podman Desktop through Homebrew on macOS rather
than Nix. Here's why:

### The Challenges with Nix

1. **Missing podman-mac-helper**: The Nix podman package doesn't include `podman-mac-helper`, which is essential for:
   - Binding to privileged ports (< 1024)
   - Proper macOS system integration
   - Running containers with elevated privileges when needed

2. **Podman Desktop Integration Issues**:
   - Podman Desktop looks for Podman CLI in hardcoded paths:
     - `/usr/local/bin/podman`
     - `/opt/homebrew/bin/podman`
     - `/opt/podman/bin/podman`
   - Nix installs to `~/.nix-profile/bin/podman`, which isn't detected
   - Workarounds require manual symlinks with sudo or wrapper scripts

3. **Complex Workarounds**:
   - Attempted to extract podman-mac-helper from official installer
   - Required building custom Nix derivations
   - Still faced integration issues with macOS security features

### Why Homebrew Works Better

1. **Complete Package**: Homebrew's podman formula includes all necessary components
2. **Native Integration**: Installs to expected system paths
3. **Podman Desktop Compatibility**: Works out of the box
4. **Simpler Setup**: One-time installation with full functionality

## Installation

### Prerequisites

Ensure Homebrew is installed:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Install Podman via Homebrew

1. Apply the home-manager configuration:

   ```bash
   ./sync-hm.sh
   ```

2. Install Homebrew packages:

   ```bash
   brew bundle --file=$HOME/.config/homebrew/Brewfile
   ```

3. Set up Podman Mac Helper:

   ```bash
   sudo podman-mac-helper install
   ```

4. Initialize Podman machine:

   ```bash
   podman machine init
   podman machine start
   ```

## What This Setup Provides

- **Podman CLI**: Full container management capabilities
- **Podman Compose**: Docker Compose compatibility
- **Podman Desktop**: GUI for container management
- **Docker Compatibility**: DOCKER_HOST is configured for compatibility

## Verification

Check that everything is working:

```bash
# Verify Podman installation
podman --version

# Check machine status
podman machine list

# Verify Mac Helper
sudo podman-mac-helper status

# Test privileged port binding
podman run -d -p 80:80 nginx:alpine
```

## Trade-offs

### What We Lose

- Pure Nix reproducibility for Podman
- Declarative version management for Podman

### What We Gain

- Full macOS integration
- All Podman features working correctly
- No manual intervention after initial setup
- Better Podman Desktop experience

## Future Considerations

If the Nix podman package eventually includes podman-mac-helper and better macOS integration, we could revisit
this decision. For now, Homebrew provides the most reliable Podman experience on macOS.
