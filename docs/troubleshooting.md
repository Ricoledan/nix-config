# Troubleshooting Guide

This guide covers common issues and their solutions when working with this Nix configuration.

## Table of Contents

- [Installation Issues](#installation-issues)
- [Build Errors](#build-errors)
- [Platform-Specific Issues](#platform-specific-issues)
- [Module Problems](#module-problems)
- [Git and Version Control](#git-and-version-control)
- [Performance Issues](#performance-issues)

## Installation Issues

### Nix is not installed

**Symptom:**
```bash
command not found: nix
```

**Solution:**
Install Nix using the Determinate Systems installer:
```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

### Home Manager not found

**Symptom:**
```bash
error: attribute 'home-manager' in selection path 'home-manager' not found
```

**Solution:**
The flake will automatically fetch home-manager. Ensure you're using the flake-enabled Nix:
```bash
nix --version  # Should show 2.18 or higher
```

### Experimental features not enabled

**Symptom:**
```bash
error: experimental Nix feature 'nix-command' is disabled
error: experimental Nix feature 'flakes' is disabled
```

**Solution:**
Add to `~/.config/nix/nix.conf` or `/etc/nix/nix.conf`:
```conf
experimental-features = nix-command flakes
```

## Build Errors

### Git tree has uncommitted changes

**Symptom:**
```bash
warning: Git tree '/Users/username/nix-config' has uncommitted changes
```

**Solution:**
This is a warning, not an error. To suppress it:
1. Commit your changes: `git add -A && git commit -m "WIP"`
2. Or use `--impure` flag (already in sync-hm.sh)

### File would be clobbered

**Symptom:**
```bash
Existing file '/Users/username/.config/git/ignore' would be clobbered
```

**Solution:**
Back up existing files and use the `-b` flag:
```bash
home-manager switch --flake .#user@$(nix eval --impure --expr 'builtins.currentSystem' --raw) --impure -b backup
```

Or manually backup:
```bash
mv ~/.config/git/ignore ~/.config/git/ignore.backup
./sync-hm.sh
```

### Module not found

**Symptom:**
```bash
error: path '/nix/store/.../home/modules/example.nix' does not exist
```

**Solution:**
1. Ensure all new files are staged in git: `git add -A`
2. Check the import path is correct relative to the importing file
3. Verify file actually exists: `ls -la home/modules/`

### Infinite recursion

**Symptom:**
```bash
error: infinite recursion encountered
```

**Solution:**
Common causes:
1. Circular imports between modules
2. Recursive option definitions
3. Using `config.option` in the definition of `option`

Debug by:
1. Comment out recent changes
2. Use `--show-trace` to identify the loop
3. Check for circular dependencies

## Platform-Specific Issues

### macOS: Homebrew not found

**Symptom:**
```bash
Homebrew is not installed. Please install it first:
```

**Solution:**
Install Homebrew:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### macOS: Architecture mismatch

**Symptom:**
```bash
error: a 'aarch64-darwin' with features {} is required, but I am a 'x86_64-darwin'
```

**Solution:**
Use Rosetta or ensure you're using the correct system:
```bash
# Check your system
uname -m

# Use the correct configuration
./sync-hm.sh  # Automatically detects system
```

### Linux: Missing clipboard support

**Symptom:**
```bash
error: xclip: command not found
```

**Solution:**
The Linux platform module should install clipboard utilities. Ensure it's imported:
```nix
imports = [
  ./modules/platform/linux.nix
];
```

## Module Problems

### Zsh configuration not loading

**Symptom:**
- P10k prompt not showing
- Aliases not working
- Completions missing

**Solution:**
1. Ensure zsh is your default shell: `chsh -s $(which zsh)`
2. Restart your terminal
3. Check if `.zshrc` is symlinked: `ls -la ~/.zshrc`
4. Manually source: `source ~/.zshrc`

### Neovim plugins not loading

**Symptom:**
- LazyVim not starting
- LSP not working
- Plugins missing

**Solution:**
1. Clear Neovim cache: `rm -rf ~/.local/share/nvim ~/.cache/nvim`
2. Open Neovim and run: `:Lazy sync`
3. Check for errors: `:checkhealth`

### Git configuration not applied

**Symptom:**
- Git aliases not working
- Wrong user information

**Solution:**
1. Check git config: `git config --list --show-origin`
2. Ensure git module is imported in home.nix
3. Override with your info:
```nix
programs.git = {
  userName = "Your Name";
  userEmail = "your@email.com";
};
```

### Direnv not activating

**Symptom:**
- `.envrc` files ignored
- No automatic environment switching

**Solution:**
1. Allow the directory: `direnv allow`
2. Check direnv status: `direnv status`
3. Ensure hook is loaded: `eval "$(direnv hook zsh)"`
4. Check trusted directories in the direnv module

## Git and Version Control

### Failed to push (uncommitted changes)

**Symptom:**
```bash
error: failed to push some refs
```

**Solution:**
1. Commit your changes first
2. Or stash them: `git stash`
3. Then push: `git push`

### Merge conflicts in flake.lock

**Symptom:**
```bash
CONFLICT (content): Merge conflict in flake.lock
```

**Solution:**
```bash
# Accept upstream version
git checkout --theirs flake.lock
nix flake update  # Regenerate with latest

# Or accept your version
git checkout --ours flake.lock
```

## Performance Issues

### Slow Home Manager activation

**Symptom:**
- `home-manager switch` takes a long time
- Hanging during activation

**Solution:**
1. Use binary cache:
```bash
nix-env -iA cachix -f https://cachix.org/api/v1/install
cachix use nix-community
```

2. Limit parallel jobs:
```bash
home-manager switch --max-jobs 2
```

3. Check for large files being copied:
```bash
du -sh ~/.config/* | sort -h
```

### High disk usage

**Symptom:**
- `/nix/store` consuming too much space

**Solution:**
1. Garbage collect old generations:
```bash
# List generations
home-manager generations

# Remove old ones
home-manager expire-generations "-7 days"

# Garbage collect
nix-collect-garbage -d
```

2. Optimize store:
```bash
nix-store --optimise
```

## Common Error Messages

### "programs.zsh.initExtra is deprecated"

**Status:** Warning only, still functional

**Solution:**
This is addressed with TODO comments in the code. Will be fixed when `initContent` is available in stable.

### "Cannot allocate memory"

**Solution:**
1. Check available memory: `free -h`
2. Close other applications
3. Reduce Nix parallel jobs: `--max-jobs 1`

### "SSL certificate problem"

**Solution:**
1. Update certificates: `nix-env -iA nixpkgs.cacert`
2. Check proxy settings
3. Verify network connectivity

## Getting Help

If you encounter an issue not covered here:

1. **Check the module documentation:** [modules.md](modules.md)
2. **Review recent changes:** `git log --oneline -10`
3. **Use verbose output:** `./sync-hm.sh --show-trace`
4. **Search existing issues:** [GitHub Issues](https://github.com/yourusername/nix-config/issues)
5. **Create a new issue with:**
   - Error message
   - Steps to reproduce
   - System information: `nix-info -m`
   - Recent changes: `git diff`

## Debug Commands

Useful commands for debugging:

```bash
# Check Nix version and features
nix --version
nix show-config | grep experimental

# Evaluate configuration
nix eval .#homeConfigurations.user@aarch64-darwin.config.home.username

# Build with debug output
nix build --show-trace --print-build-logs --verbose

# Check module options
nix repl
> :l <nixpkgs>
> :b home-manager.manual.manpage

# Verify flake
nix flake check --show-trace
nix flake metadata
nix flake show

# Test specific module
nix-instantiate --parse home/modules/example.nix
```

## Recovery

If everything is broken:

1. **Backup current state:**
```bash
cp -r ~/.config ~/.config.backup
cp -r ~/nix-config ~/nix-config.backup
```

2. **Reset to clean state:**
```bash
cd ~/nix-config
git stash
git checkout main
git pull origin main
```

3. **Rebuild from scratch:**
```bash
home-manager expire-generations "-0 seconds"
nix-collect-garbage -d
./sync-hm.sh
```

4. **Restore from backup if needed:**
```bash
cp -r ~/.config.backup/* ~/.config/
```
