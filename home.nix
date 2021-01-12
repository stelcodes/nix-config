{ stdenv, config, pkgs, ... }:
let
  #inherit (pkgs) stdenv;
  my-colorscheme = pkgs.vimUtils.buildVimPlugin {
    name = "my-vim-colorscheme";
    src = builtins.fetchGit https://github.com/stelcodes/neovim-colorscheme-generator;
  };

in 
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "stel";
  home.homeDirectory = "/Users/stel";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.03";

  home.packages = [
    pkgs.htop
    pkgs.tree
    (pkgs.nerdfonts.override { fonts = ["Noto"]; })
  ];

  fonts.fontconfig = {
    enable = true;
  };

  programs = {
    # Firefox not supported for x86 Darwin ;-;

    zsh = {
      enable = true;
      autocd = true;
      dotDir = ".config/zsh";
      enableAutosuggestions = true;
      dirHashes = {
        desktop = "$HOME/Desktop";
      };
      initExtraBeforeCompInit = ''. $HOME/.nix-profile/etc/profile.d/nix.sh'';
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
        { plugin = vim-auto-save; config = "let g:auto_save = 1"; }
        { plugin = ale; config = "let g:ale_linters = {'clojure': ['clj-kondo']}"; }
        my-colorscheme
      ];
      extraConfig = (builtins.readFile ./extra-config.vim) + "\nset shell=${pkgs.zsh}/bin/zsh";
    };

    bat = {
      enable=true;
    };

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
    };

  };
}
