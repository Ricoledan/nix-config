{ config, pkgs, lib, ... }:

{
  programs.git = {
    enable = true;

    # User configuration - will be overridden by git config if already set
    userName = lib.mkDefault "Rico Oledan";
    userEmail = lib.mkDefault "rico@example.com"; # Update with your email

    # Core git settings
    extraConfig = {
      init.defaultBranch = "main";

      core = {
        editor = "nvim";
        autocrlf = "input";
      };

      pull = {
        rebase = true;
        ff = "only";
      };

      push = {
        default = "current";
        autoSetupRemote = true;
      };

      merge = {
        conflictstyle = "diff3";
      };

      diff = {
        colorMoved = "default";
      };

      rerere = {
        enabled = true;
      };

      # Better diffs
      delta = {
        enable = lib.mkDefault false; # Enable if you want delta diff viewer
        options = {
          navigate = true;
          line-numbers = true;
          syntax-theme = "Dracula";
        };
      };
    };

    # Git aliases
    aliases = {
      # Status and info
      st = "status";
      s = "status -s";

      # Committing
      c = "commit";
      cm = "commit -m";
      ca = "commit --amend";
      can = "commit --amend --no-edit";

      # Branching
      br = "branch";
      co = "checkout";
      cob = "checkout -b";

      # Pushing/Pulling
      p = "push";
      pf = "push --force-with-lease";
      pl = "pull";

      # Logging
      lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      lga = "log --graph --all --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      last = "log -1 HEAD";

      # Diffing
      d = "diff";
      dc = "diff --cached";
      ds = "diff --staged";

      # Stashing
      ss = "stash save";
      sp = "stash pop";
      sl = "stash list";

      # Reset
      unstage = "reset HEAD --";
      undo = "reset --soft HEAD~1";

      # Clean
      cleanup = "!git branch --merged | grep -v '\\*\\|main\\|master\\|develop' | xargs -n 1 git branch -d";
    };

    # Ignore global patterns
    ignores = [
      ".DS_Store"
      "*.swp"
      "*.swo"
      "*~"
      ".idea"
      ".vscode"
      "*.iml"
      ".direnv"
      "result"
      "result-*"
    ];
  };

  # GitHub CLI configuration
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
      editor = "nvim";
    };
  };
}
