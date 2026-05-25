_: {
  # NixOS AI Agent Tools
  flake.modules.nixos.ai-tools = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      claude-code
      gemini-cli
      antigravity-fhs
    ];
  };

  # Darwin AI Agent Tools
  flake.modules.darwin.ai-tools = {pkgs, ...}: {
    homebrew.casks = [
      "claude"
      "antigravity"
      "antigravity-cli"
    ];

    environment.systemPackages = with pkgs; [
      claude-code
      gemini-cli
    ];
  };
}
