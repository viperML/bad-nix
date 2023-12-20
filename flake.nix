{
  # get nix >2.19 with nar pack
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [
        (final: prev: {
          nix = final.nixVersions.nix_2_19;
        })
      ];
    };
  in {
    packages.${system} = {
      default = pkgs.callPackage ./package.nix {
        badSrc = ./payload;
      };

      target = let
        # FIXME; this would make vscode part of the closure of the package, taking its place in the store
        # prev = pkgs.vscode;
      in
        pkgs.callPackage ./package.nix {
          badHash = "h8xh4n466vs54x3d4n6810wr0kynw22z";
          badName = "google-chrome-120.0.6099.109";
          badSrc = ./payload;
        };
    };

    devShells.${system}.default = pkgs.mkShellNoCC {
      packages = [
        pkgs.nix
      ];
    };
  };
}
