# This is the systems configuration file.
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    # If desired, can import pieces (i.e. `./users.nix`...)

    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  nix.settings = {
    experimental-features = "nix-command flakes";
    auto-optimise-store = true;
  };

  # Bootloader - uses UEFI.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "beaver"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mattjmcnaughton = {
    isNormalUser = true;
    description = "mattjmcnaughton";
    extraGroups = ["networkmanager" "wheel" "docker" "lxd"];
    packages = with pkgs; [];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  #
  # The vast, vast majority of packages should be installed on a user specific basis in home-manager.
  environment.systemPackages = with pkgs; [
    curl
    ripgrep

    tailscale # Install at a system level...

    lxd
    lxc
  ];

  environment.variables = {
    EDITOR = "vim"; # Across the entire system, set vim as the editor.
  };

  # Necessary for configuring Sway using Home Manager.
  # https://nixos.wiki/wiki/Sway.
  security.polkit.enable = true;
  # Allow `swaylock` to actually unlock on successful auth.
  security.pam.services.swaylock = {};

  virtualisation.docker.enable = true;
  virtualisation.podman.enable = true;

  virtualisation.lxd.enable = true;
  virtualisation.lxd.recommendedSysctlSettings = true;
  # Enable lxcfs for better container support
  virtualisation.lxc.lxcfs.enable = true;

  # Set up networking for LXD
  networking = {
    bridges.lxdbr0 = {
      interfaces = [];
    };
    firewall = {
      trustedInterfaces = ["lxdbr0"];
    };
    nat = {
      enable = true;
      internalInterfaces = ["lxdbr0"];
      externalInterface = "!*"; # any interface that isn't used for internal.
    };
  };

  # Enable IP forwarding for container networking
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };

  # Ensure nesting is enabled for Nix sandboxing in containers
  virtualisation.lxc.defaultConfig = "lxc.include = ${pkgs.lxcfs}/share/lxc/config/common.conf.d/00-lxcfs.conf";

  services.tailscale.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
