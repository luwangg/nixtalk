---
title: "Nix Package manager"
author: Arian van Putten
---


---

# Assumptions about my audience

<div class="incremental">
* Used a GNU/Linux based OS like Ubuntu before?
* If not, used Homebrew on Mac OS X before?
* Familiar with Git?
* Used Docker before? Hobby / Professional?
* Familiar with / Heard of Nix?
</div>

---

# Ask questions!

<div class="incremental">
* If something isn't clear. Interrupt me
* No really... Interrupt me
* We're gonna have fun either way

* Oh and I lied about the rafflers... because rafflers don't have many
  dependencies!
</div>


---

# Build problems
## A current state of affairs - (Raise hands if you had one of these issues!)

<div class="incremental">

* I build a project but it doesn't compile, whilst it did build on a collegues machine
* I modified some file like `/usr/lib/nginx/nginx.conf` and now `apt upgrade` aborts, because
  it tries to override an existing file.
* I manually installed  `node` in `/usr/bin/node`, now `apt` installs it as a
  dependency, and apt fails because it tries to override existing file
* Computer runs out of battery during `apt upgrade`, and now my whole system is F*$#kd
* My package manager has version X, but I need version Y
* **Insert story from the audience here**

</div>

---

# Challenge

* Take a random commit from 5 years ago at your company
* Can you get the commit to build from scratch?

---

# What is the root cause of all these issues?

---

# What is the root cause of all these issues?

## Mutability
<center>
<img src="current-flow.png" width="50%">
</center>

* `/usr` is a mutable directory
* `/usr` is an implicit build input to all your projects
</div>

---

# What do we want?
* Reliable builds
  - If it builds on my machine, it should build on any machine, always
  - If I build it today, I should be able to build it in 10 years
* Isolation
  - Multiple versions of the same software should be able to run next to each other
* Atomic updates
  - You either install something completely, or you do not install it al all

---

# Digression - Git
* We decided that people editing the same files in the same Dropbox / fileshare is bad
* I delete an file by accident, and now collegue wants it back
* Version Control Systems were invented

---

# Digression - Git
## In Git, do we all edit the same directory? No!
<pre><font color="#D33682">❯</font> git log --graph --decorate --all
* <font color="#B58900">commit 24c1ad70db1890dcc2b3dbaaa5a151adedaec0b9 (</font><font color="#93A1A1"><b>HEAD</b></font><font color="#B58900">)</font>
<font color="#DC322F">|</font> Author: Arian van Putten &lt;aeroboy94@gmail.com&gt;
<font color="#DC322F">|</font> Date:   Mon Jul 30 13:34:51 2018 +0200
<font color="#DC322F">|</font> 
<font color="#DC322F">|</font>     Implement feature C
<font color="#DC322F">|</font> 
* <font color="#B58900">commit 1e63d01b43dcdab7636f6e49a8c116b42dd7af8f</font>
<font color="#DC322F">|</font> Author: Arian van Putten &lt;aeroboy94@gmail.com&gt;
<font color="#DC322F">|</font> Date:   Mon Jul 30 13:34:45 2018 +0200
<font color="#DC322F">|</font> 
<font color="#DC322F">|</font>     Implement feature A
<font color="#DC322F">|</font> 
* <font color="#B58900">commit b5deb132c92bb39e99477432b62adea62dcca43c</font>
Author: Arian van Putten &lt;aeroboy94@gmail.com&gt;
Date:   Mon Jul 30 13:34:35 2018 +0200

    Initial commit
</pre>

---


# Digression - Git

* Commits refer to content they contain
* Each commit uniquely identifies an _immutable_ directory of files, stored in `.git/objects/<commit-id>`
```
commit-id(Implement feature A) =
  sha1(.
        ├── sha1(a)
        ├── sha1(b
        │        └── sha1(b.html))
        └── sha1(c
                └── sha1(a.java))

$ tree ./git/objects/24c1ad70db1890dcc2b3dbaaa5a151adedaec0b9
  ./git/objects/24c1ad70db1890dcc2b3dbaaa5a151adedaec0b9
  ├── a
  ├── b
  │   └── b.html
  └── c
      └── a.java

```

