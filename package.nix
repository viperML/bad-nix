{
  badName ? "funny",
  badHash ? "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  badSrc ? builtins.throw "Please pass a src path",

  stdenv,
  nix,
  writeShellScript,
}:
stdenv.mkDerivation {
  name = "bad-nix-for-${badName}";
  dontUnpack = true;

  env = {
    inherit badName badHash;
    NIX_CONFIG = "extra-experimental-features = nix-command flakes";
  };

  nativeBuildInputs = [
    nix
  ];

  buildPhase = ''
    trap "set +x" ERR
    set -ex

    mkdir -p $out/store
    mkdir $out/store/nar

    cp ${./nix-cache-info} $out/store/nix-cache-info

    nix nar pack ${badSrc} > $out/store/nar/${badName}.nar

    export narHash=$(nix hash file --base32 $out/store/nar/${badName}.nar)
    export narSize=$(du -sb $out/store/nar/${badName}.nar | cut -f1)

    substituteAll ${./narinfo} $out/store/${badHash}.narinfo

    tee $out/load <<EOF
    #! ${stdenv.shell}
    nix \\
      --extra-experimental-features 'nix-command flakes' \\
      copy \\
      --no-check-sigs \\
      --from file://$out/store /nix/store/${badName}-${badHash}
    EOF

    chmod +x $out/load

    set +x
  '';
}