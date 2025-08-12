# Podman Configuration Guide

## The Problem

Podman Desktop searches for the Podman CLI in specific hardcoded paths:
- `/usr/local/bin/podman`
- `/opt/homebrew/bin/podman` 
- `/opt/podman/bin/podman`

However, when installed via Nix, Podman is located at:
- `~/.nix-profile/bin/podman` (or similar Nix store path)

This mismatch causes Podman Desktop to report "Podman CLI not found" even though Podman is installed and working perfectly from the terminal.

## Why This Happens

1. **Podman Desktop's detection logic**: The application has hardcoded paths where it looks for the Podman binary, based on common installation methods (Homebrew, system packages, official installer).

2. **Nix's unique approach**: Nix installs software in its store (`/nix/store/...`) and creates symlinks in user profiles, which aren't in Podman Desktop's search paths.

3. **macOS security**: System directories like `/usr/local/bin` require elevated permissions to modify, making automated symlinking challenging.

## Solutions (Most to Least Reproducible)

### 1. Wrapper Script (Recommended) ✅

**What it does**: Creates a launcher that adds Podman to PATH before starting Podman Desktop.

```bash
# After running home-manager switch, use:
podman-desktop-wrapped
```

**Pros**:
- Fully reproducible across machines
- No sudo required
- Declarative in Nix configuration
- Works immediately after `home-manager switch`

**Cons**:
- Must remember to use `podman-desktop-wrapped` instead of regular app

### 2. System Symlinks (Semi-Reproducible) ⚠️

**What it does**: Creates symlinks in paths where Podman Desktop looks.

```bash
# Option A: Create dedicated directory (recommended)
sudo mkdir -p /opt/podman/bin
sudo ln -sf ~/.nix-profile/bin/podman /opt/podman/bin/podman

# Option B: Use existing directory
sudo ln -sf ~/.nix-profile/bin/podman /usr/local/bin/podman
```

**Pros**:
- Works with regular Podman Desktop app
- One-time setup per machine

**Cons**:
- Requires sudo (manual intervention)
- Must be redone on each new machine
- Symlinks may break if Nix profile path changes

### 3. PATH Modification (Not Recommended) ❌

**What it does**: Modifies system PATH to include Nix profile.

**Why not recommended**:
- macOS apps don't inherit shell PATH
- Would require modifying system-wide configurations
- May conflict with other tools

## How Our Configuration Handles This

The `home/modules/podman.nix` file includes:

1. **Automatic symlink attempt**: Tries to create symlinks in writable directories during activation
2. **Wrapper script**: Provides `podman-desktop-wrapped` as a reliable fallback
3. **Clear instructions**: Shows exactly what commands to run if manual setup is needed

## Verification

To check if Podman Desktop can detect Podman:

```bash
# Check if Podman is installed
which podman
podman --version

# Check if symlinks exist in expected locations
ls -la /opt/podman/bin/podman 2>/dev/null || echo "Not in /opt/podman/bin"
ls -la /usr/local/bin/podman 2>/dev/null || echo "Not in /usr/local/bin"
ls -la /opt/homebrew/bin/podman 2>/dev/null || echo "Not in /opt/homebrew/bin"
```

## Docker Compatibility

The configuration also sets up Docker compatibility:
- Sets `DOCKER_HOST` to point to Podman's socket
- Allows Docker commands to work with Podman
- Enables tools expecting Docker to work seamlessly

## Troubleshooting

### Podman Desktop still doesn't detect Podman
1. Ensure you've run `home-manager switch`
2. Try the wrapper: `podman-desktop-wrapped`
3. If needed, create symlinks with sudo (see above)
4. Restart Podman Desktop after creating symlinks

### Permission denied when creating symlinks
- You need sudo access
- Some directories may be protected by System Integrity Protection (SIP)
- Try `/opt/podman/bin` first as it's usually less restricted

### Podman works in terminal but not in Podman Desktop
- This confirms the PATH issue
- Use the wrapper script or create symlinks

## Future Improvements

Ideally, Podman Desktop would:
- Check standard PATH locations
- Allow custom Podman binary path in settings
- Detect Nix installations automatically

Until then, the wrapper script provides the most reliable, reproducible solution.