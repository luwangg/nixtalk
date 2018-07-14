{ pkgs ? import <nixpkgs> {}}:
pkgs.callPackage (import ./ing-auth.nix) {}
