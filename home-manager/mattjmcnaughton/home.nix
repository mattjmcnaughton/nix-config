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

    packages = with pkgs; [
      bitwarden-cli
      docker-compose
      ffmpeg
      libreoffice-qt  # Because using KDE.
      just
      obsidian
      parallel
      podman-compose
      spotify
      telegram-desktop

      # TODO: Explore more...
      pre-commit
      fd  # https://github.com/sharkdp/fd
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

      # Any dev-specific tools will go in a `shell.nix` or `flake.nix` dev profile.
    ] ++ [
      inputs.agenix.packages.x86_64-linux.default
    ];

    stateVersion = "23.05";
  };

  programs.home-manager.enable = true;

  programs.bash = {
    enable = true;
  };

  programs.firefox = {
    enable = true;
  };

  programs.tmux = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
  };

  programs.git = {
    enable = true;
    userName = "mattjmcnaughton";
    userEmail = "me@mattjmcnaughton.com";

    extraConfig = {
      init.defaultBranch = "main";
    };
  };

  programs.vim = {
    enable = true;
  };

  programs.alacritty = {
    enable = true;
  };

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
    ];
  };

  systemd.user.startServices = "sd-switch";
}
