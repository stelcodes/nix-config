{ stdenv, config, pkgs, ... }:
let
  #inherit (pkgs) stdenv;
  my-colorscheme = pkgs.vimUtils.buildVimPlugin {
    pname = "my-vim-colorscheme";
    name = "my-vim-colorscheme";
    src = builtins.fetchGit
      "https://github.com/stelcodes/neovim-colorscheme-generator";
  };

in {

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home = {
    username = "stel";
    homeDirectory = "/Users/stel";

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "21.03";

    packages = [
      pkgs.htop
      pkgs.tree
      (pkgs.nerdfonts.override { fonts = [ "Noto" ]; })
      pkgs.trash-cli
      pkgs.fd
      pkgs.neofetch

      # Other package managers
      pkgs.rustup
      # Run this:
      # rustup toolchain install stable
      # cargo install <package>

      # Dev tools
      pkgs.clojure
      pkgs.nixfmt
      # Not supported for mac:
      # babashka
      # tor-broswer-bundle-bin
    ];

    sessionPath = [ "$HOME/.cargo/bin" ];
  };

  fonts.fontconfig = { enable = true; };

  programs = {

    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    direnv = {
      enable = true;
      enableNixDirenvIntegration = true;
    };

    zsh = {
      enable = true;
      autocd = true;
      dotDir = ".config/zsh";
      enableAutosuggestions = true;
      dirHashes = { desktop = "$HOME/Desktop"; };
      initExtraBeforeCompInit = ". $HOME/.nix-profile/etc/profile.d/nix.sh";
      shellAliases = {
        "nix-search" = "nix repl '<nixpkgs>'";
        "source!" = "source $HOME/.config/zsh/.zshrc";
        "switch!" = "home-manager switch && source $HOME/.config/zsh/.zshrc";
      };
      oh-my-zsh = {
        enable = true;
        theme = "muse";
      };
    };

    neovim = {
      enable = true;
      vimAlias = true;
      plugins = with pkgs.vimPlugins; [
        nerdtree
        vim-obsession
        vim-commentary
        vim-dispatch
        vim-projectionist
        vim-eunuch
        vim-fugitive
        vim-sensible
        vim-nix
        lightline-vim
        conjure
        vim-fish
        vim-css-color
        tabular
        vim-gitgutter
        {
          plugin = vim-auto-save;
          config = "let g:auto_save = 1";
        }
        {
          plugin = ale;
          config = "let g:ale_linters = {'clojure': ['clj-kondo']}";
        }
        {
          plugin = my-colorscheme;
          config = "colorscheme hydrangea";
        }
      ];
      extraConfig = (builtins.readFile ./extra-config.vim) + ''

        set shell=${pkgs.zsh}/bin/zsh'';
    };

    bat = { enable = true; };

    alacritty = {
      enable = true;
      settings = {
        font = {
          size = 22;
          normal = {
            family = "FiraCode Nerd Font Mono";
            style = "Regular";
          };
        };
        shell.program = "${pkgs.zsh}/bin/zsh";
        window.padding = {
          x = 2;
          y = 2;
        };
      };
    };

    git = {
      enable = true;
      userName = "Stel Abrego";
      userEmail = "stel@stel.codes";
      ignores = [ "*Session.vim" "*.DS_Store" "*.swp" ];
      extraConfig = { init = { defaultBranch = "main"; }; };
    };

    rtorrent = { enable = true; };

    tmux = {
      enable = true;
      baseIndex = 1;
      clock24 = true;
      keyMode = "vi";
      newSession = true;
      shell = "${pkgs.zsh}/bin/zsh";
      shortcut = "a";
      terminal = "xterm-256color";
      plugins = with pkgs; [
        tmuxPlugins.cpu
        {
          plugin = tmuxPlugins.resurrect;
          extraConfig = "set -g @resurrect-strategy-nvim 'session'";
        }
        {
          plugin = tmuxPlugins.continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '5' # minutes
          '';
        }
        {
          plugin = tmuxPlugins.nord;
        }
		# {
		# 	plugin = tmuxPlugins.dracula;
		# 	extraConfig = ''
		# 		set -g @dracula-show-battery false
		# 		set -g @dracula-show-powerline true
		# 		set -g @dracula-refresh-rate 10 '';
		# }
      ];
    };

    fzf = {
      enable = true;
      defaultOptions = [ "--height 40%" "--border" ];
      defaultCommand =
        "fd --type f --hidden --exclude Photos\\ Library.photoslibrary --exclude .cache --exclude Library --exclude .git --exclude .local";
    };

    # Not supported for Mac:
    # firefox

  };
}
