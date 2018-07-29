let pkgs = import ../nixpkgs.nix;
in pkgs.stdenv.mkDerivation {
  name = "domcode-slides";
  src = ./.;
  buildInputs = [ pkgs.pandoc ];
}
