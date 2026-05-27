# Concepts Utilized

I make use of various concepts, each of the big ones I'll explain here.

## Dendritic Configuration
I use the dendritic pattern, which condenses the "features" I use into specific single files. Things such as git, networking, and gaming configurations live in their own, single files. These individual files are then defined as single, individual "aspects" that I can enable in bulk from a single host-machine specific configuration.

I chose this as it makes maintaining my systems much cleaner. I can enable aspects defined in my configurations on different machines as I please without having to write new host-specific configurations. I just tell it to enable my git aspect and it's there. Quite convenient, no matter the machine.

## Flakes
I use nix flakes, which consist of inputs and outputs. This feature allows me to input various systems and libraries, such as nix packages, home-manager, github controlled projects, and my identity from a private repository I keep. It then outputs these libraries and configurations into a buildable system using the wider range of configurations listed dendritically. Using an input and output system allows me to version control and define what my configuration imports in order to get the result I want.

## Darwin
Nix-Darwin is my Macbook configuration. I not only manage my NixOS Linux system declaratively, but also my Macbook Pro. I define programs, system defaults, ssh keys, and more using it. This is a must for my Macbook, as typical Nix is made for other architectures and kernels.

## Private Identity
I have a custom flake outside of this repo keeping my identity separate. It is imported using the main flake in this configuration with private keys that allow me access to import that information. This is to keep it out of public prying eyes.

## Overall Declarative Nature
I love declarative deployment. Defining my system this way keeps it organized and exactly the way I want it. It is a different way of thinking about programming, but certainly one I prefer over imperative management. Nix is not exclusively declarative, I can nix-shell or nix-env imperative projects and packages I wish to run in certain points as I please.
