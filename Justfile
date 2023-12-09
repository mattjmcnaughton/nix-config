hostname := `hostname`
username := `id -u -n`

switch-machine hostname=hostname:
  sudo nixos-rebuild switch --flake '.#{{hostname}}'

switch-home-manager username=username hostname=hostname:
  home-manager switch --flake '.#{{username}}@{{hostname}}'

switch-all: switch-machine switch-home-manager

update:
  nix flake update

garbage-collect:
  nix-collect-garbage -d