* Current version of our Repo (`HEAD`) is just a symbollic link to such a commit
* Can move back and forth using `git checkout <commit>`

> P.S. I know I am lying a bit, but this is _morally_ true

--- 

# Digression - Git
## We simply change to which commit HEAD points, to rollback
<pre><font color="#D33682">❯</font> git log --graph --decorate --all
* <font color="#B58900">commit 24c1ad70db1890dcc2b3dbaaa5a151adedaec0b9 (</font><font color="#93A1A1"><b>HEAD</b></font><font color="#B58900">)</font>
<font color="#DC322F">|</font> Author: Arian van Putten &lt;aeroboy94@gmail.com&gt;
<font color="#DC322F">|</font> Date:   Mon Jul 30 13:34:51 2018 +0200
<font color="#DC322F">|</font> 
<font color="#DC322F">|</font>     Implement feature C
<font color="#DC322F">|</font> 
* <font color="#B58900">commit 1e63d01b43dcdab7636f6e49a8c116b42dd7af8f</font>
<font color="#DC322F">|</font> Author: Arian van Putten &lt;aeroboy94@gmail.com&gt;
<font color="#DC322F">|</font> Date:   Mon Jul 30 13:34:45 2018 +0200
<font color="#DC322F">|</font> 
<font color="#DC322F">|</font>     Implement feature A
<font color="#DC322F">|</font> 
* <font color="#B58900">commit b5deb132c92bb39e99477432b62adea62dcca43c</font>
Author: Arian van Putten &lt;aeroboy94@gmail.com&gt;
Date:   Mon Jul 30 13:34:35 2018 +0200

    Initial commit
</pre>
```
git checkout 24c1ad
```

---

# Digression - Git
## We simply change to which commit HEAD points, to rollback
<pre><font color="#D33682">❯</font> git log --graph --decorate --all
* <font color="#B58900">commit 24c1ad70db1890dcc2b3dbaaa5a151adedaec0b9</font>
<font color="#DC322F">|</font> Author: Arian van Putten &lt;aeroboy94@gmail.com&gt;
<font color="#DC322F">|</font> Date:   Mon Jul 30 13:34:51 2018 +0200
<font color="#DC322F">|</font> 
<font color="#DC322F">|</font>     Implement feature C
<font color="#DC322F">|</font> 
* <font color="#B58900">commit 1e63d01b43dcdab7636f6e49a8c116b42dd7af8f (</font><font color="#93A1A1"><b>HEAD</b></font><font color="#B58900">)</font>
<font color="#DC322F">|</font> Author: Arian van Putten &lt;aeroboy94@gmail.com&gt;
<font color="#DC322F">|</font> Date:   Mon Jul 30 13:34:45 2018 +0200
<font color="#DC322F">|</font> 
<font color="#DC322F">|</font>     Implement feature A
<font color="#DC322F">|</font> 
* <font color="#B58900">commit b5deb132c92bb39e99477432b62adea62dcca43c</font>
Author: Arian van Putten &lt;aeroboy94@gmail.com&gt;
Date:   Mon Jul 30 13:34:35 2018 +0200

    Initial commit
</pre>
```
git checkout 1e63d0
```

# Digression - Git
## What problems does this method solve?
* A commit uniquely identifies the state of your source repository
* It will always do, because the repository is _immutable_
* We can easily rollback
* We are atomic: 2 users don't edit the same directory, they each edit their
own little world, identified by a commit hash
* You either observe a commit in its totality
* Or *Not at all*
* there is no "inbetween"

--- 

# What do we want?
* Reliable builds
* ~~Isolation~~
* ~~Atomic updates~~


# Idea
## Lets make package managers work like git!

