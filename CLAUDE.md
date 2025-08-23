# Claude Context File

This file provides important context for Claude when working with this repository.

## Repository Overview

This is a personal Nix configuration repository that manages development environments across macOS and Linux using:
- Nix flakes for reproducible package management
- Home Manager for user-specific configurations
- Platform-specific tools (Homebrew on macOS) where necessary

## Important Files to Remember

- `DECISIONS.md` - Architectural decisions and principles (UPDATE THIS when making exceptions)
- `flake.nix` - Main Nix flake configuration
- `home/home.nix` - Home Manager entry point
- `home/modules/` - Modular configuration files
- `docs/` - Detailed documentation for specific topics

## Key Principles

The core principles are defined in the main README.md. See [Core Principles section](README.md#core-principles) for details. These guide all architectural decisions in this repository.

## Platform-Specific Considerations

### macOS
- Some tools managed via Homebrew (see `Brewfile` in repository root)
- Podman requires Homebrew due to macOS integration issues
- AeroSpace window manager configuration included

### Linux
- Pure Nix approach generally works better
- Ubuntu-specific setup in `install-ubuntu.sh`

## When Making Changes

1. **Adding new packages**:
   - First try adding to `home/modules/packages.nix`
   - If Nix package has issues on macOS, consider Homebrew
   - Document any exceptions in `DECISIONS.md`

2. **Platform-specific code**:
   - Use `lib.mkIf pkgs.stdenv.isDarwin` for macOS-only
   - Use `lib.mkIf pkgs.stdenv.isLinux` for Linux-only

3. **Documentation**:
   - Update relevant docs in `docs/` for complex topics
   - Add decisions to `DECISIONS.md` when deviating from principles
   - Keep README focused on quick start

## Current Exceptions to Principles

- **Podman on macOS**: Managed via Homebrew instead of Nix (see `DECISIONS.md` and `docs/podman.md`)

## Testing Changes

Always test with:
```bash
./sync-hm.sh
```

Remember to check both platforms when possible.
