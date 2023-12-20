{
  # get nix >2.19 with nar pack
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    packages.${system}.default = pkgs.callPackage ./package.nix {
      nix = pkgs.nixVersions.nix_2_19;

      badSrc = ./payload;
    };
    devShells.${system}.default = pkgs.mkShellNoCC {
      packages = [
        pkgs.nixVersions.nix_2_19
      ];
    };
  };
}
