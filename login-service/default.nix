{ pkgs ? import <nixpkgs>  {} }:
pkgs.callPackage (import ./login-service.nix) {}
