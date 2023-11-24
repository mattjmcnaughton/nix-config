{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # Could use imports to split up if I wanted...

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
      permittedInsecurePackages = [
        "electron-24.8.6"
      ];
    };
  };

  home = {
    username = "mattjmcnaughton";
    homeDirectory = "/home/mattjmcnaughton";

    packages = with pkgs;
      [
        bitwarden-cli
        docker-compose
        ffmpeg
        libreoffice-qt # Because using KDE.
        just
        obsidian
        parallel
        podman-compose
        spotify
        telegram-desktop

        # TODO: Explore more...
        pre-commit
        fd # https://github.com/sharkdp/fd
        alejandra
        bat
        gh
        htop
        jq
        ripgrep
        tree
        watch
        exa
        unzip

        tailscale
        chromium
        firefox
        zathura

        zoom-us

        # TODO: Need a tool for managing clipboard.

        # Any dev-specific tools will go in a `shell.nix` or `flake.nix` dev profile.
      ]
      ++ [
        inputs.agenix.packages.x86_64-linux.default
      ];

    stateVersion = "23.05";
  };

  programs.home-manager.enable = true;

  # Configuration parameters listed here:
  # https://nix-community.github.io/home-manager/options.html#opt-programs.bash.enable
  programs.bash = {
    enable = true;

    sessionVariables = {
      EDITOR = "vim";
    };

    initExtra = ''
      __blue="\033[0;36m"
      __yellow="\033[0;33m"
      __nc="\033[0m"

      __parse_git_branch() {
        git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
      }

      export PS1="\h:''${__blue}\W''${__nc}''${__yellow}\$(__parse_git_branch) ''${__nc}\$ "
    '';

    shellAliases = {
      ls = "exa";
      ag = "rg";
      more = "bat";

      # TODO: Set up a alias for pbcopy/xclip/...
    };
  };

  programs.git = {
    enable = true;
    userName = "mattjmcnaughton";
    userEmail = "me@mattjmcnaughton.com";

    ignores = [
      "*.swp"
    ];

    #signing = {
    # Will change from machine to machine... based on the PGP subkey built for `signing`...
    #key = "B296E12A331AF446!";
    #signByDefault = true;
    #};

    aliases = {
      ff = "merge --ff-only";
    };

    extraConfig = {
      init.defaultBranch = "main";
    };
  };

  programs.gpg = {
    enable = true;

    # Will us gpg2 by default... don't need to specify a specific package version.

    # TODO: Copy the gpg-helper script to ... somewhere...
  };

  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "tty";
  };

  programs.firefox = {
    enable = true;
  };

  # Configuration parameters listed here:
  # https://nix-community.github.io/home-manager/options.html#opt-programs.tmux.enable
  programs.tmux = {
    enable = true;

    prefix = "C-a";

    terminal = "screen-256color";

    keyMode = "vi";
    mouse = true;

    baseIndex = 1;

    sensibleOnTop = true; # https://github.com/tmux-plugins/tmux-sensible

    extraConfig = ''
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
    '';
  };

  programs.direnv = {
    enable = true;
  };

  programs.vim = {
    enable = true;
  };

  # https://nix-community.github.io/home-manager/options.html#opt-programs.alacritty.enable
  programs.alacritty = {
    enable = true;

    settings = {
      env.TERM = "xterm-256color";
      env.WINIT_X11_SCALE_FACTOR = "1.00"; # TBD if can delete this post switch to Wayland.
      font.size = 8;
    };
  };

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
    ];
  };

  programs.fzf = {
    enable = true;
  };

  systemd.user.startServices = "sd-switch";
}
