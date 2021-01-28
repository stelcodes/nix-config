{ stdenv, config, pkgs, ... }:
let
  #inherit (pkgs) stdenv;
  my-colorscheme = pkgs.vimUtils.buildVimPlugin {
    pname = "my-vim-colorscheme";
    name = "my-vim-colorscheme";
    src = builtins.fetchGit
      "https://github.com/stelcodes/neovim-colorscheme-generator";
  };

  stel-paredit = pkgs.vimUtils.buildVimPlugin {
    pname = "stel-paredit";
    version = "1.0";
    src = pkgs.fetchFromGitHub {
      owner = "stelcodes";
      repo = "paredit";
      rev = "27d2ea61ac6117e9ba827bfccfbd14296c889c37";
      sha256 = "1bj5m1b4n2nnzvwbz0dhzg1alha2chbbdhfhl6rcngiprbdv0xi6";
    };
  };

  tmux-zsh-environment = {
    name = "tmux-zsh-environment";
    src = pkgs.fetchFromGitHub {
      owner = "stelcodes";
      repo = "tmux-zsh-environment";
      rev = "780eff5ac781cc4a1cc9f1bd21bac92f57e34e48";
      sha256 = "0k2b9hw1zjndrzs8xl10nyagzvhn2fkrcc89zzmcw4g7fdyw9w9q";
    };
  };

  # Just stupid hard to package this so I'm waiting for someone else to do it
  # markdown-preview-raw = builtins.fetchGit "https://github.com/iamcco/markdown-preview.nvim";

  # markdown-preview-deps = pkgs.mkYarnPackage {
  #   name = "markdown-preview-deps";
  #   src = markdown-preview-raw;
  #   yarnLock = markdown-preview-raw + "/app/yarn.lock";
  #   packageJSON = markdown-preview-raw + "/app/package.json";
  # };

  # markdown-preview = pkgs.vimUtils.buildVimPlugin {
  #   pname = "markdown-preview";
  #   version = "0.0.9";
  #   src = markdown-preview-raw;
  #   buildInputs = [ markdown-preview-deps ];
  # };
  
  fzfExcludes = [".local" ".cache" "*photoslibrary" ".git" "node_modules" "Library" ".rustup" ".cargo" ".m2" ".bash_history"];
  # string lib found here https://git.io/JtIua
  fzfExcludesString = pkgs.lib.concatMapStrings (glob: " --exclude '${glob}'") fzfExcludes;

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
      # process monitor
      pkgs.htop
      # nerd font (doesn't work on mac?)
      (pkgs.nerdfonts.override { fonts = [ "Noto" ]; })
      # cross platform trash bin
      pkgs.trash-cli
      # alternative find, also used for fzf
      pkgs.fd
      # system info
      pkgs.neofetch
      # zsh prompt
      pkgs.starship
      # http client
      pkgs.httpie
      # download stuff from the web
      pkgs.wget
      pkgs.ripgrep


      # Other package managers
      pkgs.rustup
      # Run this:
      # rustup toolchain install stable
      # cargo install <package>

      pkgs.clojure
      pkgs.nodejs
      pkgs.postgresql
      pkgs.nixfmt

      # Not supported for mac:
      # babashka
      # clj-kondo
      # tor-broswer-bundle-bin
      # proton vpn
    ];

    # I'm putting all manually installed executables into ~/.local/bin 
    sessionPath = [ "$HOME/.cargo/bin" "$HOME/go/bin" "$HOME/.local/bin"];
  };

  fonts.fontconfig = { enable = true; };

  programs = {

    # Let Home Manager install and manage itself.
    home-manager.enable = true;
    
    # Just doesn't work. Getting permission denied error when it tries to read .config/gh
    # gh.enable = true;

    go = {
      enable = true;

    };

    lsd = {
      enable = true;
    };

    direnv = {
      enable = true;
      # I wish I could get nix-shell to work with clojure but it's just too buggy.
      # The issue: when I include pkgs.clojure in nix.shell and try to run aliased commands out of my deps.edn,
      # it errors with any alias using the :extra-paths.
      # enableNixDirenvIntegration = true;
    };

    zsh = {
      enable = true;
      autocd = true;
      dotDir = ".config/zsh";
      enableAutosuggestions = true;
      dirHashes = { desktop = "$HOME/Desktop"; };
      initExtraFirst = ". $HOME/.nix-profile/etc/profile.d/nix.sh";
      initExtra = ''
        # Initialize starship prompt
        eval "$(starship init zsh)"

        # From https://is.gd/M2fmiv
        zstyle ':completion:*' menu select
        zmodload zsh/complist

        # use the vi navigation keys in menu completion
        bindkey -M menuselect 'h' vi-backward-char
        bindkey -M menuselect 'k' vi-up-line-or-history
        bindkey -M menuselect 'l' vi-forward-char
        bindkey -M menuselect 'j' vi-down-line-or-history
        '';
      shellAliases = {
        "nix-search" = "nix repl '<nixpkgs>'";
        "source!" = "source $HOME/.config/zsh/.zshrc";
        "switch" = "home-manager switch && source $HOME/.config/zsh/.zshrc";
        "hg" = "history | grep";
        "ls" = "${pkgs.lsd}/bin/lsd --color always -A";
        "lsl" = "${pkgs.lsd}/bin/lsd --color always -lA";
        "lst" = "${pkgs.lsd}/bin/lsd --color always --tree -A -I \".git\"";
      };
      plugins = [ 
        tmux-zsh-environment
      ];
      oh-my-zsh = {
        enable = true;
        plugins = [
          # docker completion
          "docker"
          # self explanatory
          "colored-man-pages"
          # completion + https command
          "httpie"
          # pp_json command
          "jsontools"
        ];
        # I like minimal, mortalscumbag, refined, steeef
        #theme = "mortalscumbag";
        extraConfig = ''
          bindkey '^[c' autosuggest-accept
        '';
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
          plugin = nord-vim;
          config = "colorscheme nord";
        }
        {
          plugin = stel-paredit;
          config = "let g:paredit_smartjump=1";
        }
        # See top of file
        # {
        #   plugin = markdown-preview;
        #   config = ''
        #     '';
        # }
      ];
      extraConfig = (builtins.readFile ./extra-config.vim) + ''

        set shell=${pkgs.zsh}/bin/zsh'';
    };

    bat = {
      enable = true;
      config = { theme = "base16"; };
    };

    alacritty = { enable = true; };

    git = {
      enable = true;
      userName = "Stel Abrego";
      userEmail = "stel@stel.codes";
      ignores = [ "*Session.vim" "*.DS_Store" "*.swp" "*.direnv" "/direnv" ];
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
      prefix = "M-a";
      # Set to "tmux-256color" normally, but theres this macOS bug https://git.io/JtLls
      terminal = "screen-256color";
      extraConfig = ''
        set -ga terminal-overrides ',xterm-256color:Tc'
        set -as terminal-overrides ',xterm*:sitm=\E[3m'

        # Switch windows
        bind -n M-h  previous-window
        bind -n M-l next-window
        bind M-a next-window

        # Kill active pane
        bind -n M-x kill-pane

        # Detach from session
        bind -n M-d detach

        # New window
        bind -n M-f new-window

        # See all windows in all sessions
        bind -n M-s choose-tree -s

        # Fixes tmux escape input lag, see https://git.io/JtIsn
        set -sg escape-time 10

        # Update environment
        set-option -g update-environment "PATH"
      '';
      plugins = [
        pkgs.tmuxPlugins.nord
        {
          plugin = pkgs.tmuxPlugins.resurrect;
          extraConfig = "set -g @resurrect-strategy-nvim 'session'";
        }
        {
          plugin = pkgs.tmuxPlugins.continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '5' # minutes
          '';
        }
        {
          plugin = pkgs.tmuxPlugins.fzf-tmux-url;
          extraConfig = "set -g @fzf-url-bind 'u'";
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
      defaultOptions = [ "--height 80%" "--reverse"];
      defaultCommand = "fd --type f --hidden ${fzfExcludesString}";
      changeDirWidgetCommand = "fd --type d --hidden ${fzfExcludesString}";
      # I got tripped up because home.sessionVariables do NOT get updated with zsh sourcing.
      # They only get updated by restarting terminal, this is by design from the nix devs
      # See https://git.io/JtIuV
    };

    # Not supported for Mac:
    # firefox

  };

  xdg.configFile."alacritty/alacritty.yml".text = pkgs.lib.mkMerge [
    ''
      shell:
        program: ${pkgs.zsh}/bin/zsh''
    (builtins.readFile ./alacritty-base.yml)
    (builtins.readFile ./alacritty-nord.yml)
  ];
}
