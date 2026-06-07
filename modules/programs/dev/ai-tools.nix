_: let
  aiPkgs = pkgs: with pkgs; [claude-code gemini-cli];
in {
  den.aspects.ai-tools.nixos = {pkgs, ...}: {
    environment.systemPackages = aiPkgs pkgs ++ [pkgs.antigravity-fhs];
  };

  den.aspects.ai-tools.darwin = {pkgs, ...}: {
    homebrew.casks = [
      "claude"
      "antigravity"
      "antigravity-cli"
    ];

    environment.systemPackages = aiPkgs pkgs;
  };
}
