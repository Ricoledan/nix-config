{ config, pkgs, lib, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    # LazyVim requires Neovim 0.8+
    package = pkgs.neovim-unwrapped;

    # Set up init.lua for LazyVim
    extraConfig = ''
      lua << EOF
      -- Bootstrap lazy.nvim
      local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
      if not vim.loop.fs_stat(lazypath) then
        vim.fn.system({
          "git",
          "clone",
          "--filter=blob:none",
          "https://github.com/folke/lazy.nvim.git",
          "--branch=stable",
          lazypath,
        })
      end
      vim.opt.rtp:prepend(lazypath)

      -- Use LazyVim starter
      require("lazy").setup({
        spec = {
          -- Import LazyVim plugins
          { "LazyVim/LazyVim", import = "lazyvim.plugins" },
          -- Import any extras modules here
          -- { import = "lazyvim.plugins.extras.lang.typescript" },
          -- { import = "lazyvim.plugins.extras.lang.json" },
          -- { import = "lazyvim.plugins.extras.ui.mini-animate" },
          -- Import/override with your plugins
          { import = "plugins" },
        },
        defaults = {
          lazy = false,
          version = false, -- always use the latest git commit
        },
        install = { colorscheme = { "tokyonight", "habamax" } },
        checker = { enabled = true }, -- automatically check for plugin updates
        performance = {
          rtp = {
            -- Disable some rtp plugins
            disabled_plugins = {
              "gzip",
              "tarPlugin",
              "tohtml",
              "tutor",
              "zipPlugin",
            },
          },
        },
      })
      EOF
    '';

    # Ensure required runtime dependencies are available
    extraPackages = with pkgs; [
      # Language servers
      lua-language-server
      nil # Nix LSP
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted # HTML, CSS, JSON, ESLint

      # Formatters
      stylua
      nixpkgs-fmt
      nodePackages.prettier

      # Tools
      ripgrep
      fd
      lazygit
      tree-sitter
      gcc # Required for treesitter compilation
    ];

    # Additional Lua configuration
    extraLuaConfig = ''
      -- LazyVim config
      vim.g.mapleader = " "
      vim.g.maplocalleader = "\\"

      -- Load LazyVim options
      require("lazyvim.config").init()
    '';

    # Plugin configuration directory structure
    plugins = with pkgs.vimPlugins; [
      # These will be managed by lazy.nvim, but we ensure they're available
      lazy-nvim
      LazyVim
      tokyonight-nvim
      catppuccin-nvim
      mini-nvim
      trouble-nvim
      which-key-nvim
      gitsigns-nvim
      vim-illuminate
      indent-blankline-nvim
      noice-nvim
      nui-nvim
      nvim-notify
      dressing-nvim
      bufferline-nvim
      lualine-nvim
      neo-tree-nvim
      nvim-web-devicons
      plenary-nvim
      telescope-nvim
      telescope-fzf-native-nvim
      flash-nvim
      nvim-treesitter
      nvim-treesitter-textobjects
      nvim-ts-context-commentstring
      nvim-ts-autotag
      nvim-cmp
      cmp-buffer
      cmp-path
      cmp-nvim-lsp
      cmp_luasnip
      luasnip
      friendly-snippets
      nvim-lspconfig
      neoconf-nvim
      neodev-nvim
      conform-nvim
      nvim-lint
      dashboard-nvim
      alpha-nvim
      persistence-nvim
    ];
  };

  # Ensure .config/nvim directory exists for custom plugin configurations
  xdg.configFile."nvim/lua/plugins/.gitkeep".text = "";

  # Add a simple custom plugin file as an example
  xdg.configFile."nvim/lua/plugins/example.lua".text = ''
    -- Example custom plugin configuration
    return {
      -- Add your custom plugins here
      -- {
      --   "github-user/plugin-name",
      --   config = function()
      --     -- Plugin configuration
      --   end,
      -- },
    }
  '';
}
