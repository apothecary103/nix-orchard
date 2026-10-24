{ lib, rustPlatform }:

rustPlatform.buildRustPackage {
  pname = "orchard-wallpaper";
  version = "0.1.0";

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./Cargo.toml
      ./Cargo.lock
      ./src
    ];
  };

  cargoLock.lockFile = ./Cargo.lock;

  meta = {
    description = "Neutral colour schemes from the wallpaper sway is showing";
    license = lib.licenses.mit;
    mainProgram = "orchard-wallpaper";
  };
}
