{ ... }:
{
  modules.nixos.homepage = {
    services.homepage-dashboard = {
      enable = true;
      settings = {
        theme = "dark";
        color = "slate";
        headerStyle = "clean";
        statusStyle = "dot";
        cardBlur = "md";
      };
      widgets = [
        {
          resources = {
            cpu = true;
            memory = true;
            disk = "/";
          };
        }
      ];
    };
  };
}
