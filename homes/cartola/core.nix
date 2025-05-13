{ nixpkgs, home-manager }:

{
  homeConfigurations.cartola = home-manager.lib.homeManagerConfiguration {
    inherit nixpkgs;

    # Specify your home configuration modules here, for example,
    # the path to your home.nix.
    modules = [ ./home.nix ];

    # Optionally use extraSpecialArgs
    # to pass through arguments to home.nix
  };
}
