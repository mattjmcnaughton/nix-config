# nix-config

Monorepo for managing all my personal computing machines via Nix.

## Commands

- `just switch-machine (HOSTNAME)`
- `just switch-home-manager (USERNAME HOSTNAME)`

## Bootstrapping

- We define a `devShell` (accessible via `nix develop`) which installs all of
  the necessary packages for first time provisioning.

## Organization

We used [nix-starter-configs/standard](https://github.com/Misterio77/nix-starter-configs/tree/main/standard) as inspiration.

We also looked at the following:
- https://github.com/wimpysworld/nix-config
- https://github.com/mitchellh/nixos-config
