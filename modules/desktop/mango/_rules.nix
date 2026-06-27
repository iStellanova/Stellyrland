_: {
  wayland.windowManager.mango.settings = {
    windowrule = [
      # --- System Dialogs ---
      "isfloating:1,width:0.7,height:0.5,isnoshadow:1,noblur:1,focused_opacity:1.0,unfocused_opacity:1.0,appid:xdg-desktop-portal-gtk"
      "focused_opacity:1.0,unfocused_opacity:1.0,appid:Xdg-desktop-portal-gtk"
      "isfloating:1,appid:zenity"
      "isfloating:1,appid:org.pulseaudio.pavucontrol"

      # --- File Dialogs ---
      "isfloating:1,title:File Operation Progress"
      "isfloating:1,title:Open File"
      "isfloating:1,title:Open Folder"

      # --- Picture-in-Picture ---
      "isfloating:1,focused_opacity:1.0,unfocused_opacity:1.0,isnoshadow:1,noblur:1,title:Picture in picture"
      "isfloating:1,width:0.32,height:0.18,title:Picture-in-Picture"

      # --- Nautilus & Sushi Previewer ---
      "isfloating:1,width:0.5,height:0.5,focused_opacity:1.0,unfocused_opacity:1.0,appid:org.gnome.Sushi"
      "isfloating:1,width:0.5,height:0.5,focused_opacity:1.0,unfocused_opacity:1.0,appid:org.gnome.NautilusPreviewer"

      # --- Per-App Opacity ---
      "focused_opacity:0.85,unfocused_opacity:0.75,appid:org.gnome.Nautilus"
      "focused_opacity:0.8,unfocused_opacity:0.8,appid:kitty"
      "focused_opacity:1.0,unfocused_opacity:0.85,appid:zen"
      "focused_opacity:1.0,unfocused_opacity:1.0,appid:vesktop"
      "focused_opacity:0.6,unfocused_opacity:0.6,title:YouTube Music"
    ];

    tagrule = [
      "id:1,layout_name:scroller"
      "id:2,layout_name:scroller"
      "id:3,layout_name:scroller"
      "id:4,layout_name:scroller"
      "id:5,layout_name:scroller"
      "id:6,layout_name:scroller"
      "id:7,layout_name:scroller"
      "id:8,layout_name:scroller"
      "id:9,layout_name:scroller"
    ];

    layerrule = [
      "animation_type_open:slide,layer_name:notifications"
    ];
  };
}
