# Concepts Utilized

I make use of various concepts, each of the big ones I'll explain here.

## Dendritic Configuration
I use the dendritic pattern, which condenses the "features" I use into specific single files. Things such as git, networking, and gaming configurations live in their own, single files. These individual files are then defined as single, individual "aspects" that I can enable in bulk from a single host-machine specific configuration.

I chose this as it makes maintaining my systems much cleaner. I can enable aspects defined in my configurations on different machines as I please without having to write new host-specific configurations. I just tell it to enable my git aspect and it's there. Quite convenient, no matter the machine.

Lately, I've come across Vic's Den framework. As a flake input, it allows me to define custom modules with expressions that simply make declarative management much easier per-OS. I've adopted its framework here, using import-tree to auto-import anything enabled in ./modules, while also building flake.nix using flake-file with flake definitions in their respective modules. That last point eliminates monolithic flake.nix management for good.

## Flakes
I use nix flakes, which consist of inputs and outputs. This feature allows me to input various systems and libraries, such as nix packages, home-manager, and github controlled projects. It then outputs these libraries and configurations into a buildable system using the wider range of configurations listed dendritically. Using an input and output system allows me to version control and define what my configuration imports in order to get the result I want.

## Darwin
Nix-Darwin is my Macbook Pro configuration. I not only manage my NixOS Linux system declaratively, but also my Macbook Pro. I define programs, system defaults, ssh keys, and more using it. This is a must for my Macbook, as typical Nix is made for other architectures and kernels.

## Lix
An alternative implementation of the Nix package manager, Lix simply has nicer error messages. Nix is notorious for its less than stellar error messages, making debugging very difficult with the human eye. Additionally, Lix has correctness as a primary focus, leveraging its community entrenchment to build a better implementation of the package manager I love so much.

## Preservation
Preservation is a process within my system that wipes my root folder fresh every reboot, saving only the directories I declare to keep. This is the ultimate declarative system. What survives is exactly what I declare. No stray configs, files, caches, /etc/ files, or what have you. Clean, lean, and declared.

## ZFS
The unique filesystem that leverages ARC for lightning-fast storage navigation and self-healing, auditing, and organizational features. Once on BTRFS, I thought I might as well go the whole way and use this filesystem, as in the future I could leverage its featureset.

## Overall Declarative Nature
I love declarative deployment. Defining my system this way keeps it organized and exactly the way I want it. It is a different way of thinking about programming, but certainly one I prefer over imperative management. Nix is not exclusively declarative, I can nix-shell or nix-env imperative projects and packages I wish to run in certain points as I please.
