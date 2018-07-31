{ pkgs, config, ... }:
{
  services.sshd.enable = true;
  users.users."login-service" = {
    isSystemUser = true;
  };
  
  systemd.services.login-service = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      User = config.users.users."login-service";
      ExecStart = "@${pkgs.login-servixe}/bin/login-service";
    };
  };
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 22 ];
  }
}

