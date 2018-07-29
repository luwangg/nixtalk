{ pkgs, config, ... }:
{
  services.sshd.enable = true;

  systemd.services.auth-service = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "@${pkgs.auth-service}/bin/auth-service";
    };
  };

  systemd.services.login-service = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "@${pkgs.login-servixe}/bin/login-service";
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 22 ];
  }

  services.nginx = {
    enable = true;
    virtualHosts."login.bank.example" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://localhost:888";
    }
  };
}

