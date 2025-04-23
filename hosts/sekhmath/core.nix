{ nixpkgs, nixos-wsl, system };

{
  nixosConfigurations = {
    nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        nixos-wsl.nixosModules.default
        {
          system.stateVersion = "24.11";
          wsl.enable = true;
          wsl.defaultUser = "wsl";
        }
      ];
    };
  };
}
