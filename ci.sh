#! /usr/bin/env bash
# -*- mode: bash -*-
set -eu

if [[ "$#" -ne 2 ]]; then
    echo "Usage: $0 <flakeref> <attr>"
    exit 64
fi

set -x
flakeref=$1
attr=$2

export NIX_CONFIG="extra-experimental-features = nix-command flakes"
export NIXPKGS_ALLOW_UNFREE=1

outpath="$(nix eval --impure --raw $flakeref#$attr.outPath)"

hash=${outpath:11:32}
name=${outpath:44}

