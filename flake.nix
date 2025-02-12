{
  description = "flake template";

  inputs = {
    nixpkgs.url = "github:wrvsrx/nixpkgs/patched-nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      flake = {
        overlays.default = final: prev: (import ./filters { pkgs = prev; }).packages;
      };
      perSystem =
        { pkgs, ... }:
        let
          filters = import ./filters { inherit pkgs; };
        in
        {
          packages = filters.packages;
          devShells = filters.devShells;
          formatter = pkgs.nixpkgs-fmt;
        };
    };
}
