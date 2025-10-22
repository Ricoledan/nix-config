# Architectural Decisions

This document records significant architectural decisions made in this project, including the rationale behind them and any trade-offs involved.

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

### 2025-10-22: Pin Atuin to Stable Nixpkgs

**Status**: Accepted

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
