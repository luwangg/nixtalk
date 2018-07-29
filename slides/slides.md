---
title: "Nix Package manager"
---

# Our story
* You're a developer at a big bank.
* You have packages with complex dependencies
* You want the assurance that if package builds on your machine, it builds in CI, and in production
* You're a developer at a big bank.
* _High assurance_

---

# Our Mission
* We're maintainers of a legacy COBOL codebase, which handles authentication within the bank
* Company is moving to _micro services_ architecture, because manager says so
* Other applications written in _Python_ and _Java_
* We're responsible for _smooth_ releases

---



---

# Build problems
## A current state of affairs - (Raise hands if you had one of these issues!)
* I build a project but it doesn't compile, whilst it did build on a collegues machine
* I modified some file like `/etc/nginx/nginx.conf` and now `apt upgrade` aborts, because
  it tries to override an existing file.
* Computer runs out of battery during `apt upgrade`, and now my whole system is F*$#kd
* My package manager has language version X, but I need language version Y

---

# Build problems
## What is the root cause of all these issues?

<img src="current-flow.png" width="80%">

---

# What do we want?
* Reliable builds
  - If it builds on my machine, it should build on any machine
* Isolation
  - Multiple versions of the same software should be able to run next to each other
* Atomic updates
  - You either install something completely, or you do not install it al all

---

# Solution

<center>
<img src="Docker-logo-011.png" width="50%">
</center>

> Just put it in a damn container - <b>Lucas</b>



---

# Solution? Docker

* Docker is a distribution format and execution method
* It does not solve the problem of reliable builds
*
steal from here:
https://news.ycombinator.com/item?id=15478209 

---

# Docker

* Solves the 'works on my machine' problem by shipping container artifacts from dev/CI to production
* Does _not_ solve the 'compiles on my machine' problem.  
* Two people with the same Dockerfile, are not guarenteed to both succesfully build the project

---

# Solution: Functional flow
<img src="desired-flow.png" width="80%">

---

# The Nix Package Manager
* Purely functional
* Atomic
* Reproducible
* Packages described in the declarative "Nix Programming Language"

---

# The Nix Package Manager





---

# Using Nix for day to day use
* You can use Nix as a replacement for `apt` or `homebrew`

---



---

# The nix programming language
* Think of it as JSON with templates and functions
* Used to describe package derivations
* Show around a little bit in the repl

---

#  Our first package
## Java Login frontend of our bank
* Use imagination such that this is a Spring enterprise web servlet in the cloud

```java
import org.zeromq.ZMQ;
import java.nio.charset.StandardCharsets;

public class LoginService {
  public static void main(String[]args) {
    ZMQ.Context ctx = ZMQ.context(1);
    ZMQ.Socket sock = ctx.socket(ZMQ.REQ);
    sock.connect("tcp://127.0.0.1:1234");
    byte[] msg = "arian       @r1aN".getBytes(StandardCharsets.UTF_8);
    sock.send(msg, 0, 0);
    byte[] resp = sock.recv(0);
    String s = new String(resp, StandardCharsets.UTF_8);
    System.out.println(s);
  }
}


```

---

# Our first package

<table>
<tr>
<td>
```nix
# default.nix
let
  pkgs = import ../nixpkgs.nix;
in
  derivation {
    name = "login-service";
    builder = "${pkgs.bash}/bin/bash";
    args = [ ./builder.sh ];
    src = ./LoginService.java;
    coreutils = pkgs.coreutils;
    openjdk = pkgs.openjdk;
    jre = pkgs.jre;
    jzmq = pkgs.jzmq;
    system = builtins.currentSystem;
  }
```
</td>
<td>
```bash
# builder.sh
export PATH=$coreutils/bin:$openjdk/bin
cp $src LoginService.java
javac -cp $jzmq/share/java/zmq.jar LoginService.java
jar cfe LoginService.jar LoginService LoginService.class
mkdir $out
cp LoginService.jar $out
cat <<EOF >> $out/login-service
#!/{pkgs.bash}
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

# What is a derivation?
<table>
<tr>
<td>
```nix
# default.nix
let
  pkgs = import ../nixpkgs.nix;
in
  derivation {
    name = "login-service";
    builder = "${pkgs.bash}/bin/bash";
    args = [ ./builder.sh ];
    src = ./LoginService.java;
    coreutils = pkgs.coreutils;
    openjdk = pkgs.openjdk;
    jre = pkgs.jre;
    jzmq = pkgs.jzmq;
    system = builtins.currentSystem;
  }
```
</td>
<td>
```json
{ 
  "/nix/store/smr6-login-service.drv": {
    "outputs": {
      "out": { "path": "/nix/store/mzj8-login-service" }
    },
    "inputSrcs": [
      "/nix/store/f3y1-LoginService.java",
      "/nix/store/r1ry-builder.sh"
    ],
    "inputDrvs": [ 
      "/nix/store/2zlf-bash-4.4-p23.drv",
      "/nix/store/9fwq-jzmq-3.1.0.drv",
      "/nix/store/q80i-openjdk-8u172b11.drv",
      "/nix/store/wx2j-coreutils-8.29.drv"
    ],
    "builder": "/nix/store/8zkg-bash-4.4-p23/bin/bash",
    "args": [  "/nix/store/r1ry-builder.sh" ],
    "env": {
      "builder":   "/nix/store/8zkg-bash-4.4-p23/bin/bash",
      "coreutils": "/nix/store/n7qp-coreutils-8.29",
      "jre":       "/nix/store/v5ld-openjdk-8u172b11-jre",
      "openjdk":   "/nix/store/8nll-openjdk-8u172b11",
      "jzmq":      "/nix/store/hill-jzmq-3.1.0",
      "out":       "/nix/store/mzj8-login-service",
      "src":       "/nix/store/f3y1-LoginService.java",
      "name":      "login-service",
      "system": "x86_64-linux"
    } 
  }
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
## Anecdote
* Ansible modifies `/etc/nginx/nginx.conf`
* Ansible enabled auto upgrades of packages
* Upgrade of apt overrides `/etc/nginx/nginx.conf
* Stuff silently fails
* Rerun ansible,  stuff converges again...

---

# NixOS - A configuration management tool

Okay, we need to add code example here.

---

# NixOS - A configuration management tool
* Reliable upgrades & consistency
* Immutable OS, pinned to a specific git commit in your repo
* Atomic upgrades and rollback (Your OS is just another Nix package!)
* INFRASTRUCTURE AS CODE. TRULY

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

---

# Downsides of Nix
* Steep learning curve. Thinking functionally is something to get used to
* You _Can not_ do dirty hacks.  You can't go monkeypatch some python package in `/usr/lib/python`, or update `/etc/hosts` manually 
* Ok.. maybe the above is a Pro. But it forces you to do things properly. Which might be slow
* Install can get large, as multiple people have multiple versions of packages
* Documentation is ... not always great. "Read the source code" is a common philosophy among Nix'ers
* However, this forces you to actually learn the tool, and gives great flexibility to you

# Questions?
* [https://nixos.org/nixos/nix-pills - Tutorial to get up to speed quickly with how nix works](https://nixos.org/nixos/nix-pills)
* [https://nixos.org/nix](https://nixos.org/nix)
* [https://nixos.org/nixos](https://nixos.org/nixos)
* [https://nixos.org/nixops](https://nixos.org/nixops)
* [https://github.com/nixos](https://github.com/nixos)
* [\@ProgrammerDude - Stalk me on Twitter](https://twitter.com/ProgrammerDude)
* [https://github.com/arianvp - Stalk me on Github](https://github.com/arianvp)

