let
  info = builtins.fromJSON (builtins.readFile ./nixpkgs-version.json);
  location = builtins.fetchGit {
    url = info.url; 
    rev = info.rev;
  };
in import location;
