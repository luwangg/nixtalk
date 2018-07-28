#!/usr/bin/env nix-shell
#!nix-shell -p nix-prefetch-git
nix-prefetch-git  https://github.com/nixos/nixpkgs-channels.git refs/heads/nixos-unstable > nixpkgs-version.json
