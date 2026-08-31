{ lib, ... }:

{
  description = "Qt applications";

  # Like GTK, this changes every application in the graphical session.
  activation = "explicit";
  generated = false;
  integration = { };

  home =
    {
      pkgs,
      provider,
      theme,
      ...
    }:
    let
      selected =
        if provider == null then
          {
            engine = "";
            name = "";
            package = pkgs.emptyDirectory;
          }
        else
          provider;
    in
    lib.mkMerge [
      {
        assertions = [
          {
            assertion = provider != null;
            message = "orchard: ${theme} has no upstream Qt integration";
          }
        ];
      }

      (lib.mkIf (provider != null) (
        lib.mkMerge [
          { qt.enable = lib.mkDefault true; }

          (lib.mkIf (selected.engine == "kvantum") {
            qt = {
              style.name = lib.mkDefault "kvantum";
              kvantum = {
                enable = lib.mkDefault true;
                themes = lib.mkDefault [ selected.package ];
                settings.General.theme = lib.mkDefault selected.name;
              };
            };
          })

          (lib.mkIf (selected.engine == "adwaita") {
            qt = {
              platformTheme.name = lib.mkDefault "adwaita";
              style = {
                name = lib.mkDefault selected.name;
                package = lib.mkDefault selected.package;
              };
            };
          })
        ]
      ))
    ];
}
