# On the surface
* Nix seems very similar to the package managers you are used to
* `apt` `homebrew` `rpm` etc ...

# Some common operations

```
# list currently installed packages
nix-env --query
# list available packages
nix-env -f 'nixpkgs.nix' --query --available --attr-path | grep tree
```

# So lets install a package

```
nix-env -f 'nixpkgs.nix' --install --attr tree
# What package do we want to install? Ask audience!
```

# And it works!

```
tree
# custom command here
```

# So what is a package?

```
nix edit -f 'nixpkgs.nix' tree
nix edit -f 'nixpkgs.nix' czmq
```

# So what is the big deal?







#  For a package, we define build inputs
But when installing something, we only want to download the runtime dependencies. 
