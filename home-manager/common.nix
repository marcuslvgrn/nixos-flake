{
#  config,
  lib,
  inputs,
  nixosConfig,
  userConfig,
#  pkgs,
#  pkgs-stable,
  pkgs-unstable,
  ...
}:

{
  imports = [
    ./dconf.nix
    inputs.nixvim.homeModules.nixvim
  ];

  programs.firefox = lib.mkIf nixosConfig.programs.firefox.enable {
    #Let home-manager manage firefox, but only when installed in nixos
    enable = true;

    languagePacks = [
      "sv-SE"
      "en-US"
    ];

    policies = {
      DisableFirefoxAccounts = true;
      DisableSync = true;
    };

    profiles.default = {
      name = "default";
      isDefault = true;
      search = {
        force = true;
        default = "ddg";
      };
      extensions.packages = with pkgs-unstable.nur.repos.rycee.firefox-addons; [
        ublock-origin
        bitwarden
        i-dont-care-about-cookies
        istilldontcareaboutcookies
        gnome-shell-integration
        duckduckgo-privacy-essentials
        floccus
        proton-pass
      ];
      settings = {
        "intl.locale.requested" = "sv-SE,en-US";
        "browser.startup.page" = 3;
        "browser.sessionstore.resume_from_crash" = true;
        "extensions.install.requireBuiltInCerts" = false;
        "extensions.autoDisableScopes" = 0;
        "browser.translations.neverTranslateLanguages" = "en,en-US,en-GB";
        "signon.rememberSignons" = false;
        "datareporting.healthreport.uploadEnabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;
        "extensions.pocket.enabled" = false;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.unified" = false;
      };
    };
  };

  home = {
    username = userConfig.username;
    homeDirectory = lib.mkDefault "/home/${userConfig.username}";
    sessionVariables = {
      LANG = "sv_SE.UTF-8";
      #      XDG_DATA_DIRS = lib.mkMerge [
      #        (lib.mkDefault "/run/current-system/sw/share")
      #        (lib.mkIf (config.home.username != null)
      #          "/etc/profiles/per-user/${config.home.username}/share")
      #      ];
      #      GSETTINGS_SCHEMA_DIR = "/run/current-system/sw/share/glib-2.0/schemas";
    };
    shellAliases = {
      ll = "ls -lah";
      ls = "ls --color=tty";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gps = "git push";
      gpl = "git pull";
      gd = "git diff";
      rebuild = lib.mkDefault "nixos-rebuild switch --flake ~/git/nixos-flake";
      sudo = "sudo ";
    };
    stateVersion = "25.05";
  };

  programs.bash = {
    enable = true;
    initExtra = ''
      export LANG="en_US.UTF-8"
      export LC_MESSAGES="en_US.UTF-8"
    '';
  };

  programs.zsh = {
    enable = true;
    initContent = ''
      export LANG="en_US.UTF-8"
      export LC_MESSAGES="en_US.UTF-8"
    '';
  };

  programs.git = {
    enable = true;
    settings.user.email = "${userConfig.email}";
    settings.user.name = "${userConfig.gituser}";
  };

  programs.nixvim = {
    enable = true;
    vimAlias = true;
    viAlias = true;
    globals.mapleader = " ";

    colorschemes.catppuccin.enable = true;
    plugins = {
      #      oil.enable = true;
      #      conform_nvim = {
      #        enable = true;
      #        ft = [ "nix" ];
      #        # Tell it to format nix files with nixfmt
      #        formattersByFt = {
      #          nix = [ "nixfmt" ];
      #        };
      #
      #        # Optional: auto-format on save
      #        formatOnSave = {
      #          enable = false;
      #        };
      #      };
      gitsigns = {
        enable = true;
        settings = {
          current_line_blame = true;
          current_line_blame_opts = {
            delay = 0;
            virt_text_opts = "eol";
          };
        };
      };
      "indent_blankline" = {
        enable = true;
        settings = {
          indent = {
            char = " ";
            tab_char = " ";
          };
        };
      };
      lazygit = {
        enable = true;
        settings = {
          floating_window_winblend = 0;
          floating_window_scaling_factor = 0.9;
        };
      };
      lsp = {
        enable = true;
        servers = {
          lua_ls.enable = true;
          nixd.enable = true;
        };
      };
      lualine.enable = true;
      lua_snip.enable = true;
      nvim_cmp = {
        enable = true;

        snippet_support = true; # allows LuaSnip snippets
        sources = {
          lsp = true; # completions from LSP
          buffer = true; # completions from buffer text
          path = true; # completions from file paths
          luasnip = true; # snippet completions
        };
      };
      ripgrep.enable = true;
      telescope = {
        enable = true;
      };
      #      nvim-tree.enable = true;
      neo-tree = {
        enable = true;
        settings = {
          filesystem = {
            follow_current_file = {
              enabled = true;
            };

            hijack_netrw_behavior = "open_default";
            use_libuv_file_watcher = true;
          };

          buffers = {
            show_unloaded = true; # shows buffers not loaded into memory
            follow_current_file = true;
          };

          window = {
            position = "left";
            width = 30;
          };
        };
        auto_open = true;
      };
      treesitter.enable = true;
      web-devicons.enable = true;
    };
    extraInit = ''
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd() })
      end
    '';
    extraPlugins = [

    ];
    opts = {
      number = true;
      relativenumber = true;
      cursorline = true;
      shiftwidth = 2;
      tabstop = 2;
      softtabstop = 2;
      expandtab = true;
      autoindent = true;
      smartindent = true;
      guifont = "FiraCodeNerdFontMono-Regular";
    };
    keymaps = [
      {
        mode = "n";
        key = "<leader>wa";
        action = ":wa<CR>";
        options.silent = false;
      }
      {
        mode = "n";
        key = "<leader>w";
        action = ":w<CR>";
        options.silent = false;
      }
      {
        mode = "n";
        key = "<leader>q";
        action = ":q<CR>";
        options.silent = false;
      }
      {
        mode = "n";
        key = "<leader>ff";
        action = "<cmd>Telescope find_files<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>fb";
        action = "<cmd>Telescope buffers<CR>";
        options.silent = false;
      }
      {
        mode = "n";
        key = "<leader>nt";
        action = "<cmd>Neotree toggle<CR>";
        options.silent = false;
      }
      {
        mode = "n";
        key = "<leader>ntb";
        action = "<cmd>Neotree buffers toggle<CR>";
        options.silent = false;
      }
      {
        mode = "n";
        key = "<leader>f";
        action = "<cmd>lua local pos = vim.api.nvim_win_get_cursor(0); vim.cmd('%!nixfmt'); vim.api.nvim_win_set_cursor(0, pos)<CR>";
        options.desc = "Format current buffer";
      }
#      {
#        mode = "i";
#        key = "<Tab>";
#        action = "v:lua.require('cmp').visible() and require('cmp').confirm({select = true}) or require('luasnip').expand_or_jumpable() and '<Plug>luasnip-expand-or-jump' or '<Tab>'";
#        options.expr = true;
#        options.silent = true;
#      }
      {
        mode = "s";
        key = "<Tab>";
        action = "<Plug>luasnip-expand-or-jump";
      }
    ];
  };

  #  programs.neovim = {
  #    enable = true;
  #    viAlias = true;
  #    vimAlias = true;
  #    extraLuaConfig = ''
  #      vim.opt.autoindent = true
  #    '';
  #    plugins = with pkgs.vimPlugins; [
  #      nvim-treesitter
  #      nvim-lspconfig
  #    ];
  #  };

  programs.home-manager.enable = true;

}
