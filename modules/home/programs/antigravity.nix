{ pkgs, ... }:

{
  home.packages = with pkgs; [
    antigravity-fhs
  ];

  # Antigravity is a fork of VS Code, it might use ~/.config/antigravity
  # or ~/.vscode for extensions. 
  # For now, just installing the package.
}
