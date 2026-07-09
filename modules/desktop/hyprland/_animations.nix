{ lib, ... }:
let
  lua = lib.generators.mkLuaInline;
in
{
  wayland.windowManager.hyprland.settings = {
    curve =
      {
        md3_decel = "{ type = \"bezier\", points = { { 0.05, 0.7  }, { 0.1,  1    } } }";
        md3_accel = "{ type = \"bezier\", points = { { 0.3,  0    }, { 0.8,  0.15 } } }";
        hyprnostretch = "{ type = \"bezier\", points = { { 0.05, 0.9  }, { 0.1,  1.0  } } }";
        menu_decel = "{ type = \"bezier\", points = { { 0.1,  1    }, { 0,    1    } } }";
        menu_accel = "{ type = \"bezier\", points = { { 0.38, 0.04 }, { 1,    0.07 } } }";
        easeOutExpo = "{ type = \"bezier\", points = { { 0.16, 1    }, { 0.3,  1    } } }";
        softAcDecel = "{ type = \"bezier\", points = { { 0.26, 0.26 }, { 0.15, 1    } } }";
      }
      |> lib.mapAttrsToList (name: points: { _args = [ name (lua points) ]; });

    animation = [
      {
        leaf = "border";
        enabled = true;
        speed = 10;
        bezier = "default";
      }
      {
        leaf = "borderangle";
        enabled = true;
        speed = 100;
        bezier = "softAcDecel";
        style = "once";
      }
      {
        leaf = "windows";
        enabled = true;
        speed = 3;
        bezier = "md3_decel";
        style = "popin 60%";
      }
      {
        leaf = "windowsIn";
        enabled = true;
        speed = 3;
        bezier = "hyprnostretch";
        style = "popin 40%";
      }
      {
        leaf = "windowsOut";
        enabled = true;
        speed = 3;
        bezier = "md3_accel";
        style = "popin 60%";
      }
      {
        leaf = "fade";
        enabled = true;
        speed = 3;
        bezier = "md3_decel";
      }
      {
        leaf = "layersIn";
        enabled = true;
        speed = 3;
        bezier = "menu_decel";
        style = "popin";
      }
      {
        leaf = "layersOut";
        enabled = true;
        speed = 1.6;
        bezier = "menu_accel";
      }
      {
        leaf = "fadeLayersIn";
        enabled = true;
        speed = 2;
        bezier = "menu_decel";
      }
      {
        leaf = "workspaces";
        enabled = true;
        speed = 5;
        bezier = "easeOutExpo";
        style = "slidefadevert 50%";
      }
      {
        leaf = "specialWorkspace";
        enabled = true;
        speed = 3;
        bezier = "md3_decel";
        style = "slidefadevert 15%";
      }
    ];
  };
}
