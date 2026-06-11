{
  sn,
  ...
}: let
  aiPkgs = pkgs: with pkgs; [claude-code gemini-cli];
in {
  sn.dev = {includes = [sn.ai-tools];};

  sn.ai-tools.nixos = {pkgs, ...}: {
    environment.systemPackages = aiPkgs pkgs ++ [pkgs.antigravity-fhs];
  };

  sn.ai-tools.darwin = {pkgs, ...}: {
    homebrew.casks = [
      "claude"
      "antigravity"
      "antigravity-cli"
    ];

    environment.systemPackages = aiPkgs pkgs;
  };
}
