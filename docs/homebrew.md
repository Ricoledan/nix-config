# Homebrew Bundle Management

This document covers Homebrew Bundle usage for managing macOS-specific applications in this Nix configuration.

## Overview

Homebrew is used on macOS for applications that:
- Have better macOS integration via Homebrew
- Are not available in nixpkgs
- Have issues when installed via Nix on macOS

The `Brewfile` in the repository root defines all Homebrew packages, casks, and Mac App Store apps to be installed.

## Installing from Brewfile

To install all packages defined in the Brewfile:

```bash
brew bundle
```

This reads the `Brewfile` and installs any missing packages.

## Cleaning Up Unneeded Packages

Over time, you may have installed Homebrew packages that are no longer in your Brewfile. To clean these up:

### Check what would be removed

To see what packages are installed but not in the Brewfile (dry run):

```bash
brew bundle cleanup
```

This shows a list without actually removing anything.

### Remove packages not in Brewfile

To actually remove packages that aren't in the Brewfile:

```bash
brew bundle cleanup --force
```

**Note**: This will uninstall any Homebrew formulae, casks, and taps that are not listed in your Brewfile. Make sure to review the list first with the dry run command.

### Common issues

- Some removals may require sudo permissions and fail silently
- Taps with installed formulae won't be removed automatically
- Applications may leave behind configuration files in `~/Library` that need manual cleanup

## Updating the Brewfile

When you install a new package via Homebrew and want to keep it:

1. Add it to the `Brewfile` manually, or
2. Generate a Brewfile from currently installed packages:
   ```bash
   brew bundle dump --force
   ```
   (This overwrites the existing Brewfile with all currently installed packages)

## Best Practices

1. Keep the Brewfile in version control
2. Run `brew bundle cleanup` periodically to check for drift
3. Document why specific packages are managed via Homebrew instead of Nix (see `DECISIONS.md`)
4. Use `brew bundle check` to verify all Brewfile dependencies are satisfied