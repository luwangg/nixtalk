let
  pkgs = import ../nixpkgs.nix;
in
  derivation {
    name = "login-service";
    builder = "${pkgs.bash}/bin/bash";
    args = [ "${./builder.sh}" ];
    src = "${./LoginService.java}";

    /* dependencies */
    coreutils = "${pkgs.coreutils}";
    bash = "${pkgs.bash}";
    openjdk = "${pkgs.openjdk}";
    jre = "${pkgs.jre}";
    jzmq = "${pkgs.jzmq}";

    system = builtins.currentSystem;
  }
