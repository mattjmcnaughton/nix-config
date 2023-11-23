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
      terraform
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

  programs.git = {
    enable = true;
    userName = "mattjmcnaughton";
    userEmail = "me@mattjmcnaughton.com";
  };

  programs.vim = {
    enable = true;
  };

  systemd.user.startServices = "sd-switch";
}
