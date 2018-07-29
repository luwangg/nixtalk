let
  info = builtins.fromJSON (builtins.readFile ./nixpkgs-version.json);
  fromGit = builtins.fetchGit {
    url = info.url; 
    rev = info.rev;
  };
in
  (import fromGit) {} // { 
    login-service = import ./login-service/default.nix;
    auth-service = import ./auth-service/default.nix;
  }
