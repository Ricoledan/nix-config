# Architectural Decisions

This document records significant architectural decisions made in this project, including the rationale behind
them and any trade-offs involved.

For the core principles that guide these decisions, see the [Core Principles section in README.md](README.md#core-principles).

## Decision Log

### 2025-08-12: Use Homebrew for Podman on macOS

**Status**: Accepted

**Context**:

- We initially tried to manage Podman through Nix for consistency and reproducibility
- The Nix podman package on macOS lacks `podman-mac-helper`, which is required for:
  - Binding to privileged ports (< 1024)
  - Proper macOS system integration
  - Podman Desktop compatibility
- Podman Desktop looks for the CLI in specific hardcoded paths that don't include Nix's installation directory

**Decision**:
Use Homebrew to manage Podman, podman-compose, and Podman Desktop on macOS while keeping other tools in Nix.

**Consequences**:

- ✅ Full Podman functionality including privileged operations
- ✅ Seamless Podman Desktop integration
- ✅ No manual workarounds or symlinks required
- ❌ Split package management between Nix and Homebrew
- ❌ Less reproducible than pure Nix solution

**Alternatives Considered**:

1. Extract podman-mac-helper from official installer - Too complex and fragile
2. Create symlinks to expected paths - Requires manual sudo intervention
3. Use wrapper scripts - Doesn't solve all integration issues

**References**:

- [Detailed analysis in docs/podman.md](docs/podman.md)

---

### 2025-12-17: Use Nix for Podman on Linux

**Status**: Accepted

**Context**:

- Podman is managed via Homebrew on macOS due to integration issues (see above decision)
- On Linux, the Nix podman package works correctly without the limitations present on macOS
- The repository's core principle is "Nix-first" for cross-platform tools
- Zsh configuration sets `DOCKER_HOST` to the podman socket on all platforms

**Decision**:
Use Nix to manage Podman on Linux while continuing to use Homebrew for macOS.

**Consequences**:

- ✅ Follows "Nix-first" principle where possible
- ✅ Full reproducibility on Linux via Nix
- ✅ No special integration workarounds needed on Linux
- ✅ Consistent container tooling across both platforms (same binary, different installation method)
- ❌ Split package management between platforms (expected trade-off)

**Implementation**:
- Podman added to Linux-specific packages in `home/modules/platform/linux.nix`
- macOS continues to use Homebrew (Brewfile)
- Both platforms use the same zsh configuration with DOCKER_HOST set to podman socket

---

### 2025-11-09: Use Homebrew for VSCode on macOS

**Status**: Accepted

**Context**:

- VSCode was managed through Nix, which packages GUI apps as `.app` bundles
- macOS protects application bundles with special permissions that prevent Nix from properly cleaning them up during
  garbage collection
- This causes persistent "Operation not permitted" errors when running `nix-collect-garbage`
- The repository already uses Homebrew for other macOS GUI applications (Ghostty, Alfred, Obsidian, etc.)

**Decision**:
Use Homebrew to manage VSCode on macOS while keeping CLI development tools in Nix.

**Consequences**:

- ✅ No more macOS permission errors during Nix garbage collection
- ✅ Consistent with existing pattern of using Homebrew for GUI apps
- ✅ Better integration with macOS application management
- ❌ Split package management between Nix and Homebrew
- ❌ Less reproducible than pure Nix solution

**Alternatives Considered**:

1. Ignore the error - Harmless but clutters output and leaves orphaned store paths
2. Manual cleanup - Requires sudo intervention and isn't automated
3. Keep using Nix - Continues to cause permission errors on every garbage collection

---

### 2025-10-22: Pin Atuin to Stable Nixpkgs

**Status**: Superseded

**Context**:

- CI builds failing due to Ruby/Nokogiri compilation issues in latest nixpkgs-unstable
- The failure chain: nokogiri → ronn → bats → bash-preexec → Home Manager build failure
- Atuin (shell history tool) was transitively depending on these Ruby-based tools
- Blocking all configuration updates and deploys

**Decision**:
Pin Atuin specifically to stable nixpkgs (24.05) while keeping all other packages on unstable.

**Consequences**:

- ✅ CI builds pass immediately
- ✅ Atuin functionality preserved
- ✅ Other packages stay on latest versions
- ✅ No user-facing changes
- ❌ Mixed package sources (stable + unstable)
- ❌ Additional complexity in flake.nix

**Alternatives Considered**:

1. Pin entire nixpkgs to stable - Too conservative, loses latest packages
2. Disable Atuin temporarily - Loses valuable shell history functionality
3. Wait for upstream fix - Blocks development indefinitely
4. Override Ruby/Nokogiri versions - Too complex and fragile

---

### 2025-10-22: Temporarily Disable Bash Integration to Fix Ruby/Nokogiri Build

**Status**: Accepted

**Context**:

- Home Manager build failing due to Ruby/Nokogiri compilation issues on macOS ARM64
- Dependency chain: `home-manager → bashrc → bash-preexec → bats → flock → ronn → nokogiri`
- The `programs.bash.enable = true` setting in `home.nix` triggers bash-preexec installation
- bash-preexec depends on bats (testing framework) which requires ronn (Ruby-based documentation tool)
- ronn depends on nokogiri (Ruby XML parser) which fails to compile on macOS with newer Clang

**Decision**:
Temporarily disable bash integration by commenting out `programs.bash.enable = true` in `home/home.nix`.

**Consequences**:

- ✅ Immediate fix for CI/build failures
- ✅ All other tools and configurations remain intact
- ✅ Zsh (primary shell) continues to work perfectly
- ❌ No bash-specific integrations or customizations
- ❌ Temporary loss of bash compatibility features

**Alternatives Considered**:

1. Pin bash-preexec to stable nixpkgs - Complex override required, may not fix underlying issue
2. Override nokogiri/Ruby versions - Too invasive and fragile
3. Switch entire nixpkgs to stable - Too conservative, loses access to latest packages
4. Find alternative to bash-preexec - Would require significant research and testing

**Update 2025-10-22**: This decision was superseded by disabling bash integration entirely, which was the
actual root cause. Atuin now uses unstable nixpkgs again.

**Next Steps**:

- Monitor upstream nixpkgs for nokogiri/Ruby fixes on macOS ARM64
- Re-enable bash integration once the issue is resolved upstream
- Consider alternative bash integration approaches if issue persists

---

## Template for New Decisions

### YYYY-MM-DD: [Decision Title]

**Status**: [Proposed | Accepted | Deprecated | Superseded]

**Context**:
[What is the issue that we're seeing that is motivating this decision?]

**Decision**:
[What is the change that we're proposing and/or doing?]

**Consequences**:

- ✅ [Positive consequences]
- ❌ [Negative consequences]

**Alternatives Considered**:
[What other options were considered and why were they rejected?]

**References**:
[Links to related documentation, issues, or discussions]
