Nix - A developer oriented package manager

Ever had your laptop running out of battery during and apt dist-upgrade, and
got yourself rebooting in a broken system?  Always struggling with making sure
everybody runs exactly the same version of Python when performing builds?  Ever
had a moment where a test broke on your machine, but you can not reproduce it
in production or on one of your team member's laptops? These days are
officially gone with Nix!

Nix is a project build utility that is:
- Reliable:  installing or upgraidng one package will never cause breakage
  somewhere else. All projects are isolated
- Reproducible: All software built with nix must explicitly pin all the
  dependencies, thus if I give my Nixfile to my collegues, they will be abl
  build my software as well. Every time. Even in a hundred years.
- Great for developers:  Nix makes it easy to set up and share build
  environments for your projects that are reliable. you will still be able to
  use your favorite build tools under the hood, like pip
- Portable: Though Nix was developed for the NixOS operating system, it is in
  no way tied to it. You can run Nix on any Linux distribution and even MacOS.

In this talk, I will explain how exactly Nix works and what makes it special
compared to other tools and how you can use it to make sharing projects with
collegues a breeze.  I will cover a few cases of where traditional ways of
setting up development environments failed for me (Dockerfiles that broke, or a
power outage during an apt dist-upgrade), and how Nix helped me solve these
issues.  Using our new-gained knowledge  I will then show how we can develop,
package, and deploy a Domcode Raffler in your favorite programming language
using the Nix package manager.


