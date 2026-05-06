# Multi-System Management
## Definition
I have a host linux system and a Macbook Pro I do remote and mobile work with. As great as they are individually, I wanted something unifying. After I had migrated to NixOS, as documented in my workflow-journey, I now had the tools to manage everything in a very special way. I discovered this about 3 weeks into my nixOS system.

## My Ideal Workflow
I wanted my work to feel seamless, connected, and, most importantly, organized. Nix was doing all of this perfectly in NixOS. Discovering Nix-Darwin, a tool to manage MacOS declaratively, I knew I just had to use it.

## How I did it
I made note of programs that are platform-agnostic. Things such as kitty, discord, zed, btop, among other things, were programs and configurations that did not care about the system it was running on. Home-manager and Nix knew how to get those put together, I just had to define them and add nix-darwin to my flake as an input and output.

1. **Restructured Configurations**
  I restructured my NixOS configuration to have a new host and installed `if isDarwin` statements across my configurations. This allowed NixOS-specific aspects and configurations to differentiate themselves from Nix-Darwin, allowing the system to build on both machines cleanly.
2. **Dendritic Migration**
  At some point, I decided to migrate to the dendritic architecture, documented in workflow-journey. In doing so, I could enable specific aspects declaratively and in whole parts with one host configuration, using the same aspects for both systems where it makes sense. This greatly cleaned up my maintenance and made organization a whole lot easier.
3. **Ultimate Organization and Deployment**
  This matters to me the most. I love organization and hands-on configuration. Having it all in one place for both systems is the ultimate housekeeping method. This is incredibly important to me, as both machines now pull from the same repo using the same configuration. In a scenario I'd need to wipe a machine or use a new one, pulling this configuration would turn it into a system I've already been configuring for months.