> Eelco Dolstra. The Purely Functional Software Deployment Model. PhD thesis,
> Faculty of Science, Utrecht, The Netherlands. January 2006. ISBN 90-393-4130-3.

[https://nixos.org/~eelco/pubs/phd-thesis.pdf](https://nixos.org/~eelco/pubs/phd-thesis.pdf)


---

# Idea
## Lets make package managers work like git!

```
PREFIX= sha1(sha1(deps(package)) + sha1(src(package)) + sha1(options(package))

$PREFIX/bin , $PREFIX/lib  $PREFIX/share
instead of:
/usr/bin, /usr/lib/, /usr/share

```

<center>
<img src="desired-flow.png" width="50%">
</center>

* Dependencies change?   => Installed in different prefix
* Source code change?    => Installed in different prefix
* Build options change?  => Installed in different prefix


# Nix

<table>
<tr>
<td>
* Package manager
* Declarative lanuage to describe package builds
* Isolated build environments
* Over 10000 packages and counting
* Mac OS X / Linux / BSD  and Soon Windows Subsystem for Linux*
* Source-based package manager (Like Gentoo)
* But don't worry; also has a build cache
</td>
<td>
<img src="nixos.svg">
</td>
<tr>
</table>

---

# DEMO TIME: Installing a package

* To install a package, we build it from source, given a package description
* `./nixpkgs.nix` is a file containing build instructions for all packages

```
nix-build ./nixpkgs.nix -A nginx
tree /nix/store/i5h55rj3mhlad1vbp6rlwvacfafycl4p-nginx-1.14.0
sudo /nix/store/i5h55rj3mhlad1vbp6rlwvacfafycl4p-nginx-1.14.0/bin/nginx
curl http://localhost
```

* Observation: It was instant? It didn't build anything from source?
* Not very user-friendly to type in the large /nix/store/bLAHBLAH/ when I want to run a program

---


# nix-env 

* Used to install software in $PATH

```
nix-env -f ./nixpkgs.nix -i  -A nginx
sudo nginx
which nginx
tree /home/arian/.nix-profile
nix-env -f ./nixpkgs.nix -i -A hello
tree /home/arian/.nix-profile
nix-env --rollback
hello
nix-env --rollback
nginx
```

* Rollbacks possible?
* How?!

---

# nix-env
## Atomic updates and rollbacks

<pre>
export PATH=/nix/var/nix/profiles/per-user/arian/<font color="green">profile</font>

/nix/var/nix/profiles/per-user/arian
├── <font color="green">profile</font> -> <font color="red">profile-1-link</font>
│   
├── <font color="red">profile-1-link -> /nix/store/7m5fi-user-environment
│   └── bin -> /nix/store/2gk7-nginx-2.0.1/bin</font>
│   
└── <font color="magenta">profile-2-link -> /nix/store/34hia-user-environment
    └── bin
        ├── hello -> /nix/store/i5h55-hello-1.14.0/bin/hello
        └── nginx ->  /nix/store/2gk7-nginx-2.0.1/bin/nginx</font>
</pre>

* This is _exactly_ the same as `HEAD` in git!

---

# nix-env
## Atomic updates and rollbacks

<pre>
export PATH=/nix/var/nix/profiles/per-user/arian/<font color="green">profile</font>

/nix/var/nix/profiles/per-user/arian
├── <font color="green">profile</font> -> <font color="magenta">profile-2-link</font>
│   
├── <font color="red">profile-1-link -> /nix/store/7m5fi-user-environment
│   └── bin -> /nix/store/2gk7-nginx-2.0.1/bin</font>
│   
└── <font color="magenta">profile-2-link -> /nix/store/34hia-user-environment
    └── bin
        ├── hello -> /nix/store/i5h55-hello-1.14.0/bin/hello
        └── nginx ->  /nix/store/2gk7-nginx-2.0.1/bin/nginx</font>
</pre>
      
* This is _exactly_ the same as `HEAD` in git!

---

# Important takeaways

* Each package is installed in its own unique path (think git commit hash)
* Software is installed into profiles, which are symlinks to packages (think `HEAD`)
* You can rollback to previous profiles, by changing a symlink (think `git checkout`)
* This allows for atomic updates, because symlink changes are atomic
* As an end user, not very different from `homebrew` or `apt`, except for rollbacks

---

# How does all this Black Magic work?

<center>
<img src="dog.jpg" width="50%">
</center>

--- 

# The Nix  Language
* Language of Nixfiles, which describes how to build packages
* Think `Dockerfile` or `debinfo` file
* Actually a proper programming language
* JSON-like with templating, functions and variables
* Side-effects only allowed _but_  only if we know the _output_ beforehand

---

# The Nix Language in 1 minute

```nix
"hello"
1 + 3
./a/path
[ "i" 3 5 ]

```
```nix
{
  a = 5;
  b = "yo";
}
```
```nix
a = 3
b = 4
add = {x, y}:  x + y // {x,y} => x + y in javascript
add { x = a ; y = b}
people = "Domcode";

"Hello ${people}"

import ./domcode.nix
```

```nix
derivation { /* package build instructions */ }
```

---

# The derivation function

* derivation takes a build description
* Builds the project
* and returns where in /nix/store the project will installed

<pre>
lol =  derivation { name = "lol";  builder = "lol"; system = builtins.currentSystem; }
"${lol}"
<font color="#B58900">&quot;/nix/store/7kv2zhwjiyzlnfn0lv1fcyd0w8xzcd8r-lol&quot;</font>
</pre>

* Nix is lazy. no other package needed the "lol" package, so it wasn't built
* We can force it to build
<pre>
:b lol  # basically the same as doing  nix-build in the commandline
</pre>

# The derivation function

* How does the derivation function decide where to install?
* **Hash of all its inputs, like git a commit!**

```
location =  /nix/store/sha256({ name = sha256("lol"); builder = sha256("lol")}) + name;
         =  /nix/store/7kv2zhwjiyzlnfn0lv1fcyd0w8xzcd8r-lol
```


---

# An actual derivation

<table>
<thead>
<th>default.nix</th>
<th>builder.sh</th>
</thead>
<tr>
<td>
```nix
derivation {
  name = "login-service";

  /* how to build */
  builder = "${import ./bash.nix}/bin/bash";
  args = [ "${./builder.sh}" ];

  /* dependencies passed as env vars */
  src = "${./LoginService.java}";
  coreutils = "${import ./coreutils.nix}";
  bash = "${import ./bash.nix}";
  openjdk = "${import ./openjdk.nix}";
  jre = "${import ./jre.nix}";
  jzmq = "${import ./jzmq.nix}";

  system = builtins.currentSystem;
}
```
</td>
<td>
```bash
export PATH=$coreutils/bin:$openjdk/bin
cp $src LoginService.java
javac -cp $jzmq/share/java/zmq.jar LoginService.java
jar cfe LoginService.jar LoginService LoginService.class
mkdir $out/bin
mkdir $out/lib
cp LoginService.jar $out/lib
cat <<EOF >> $out/bin/login-service
#!$bash/bin/bash
$jre/bin/java -Djava.library.path="$jzmq/lib" \
  -cp "$jzmq/share/java/zmq.jar:$out/lib/LoginService.jar" \
  LoginService
EOF
chmod +x $out/bin/login-service
```
</td>
</tr>
</table>

---

# An actual derivation

<table>
<thead>
<th>default.nix</th>
<th>builder.sh</th>
</thead>
<tr>
<td>
```nix
derivation {
  name = "login-service";

  /* how to build */
  builder = "/nix/store/81293812dhadshu-bash/bin/bash";
  args = [ "/nix/store/adjk39213813-builder.sh" ];

  /* dependencies passed as env vars */
  src = "/nix/store/ads12hj3981-LoginService.java";
  coreutils = "/nix/store/sij1873123-coreutils";
  bash = "/nix/store/81293812dhadshu-bash";
  openjdk = "/nix/store/13uwduoiqeuq-openjdk";
  jre = "/nix/store/21uiuadiuqe-jre";
  jzmq = "/nix/store/ajsdqueiq-jzmq";

  system = builtins.currentSystem;
}
```
</td>
<td>
```bash
export PATH=$coreutils/bin:$openjdk/bin
cp $src LoginService.java
javac -cp $jzmq/share/java/zmq.jar LoginService.java
jar cfe LoginService.jar LoginService LoginService.class
mkdir $out
cp LoginService.jar $out
cat <<EOF >> $out/login-service
#!$bash/bin/bash
$jre/bin/java -Djava.library.path="$jzmq/lib" \
  -cp "$jzmq/share/java/zmq.jar:$out/LoginService.jar" \
  LoginService
EOF
chmod +x $out/login-service
```
</td>
</tr>
</table>

---

# Graphical representation of our Derivation

<center>
<img width="90%" src="before-evaluation.svg">
</center>

---

# Evaluated derivation
<center>
<img width="90%" src="lolandthen.svg">
</center>

---

# Evaluated derivation
<center>
<img width="90%" src="after-evaluation.svg">
</center>

---

# If I update the source code
<center>
<img width="90%" src="update-sourcecode.svg">
</center>

---

# If I update the source code
<center>
<img width="90%" src="after-update-sourcecode.svg">
</center>

---

# ...

<center>
<img width="90%" src="inbetween.svg">
</center>

---

# If I update one of the dependencies ...
<center>
<img width="90%" src="update-openjdk.svg">
</center>

---

# If I update one of the dependencies ...
<center>
<img width="90%" src="after-update-openjdk.svg">
</center>

---

# So why a programming language?
* To build reusable constructs
* Comes with a large standard library of common build patterns
* `./nixpkgs.nix` is a list of 10000+ packages the community already created [https://github.com/nixos/nixpkgs](https://github.com/nixos/nixpkgs)
* `stdenv` is a derivation that will automatically detect
  your project's build tool (`make`, `cmake`, `autotools`), and
  will generate that pesky `builder.sh` for us
```nix
let pkgs = import ./nixpkgs.nix
in
pkgs.stdenv.mkDerivation rec {
  name = "jzmq-${version}";
  version = "3.1.0";
  src = fetchFromGitHub {
    owner = "zeromq";
    repo = "jzmq";
    rev = "v${version}";
    sha256 = "1wlzs604mgmqmrgpk4pljx2nrlxzdfi3r8k59qlm90fx8qkqkc63";
  };
  buildInputs = [ pkgs.zeromq3 pkgs.jdk ];
```

---

# So why a programming language?

* Currate package sets
  ```nix
  let pkgs = import ./nixpkgs;
  in filter (pkg: pkgs.meta.license !== pkgs.lib.licenses.AGPL3) 
            pkgs
  ```
* Override existing packages and tweak them
  ```nix
  myNginx = nginx.override { openssl = libressl; }
  ```
---

# How is a derivation built
* Source code is downloaded
* Code is **checked against hash, otherwise abort**
* A chroot (container) is setup, containing _just_ the build dependencies and source
* No network access
* All environment variables are _Cleared_
* No access to `$HOME`. No access to anything on disk..
* Time is set to 1970
*  **The package build can only depend directly on the dependencies specified,
   and NOTHING else**
* The `builder` argument is executed, and its output copied to the Nix store

---

# How is a derivation built
* Now, if a collegue forgets to write down what libraries _exactly_ you need to install
* ... Or if uses library that is available by default on Ubuntu but not On Redhat
* ... The build is guarenteed to fail
* We explicitly state the hash of sources we download from the internet
* If the internet changes, then the build fails. No implicit changes!
* **Reliable builds**

---

# Reliable builds

* I am confident, that if I check out the Nix file of `nginx` from a year ago,
  it will build
* It will build all old versions of dependencies from source, and then
  build `nginx` from source
* Takes a long time. But **it _will_ work**

```
cd nixpkgs-channels
git log
cat nginx.nix
nix-build  nginx.nix
```
---

# What do we want?
* ~~Reliable builds~~
* ~~Isolation~~
* ~~Atomic updates~~
* Not build everything from source? What the hell, Arian?

--- 

# Build Cache

* Remember, our build instructions uniquely determine where we install the package

<pre>nix-repl&gt; &quot;${nginx}&quot;
<font color="#B58900">&quot;/nix/store/i5h55rj3mhlad1vbp6rlwvacfafycl4p-nginx-1.14.0&quot;</font></pre>

* **We know _beforehand_ where our build is going to be put!**
* Simply _ask_ if someone else already built it, and download it from there!

```perl
if file_exists("${pkg}") {
  return;
} else if download("https://cache.nixos.org/${pkg}") {
  return;
} else {
  build(pkg);
}

```

--- 

# Build Cache

* Remember, our build instructions uniquely determine where we install the package

<pre>nix-repl&gt; &quot;${nginx}&quot;
<font color="#B58900">&quot;/nix/store/i5h55rj3mhlad1vbp6rlwvacfafycl4p-nginx-1.14.0&quot;</font></pre>

* **We know _beforehand_ where our build is going to be put!**
* Simply _ask_ if someone else already built it, and download it from there!
<code>
<pre>
if file_exists(<font color="#B58900">&quot;/nix/store/i5h55rj3mhlad1vbp6rlwvacfafycl4p-nginx-1.14.0&quot;</font>) {
  return;
} else if download(<font color="#B58900">&quot;https://cache.nixos.org/nix/store/i5h55rj3mhlad1vbp6rlwvacfafycl4p-nginx-1.14.0&quot;</font>) {
  return;
} else {
  build(pkg);
}
</pre>
</code>

---

# Build Cache

* Can also be used privately, for company-internal packages

<div class="incremental">
* `nix build --store https://cache.nixos.org` (Default)
* `nix build --store s3://my-company-bucket`
* `nix build --store ssh://collegue-machine`
* `nix build --store file:///nfs/company-fileshare/`
* BuildCache As A Service : [https://cachix.org/](https://cachix.org)
</div>

* If a collegue already built some project
* ... and you checkout the same git commit
* Then you don't have to rebuild everything! You just download it from the
  cache!

---

# Continious integration script

* Typical Nix CI script
```yaml
# .travis.yml
language: nix
script:
  - nix build . --store s3://company-bucket
after_success:
  - nix copy . --to s3://company-bucket
```

---


# How about docker?

<center>
<img src="Docker-logo-011.png" width="50%">
</center>
> Just put it in a damn container - <b>Lucas</b>


---

# Docker?
<table>
<tr>
<td>
```docker
FROM ubuntu:xenial
RUN apt update -y && \
    apt upgrade -y && \
    apt install python3 \
                python3-pip \ 
                mysql-client \
                liblapack-dev && \
    pip3 install scipy \
                 Flask \
                 sqlalchemy
COPY . /app
WORKDIR /app
ENTRYPOINT ["python3"]
EXPOSE 8080
CMD ["app.py"]

```
</td>
<td>
* Atomic
* Isolated
* But reliable?
  -  Does xenial still exist?
  -  What version packages do I get if I run "upgrade?"
  -  What libs are installed by default on xenial?

## Challenge
* Can you take a random commit + Dockerfile from 5 years ago at your company and build
  your project?
</td>
</tr>
</table>

---

# Solution? Docker
* Docker is an ubiquitos distribution format.
* Solves the "runs on my machine" problem
* Does _not_ solve the "builds on my machine" problem

---

# Best of both worlds

<table>
<tr>
<td>
* Nix has support for building docker containers
* Copies your package + all its dependencies in a docker image
* **Bare image**,  no `FROM blah`
* Super small
* You can easily integrate Nix in existing docker-compose or Kubernetes projects!
</td>
<td>

```nix
let
  pkgs = import ../nixpkgs.nix;
  login-service = import ./login-service.nix;
in
  pkgs.dockerTools.buildImage {
    name = "login-service";
    config = {
      Cmd = [ "${login-service}/bin/login-service" ];
      Expose = [ 8080 ];
    };
  }
```
</td>
</tr>
</table>

---

# NixOS - A configuration management tool
## Problems with existing tools like Chef / Ansible / Puppet
* Just like with package management, output state depends on current state
* Your playbooks might depend on implicit state
* Playbooks might diverge with what is actually on the system
* Package manager might even _fight_ against the configuration manager!

---

# NixOS - A configuration management tool
## Anecdote 1
* Ansible modifies `/etc/nginx/nginx.conf`
* Ansible enabled auto upgrades of packages
* Upgrade of apt overrides `/etc/nginx/nginx.conf
* Stuff silently fails
* Rerun ansible,  stuff converges again...

---

# NixOS - A configuration management tool
## Anecdote 2
* If you remove a line in Ansible, nothing happens!
```yaml
- name: "enable and start nginx"
  service:
    name: "nginx"
    enabled: true
    state: "started"
```

---

# NixOS - A configuration management tool

<table>
<tr>
<td>
* Immutable OS
* Delete some config => different hash => Different package
* Atomic upgrades and rollback (Your OS is just another Nix package!)
* INFRASTRUCTURE AS CODE. TRULY
</td>
<td>
```nix
{ pkgs, config, ... }:
{
  boot.grub.disk = "/dev/sda";
  services.sshd.enable = true;
  users.users."login-service" = {
    isSystemUser = true;
  };
  systemd.services.login-service = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      User = config.users.users."login-service";
      ExecStart = "@${pkgs.login-service}/bin/login-service";
    };
  };
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 22 ];
  }
}
```
</td>
</tr>
</table>

---

# NixOS - A Configuration management tool
* Downside: You need to fully buy into Nix. hard to sell?
* In that case, just build Docker containers instead, like shown before
* Could for example us NixOS, to set up your kubernetes cluster
* Other collegues can keep existing Docker based images
* You can use Nix

---

# NixOps - infrastructure management tool
* Again, same problems of package mangement, arise in infrastructure management
* Before, people click around UI to create things
* Now, a pure function from datacenter description, to an actual datacenter!
* Create NixOS VMs
* ... Load balancers
* ... DNS Records
* ... Storage buckets
* **Check out commit from 5 years ago, get production environment from  5 years ago**

<img src="giphy.gif">

---

# Downsides of Nix
* Steep learning curve. Thinking functionally is something to get used to
* You _Can not_ do dirty hacks.  You can't go monkeypatch some python package in `/usr/lib/python`, or update `/etc/hosts` manually 
* Ok.. maybe the above is a Pro. But it forces you to do things properly. Which might be slow
* Install can get large, as multiple people have multiple versions of packages
* Documentation is ... not always great. "Read the source code" is a common philosophy among Nix'ers
* However, this forces you to actually learn the tool, and gives great flexibility to you

# Recap

* Nix is a package manager 
* Packages are immutable
* builds are isolated
* ... are atomic
* ... are reliable
* Easily share build environments with collegues
* Thousands of build environments available
* Is not docker, but works well with docker!


# Thanks! Questions?
* [https://nixos.org/nixos/nix-pills - Tutorial to get up to speed quickly with how nix works](https://nixos.org/nixos/nix-pills)
* [https://nixos.org/nix](https://nixos.org/nix)
* [https://nixos.org/nixos](https://nixos.org/nixos)
* [https://nixos.org/nixops](https://nixos.org/nixops)
* [https://github.com/nixos](https://github.com/nixos)
* [\@ProgrammerDude - Stalk me on Twitter](https://twitter.com/ProgrammerDude)
* [https://github.com/arianvp - Stalk me on Github](https://github.com/arianvp)

# Bonus: Hey did that nginx thingy compile?

