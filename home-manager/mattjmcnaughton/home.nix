{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let
  wallpaper = pkgs.copyPathToStore ./assets/wallpaper-coding-pug-1920-1080.jpg;
in {
  # Could use imports to split up if I wanted...

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
      permittedInsecurePackages = [
        "electron-24.8.6"
        "electron-25.9.0"
      ];
    };
  };

  home = {
    username = "mattjmcnaughton";
    homeDirectory = "/home/mattjmcnaughton";

    packages = with pkgs;
      [
        # Unstable
        unstable.neovim
        unstable.vscode
        unstable.zed-editor
        unstable.code-cursor

        # Stable
        bitwarden-cli
        docker-compose
        ffmpeg
        mpv
        imagemagick
        libreoffice
        just
        obsidian
        parallel
        podman-compose
        spotify
        telegram-desktop

        # TODO: Explore more...
        pre-commit
        fd # https://github.com/sharkdp/fd
        bat
        gh
        htop
        jq
        ripgrep
        tree
        watch
        eza
        unzip
        lsof
        dig
        wget
        nmap
        rpi-imager # Create raspberry pi images - run with `sudo -E`

        # Afaik, we just need to install the tools and ebpf should work
        # out of the box.
        bpftools
        bcc

        chromium

        awscli2 # Could use `programs.awscli`, but would need a different mechanism for specifying creds.

        zathura
        feh

        pamixer # mixer for usage w/ pulseaudio (`pamixer --get-volume` and `pamixer --set-volume`)
        bluetui # tui for bluetooth

        zoom-us

        alejandra
        shellcheck

        python312 # `uv` cannot manage python versions on Nix
        uv

        go # v1.23 as of NixOS 24.11

        tenv # Version manager for Terraform, OpenTofu, etc.

        ollama

        # sway/wayland tools (that don't have `programs/services`)
        wl-clipboard
        wlr-randr # TODO: Determine if better tool we could use.
        shotman # TODO: Determine if there's a better screen-capture tool.

        # There's probably a more declarative way we could do this... but for
        # now, I'm not super concerned.
        #
        # Working from https://www.ertt.ca/nix/shell-scripts/
        (writeScriptBin "gpg-helper.sh" (builtins.readFile ./scripts/gpg-helper.sh))
        (writeScriptBin "aws-mfa-auth.sh" (builtins.readFile ./scripts/aws-mfa-auth.sh))
        (writeScriptBin "aws-utils.sh" (builtins.readFile ./scripts/aws-utils.sh))

        # Any dev-specific tools will go in a `shell.nix` or `flake.nix` dev profile.
      ]
      ++ [
        inputs.agenix.packages.x86_64-linux.default
      ]
      ++ [
        inputs.ghostty.packages.x86_64-linux.default
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

      # We will need to create ~/.local/bin if it doesn't exist.
      # We do this for a place to store "custom" binaries (i.e. installed via
      # `tfswitch`).
      # todo: Determine if a better way to do it.
      export PATH=$PATH:~/.local/bin
    '';

    shellAliases = {
      ls = "eza";
      ag = "rg";
      more = "bat";

      terraform = "tofu";

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

    signing = {
      key = "BC530981A9A1CC9D";
      signByDefault = true;
    };

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
    pinentryPackage = pkgs.pinentry-tty;
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

  # https://nix-community.github.io/home-manager/options.html#opt-programs.vim.enable
  programs.vim = {
    enable = true;

    defaultEditor = true;

    # Custom .vimrc lines...
    #
    # NOT stored in `~/.vimrc` or `~/.config`.
    # Can run `:scriptnames` to find the current `vimrc`... its part of the
    # nix-store.
    #
    # This is actually cool, because I _think_ it means that my `shell.nix`
    # could define per project vims, including specific config, plugins, etc...
    #
    # This ability would allow fancier "per-project" vims and my base vim to
    # stay quite simple.
    extraConfig = builtins.readFile ./dotfiles/vimrc;

    # Search via `nix-env -f '<nixpkgs>' -qaP -A vimPlugins
    plugins = [
      # TODO: Review all of these plugins...

      # TODO: Set-up shortcuts for fzf-vim that mirror `ctrl-p` and `ag`.
      pkgs.vimPlugins.fzf-vim
      pkgs.vimPlugins.vim-commentary

      # TODO: Additional plugins such as:
      # ale (linters)
      # Language specific plugins (i.e. for python, Go... but also could be per-project...)
      # Auto-completion/IntelliSense
      # Snippets
      # vim-fugitive
      # EasyAlign
      # Stuff from `junegunn` and `tpope`
      # TODO: Look at https://github.com/mitchellh/nixos-config/blob/main/users/mitchellh/home-manager.nix for plugin ideas.
    ];
  };

  programs.fzf = {
    enable = true;
  };

  # Copy the lock-screen image to `~/.lock-screen.jpg`.
  home.file.".lock-screen.jpg".source = ./assets/wallpaper-coding-sleeping-pug-1920-1080.jpg;

  # Source ghostty config file
  xdg.configFile."ghostty/config".source = ./dotfiles/ghostty/config;

  wayland.windowManager.sway = {
    enable = true;

    config = {
      modifier = "Mod1"; # Left alt key...

      terminal = "${inputs.ghostty.packages.x86_64-linux.default}/bin/ghostty";
      menu = "${pkgs.wofi}/bin/wofi --show run";

      input = {
        # Get the "ids" via running `swaymsg -t get_inputs`
        #
        # Anker mouse
        "1578:16642:MOSART_Semi._2.4G_Wireless_Mouse" = {
          natural_scroll = "enabled";
        };

        # Dell XPS mouse
        "1739:30383:DELL07E6:00_06CB:76AF_Touchpad" = {
          natural_scroll = "enabled";
        };

        # Thinkpad/XPS13 keyboard...
        "1:1:AT_Translated_Set_2_keyboard" = {
          xkb_options = "caps:swapescape";
        };
      };

      output = {
        "*" = {
          bg = "${wallpaper} fill";
        };
      };

      # TODO: add `startup` config -
      # https://rycee.gitlab.io/home-manager/options.html#opt-wayland.windowManager.sway.config.startup.
    };

    # TODO: Should `wrapperFeatures.gtk = true`?

    # TODO: Can we move some (all) of this into the home-manager config...
    extraConfig = builtins.readFile ./dotfiles/sway/config;
  };

  programs.swaylock = {
    enable = true;

    # PAM should be configured by default - see
    # https://rycee.gitlab.io/home-manager/options.html#opt-programs.swaylock.enable.
  };

  services.mako = {
    enable = true;
  };

  services.swayidle = {
    enable = true;

    events = [
      {
        event = "before-sleep";
        command = "${pkgs.swaylock}/bin/swaylock -f";
      }
    ];

    timeouts = [
      {
        timeout = 3600; # 1 hour
        command = "${pkgs.swaylock}/bin/swaylock -fF";
      }
    ];
  };

  programs.wofi = {
    enable = true;
  };

  systemd.user.startServices = "sd-switch";
}
