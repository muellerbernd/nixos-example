{
  description = "NixOS systems and tools";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      # url = "github:nix-community/home-manager"; # only when using nixos-unstable
      # We want to use the same set of nixpkgs as our system.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:nixos/nixos-hardware";
    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
    agenix.url = "github:ryantm/agenix";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      # Overlays is the list of overlays we want to apply from flake inputs.
      overlays = [
        # inputs.neovim-nightly-overlay.overlay
        (self: super: {
          annotator = super.callPackage ./pkgs/annotator
            { }; # path containing default.nix
        })
      ];
    in
    {
      nixosConfigurations.t480 = nixpkgs.lib.nixosSystem
        {
          system = "x86_64-linux";

          modules = [
            # Apply our overlays. Overlays are keyed by system type so we have
            # to go through and apply our system type. We do this first so
            # the overlays are available globally.
            { nixpkgs.overlays = overlays; }

            ./hosts/t480/configuration.nix

            # include user configs

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.bernd = ./users/bernd/home-manager.nix;
            }

            # agenix.nixosModules.age

          ] ++ [ ./users/bernd/bernd.nix ];
          specialArgs = { inherit inputs; };
        };
    };
}
