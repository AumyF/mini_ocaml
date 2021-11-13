{
  description = "A very basic flake";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.opal = {
    flake = false;
    url = "github:pyrocat101/opal/v0.1.1";
  };

  outputs = { self, nixpkgs, flake-utils, opal }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system}; in
      rec {
        packages = flake-utils.lib.flattenTree
          {
            mini-ocaml = pkgs.callPackage ./default.nix { };
          };
        defaultPackage = packages.mini-ocaml;
        apps.mini-ocaml = flake-utils.lib.mkApp { drv = packages.mini-ocaml; };
        defaultApp = apps.mini-ocaml;
        devShell = pkgs.callPackage ./shell.nix { };
      }
    );
}
