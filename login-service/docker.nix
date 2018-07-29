
let
  pkgs = import ../nixpkgs.nix;
  login-service = import ./default.nix;
in
  pkgs.dockerTools.buildImage {
    name = "login-service";
    config = {
      Cmd = [ "${login-service}/bin/login-service" ];
    };
  }

