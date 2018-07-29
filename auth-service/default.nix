let
  pkgs = import ../nixpkgs.nix;
in
  pkgs.stdenv.mkDerivation {
    name = "ing-auth";
    src = ./.;
    buildInputs = [ pkgs.gnu-cobol pkgs.czmq ];
  }
