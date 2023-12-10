{
  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-23.11;

    home-manager.url = github:nix-community/home-manager/release-23.11;
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    agenix,
    ...
  } @ inputs: let
    inherit (self) outputs;

    # From https://github.com/NixOS/templates/blob/master/go-hello/flake.nix
    supportedSystems = ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];

    # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    # Nixpkgs instantiated for supported system types.
    nixpkgsFor = forAllSystems (system: import nixpkgs {inherit system;});
  in {
    nixosConfigurations = {
      armadillo = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          ./machines/armadillo/configuration.nix
          agenix.nixosModules.default
        ];
      };

      beaver = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          ./machines/beaver/configuration.nix
          agenix.nixosModules.default
        ];
      };
    };

    homeConfigurations = {
      "mattjmcnaughton@armadillo" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;

        extraSpecialArgs = {inherit inputs;};

        modules = [
          ./home-manager/mattjmcnaughton/home.nix
          agenix.homeManagerModules.default
        ];
      };

      "mattjmcnaughton@beaver" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;

        extraSpecialArgs = {inherit inputs;};

        modules = [
          ./home-manager/mattjmcnaughton/home.nix
          agenix.homeManagerModules.default
        ];
      };
    };

    # From https://github.com/NixOS/templates/blob/master/go-hello/flake.nix
    devShells = forAllSystems (system: let
      pkgs = nixpkgsFor.${system};
    in {
      default = pkgs.mkShell {
        buildInputs = [
          # If we try and use `with pkgs` and then refer to `home-manager`, we run into errors because `home-manager` is already defined...
          pkgs.home-manager
          pkgs.just
          pkgs.vim
          pkgs.git
          agenix.packages.${system}.default
        ];
      };
    });
  };
}
