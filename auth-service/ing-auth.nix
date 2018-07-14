{ gnu-cobol, stdenv, czmq }:
stdenv.mkDerivation {
  name = "ing-auth";
  src = ./.;
  buildInputs = [ gnu-cobol czmq ];
}
