# flake.nix
{
  description = "NixOS configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    hyprland.url = "github:hyprwm/Hyprland";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    pia.url = "github:Fuwn/pia.nix";
    pia.inputs.nixpkgs.follows = "nixpkgs";
    zen-browser.url = "github:abergdorf/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ nixpkgs, home-manager, sops-nix, pia, ... }:
  let
    pkgs = import nixpkgs {
      system = "x86_64-linux";
      config = {
        allowUnfree = true;
        allowUnfreePredicate = (pkg: true);
      };
    };
  in
  {
    nixosConfigurations = {
      default = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs; };
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.andrew = ./home.nix;
          }
          sops-nix.nixosModules.sops
          pia.nixosModules."x86_64-linux".default
          {nixpkgs.pkgs = pkgs;}

          # This overlay is what provides the pkgs argument to configuration.nix
          ({
            nixpkgs.overlays = [
              (import ./overlays/plex.nix)
            ];
          })
        ];
      };
    };
  };
}
