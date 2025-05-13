# # {
# #   description = "A very basic flake";
# #
# #   inputs = {
# #     nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
# #     nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
# #     # home-manager.url = "github:nix-community/home-manager";
# #     # home-manager.inputs.nixpkgs.follows = "nixpkgs";
# #   };
# #
# #   outputs = inputs@{ self, nixpkgs, home-manager, nixos-wsl, ... }:
# #   let
# #     hostDir = "hosts";
# #     hostNames = builtins.attrNames (builtins.readDir ./${hostDir});
# #     makeHost = name:
# #       let path = ./${hostDir}/${name}/core.nix; in
# #       {
# #         inherit name;
# #         config = import (path) {
# #           inherit nixpkgs;
# #         };
# #       };
# #
# #     allHostsConfigs = builtins.listToAttrs (
# #       map (name: {
# #         name = name;
# #         value = (makeHost name).config;
# #       }) hostNames
# #     );
# #
# #     mergedConfigs = builtins.foldl'
# #       (acc: cfg: acc // cfg.nixosConfigurations)
# #       {}
# #       (builtins.attrValues  allHostsConfigs);
# #   in
# #   {
# # # nixosConfigurations = mergedConfigs.nixosConfigurations;
# # # nixosConfigurations = mergedConfigs;
# # # nixosConfigurations.wsl = allHostsConfigs.wsl.nixosConfigurations;
# #     nixosConfigurations.wsl = nixpkgs.lib.nixosSystem {
# #       system = "x86_64-linux";
# #       modules = [
# #       {
# #         imports = [
# #           <nixos-wsl/modules>
# #         ];
# #
# #         wsl.enable = true;
# #         wsl.defaultUser = "wsl";
# #         system.stateVersion = "24.11"; # Did you read the comment?
# #       }
# #       ];
# #     };
# #   };
# # }
#
#
# {
#   inputs = {
#     nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
#     nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
#   };
#
#   outputs = { self, nixpkgs, nixos-wsl, ... }:
#   let
#     hostDir = "hosts";
#     hostNames = builtins.attrNames (builtins.readDir ./${hostDir});
#     makeHost = name:
#       let path = ./${hostDir}/${name}/core.nix; in
#       {
#         inherit name;
#         config = import (path) {
#           inherit nixpkgs;
#         };
#       };
#
#     allHostsConfigs = builtins.listToAttrs (
#       map (name: {
#         name = name;
#         value = (makeHost name).config;
#       }) hostNames
#     );
#   in
#   {
#     nixosConfigurations.wsl = allHostsConfigs.wsl.nixosConfigurations;
#     # nixosConfigurations = {
#     #   wsl = nixpkgs.lib.nixosSystem {
#     #     system = "x86_64-linux";
#     #     modules = [
#     #       nixos-wsl.nixosModules.default
#     #       {
#     #         system.stateVersion = "24.11";
#     #         wsl.enable = true;
#     #         wsl.defaultUser = "wsl";
#     #         nix.settings.experimental-features = [ "nix-command" "flakes" ];
#     #       }
#     #     ];
#     #   };
#     # };
#   };
# }

{
  description = "flake configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
  let
    hostNames = builtins.attrNames (builtins.readDir ./hosts);
    homeNames = builtins.attrNames (builtins.readDir ./homes);

    makeHost = name:
      let path = ./hosts/${name}/core.nix; in
      {
        inherit name;
        config = import (path) {
          inherit nixpkgs;
        };
      };

    makeHome = name:
      let path = ./homes/${name}/core.nix; in
      {
        inherit name;
        config = import (path) {
          inherit nixpkgs home-manager;
        };
      };

    allHomesConfigs = builtins.listToAttrs (
      map (name: {
        name = name;
        value = (makeHome name).config;
      }) homeNames
    );


    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    homeConfigurations = allHomesConfigs;
    # homeConfigurations."cartola" = home-manager.lib.homeManagerConfiguration {
    #   inherit pkgs;
    #
    #   # Specify your home configuration modules here, for example,
    #   # the path to your home.nix.
    #   modules = [ ./home.nix ];
    #
    #   # Optionally use extraSpecialArgs
    #   # to pass through arguments to home.nix
    # };
  };
}
