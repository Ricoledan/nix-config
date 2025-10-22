{ config, pkgs, lib, ... }:

{
  programs.zsh.initExtra = lib.mkAfter ''
    # Load secrets from 1Password
    load_secrets() {
      if command -v op &> /dev/null && op account get &>/dev/null; then
        export CONTEXT7_API_KEY=$(op read "op://Private/Context7 API Key/credential" 2>/dev/null)
      fi
    }

    # Function to check which secrets are loaded
    check_secrets() {
      echo "🔍 Checking loaded secrets:"
      [[ -n "$CONTEXT7_API_KEY" ]] && echo "  ✅ Context7" || echo "  ❌ Context7"
    }

    # Load secrets automatically
    load_secrets
  '';

  # Shell aliases for secret management
  programs.zsh.shellAliases = {
    secrets-check = "check_secrets";
    secrets-reload = "load_secrets";
  };
}
