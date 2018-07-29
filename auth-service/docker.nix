
let
  pkgs = import ../nixpkgs.nix;
  auth-service = import ./default.nix;
in
  pkgs.dockerTools.buildImage {
    name = "login-service";
    config = {
      Cmd = [ "${auth-service}/bin/login-service" ];
    };
  }

