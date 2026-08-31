{ lib, ... }:

{
  description = "GTK applications";

  # Toolkit themes affect an entire graphical session and must never follow the
  # global application auto-enable policy.
  activation = "explicit";
  generated = false;
  integration = { };

  home =
    {
      p,
      provider,
      theme,
      ...
    }:
    let
      selected = if provider == null then { name = ""; } else provider;
    in
    lib.mkMerge [
      {
        assertions = [
          {
            assertion = provider != null;
            message = "orchard: ${theme} has no upstream GTK integration";
          }
        ];
      }

      (lib.mkIf (provider != null) {
        gtk = {
          enable = lib.mkDefault true;
          colorScheme = lib.mkDefault (if p.isLight then "light" else "dark");
          theme = {
            name = lib.mkDefault selected.name;
            package = lib.mkDefault (selected.package or null);
          };
        };
      })
    ];
}
