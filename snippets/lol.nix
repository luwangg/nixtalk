let
  stdenv = import ./stdenv.nix;
  libxml = import ./libxml.nix;

in
  derivation {
    name = "myproject";
    src = ./.;
    buildInputs = [ libxml ];
  }
