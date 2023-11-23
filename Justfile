hostname := `hostname`
username := `id -u -n`

switch-machine hostname=hostname:
	sudo nixos-rebuild switch --flake '.#wilbur'

switch-home-manager username=username hostname=hostname:
	home-manager switch --flake '.#{{username}}@{{hostname}}'

switch-all: switch-machine switch-home-manager
