{
  description = "flake template";

  inputs = {
    flake-lock.url = "github:wrvsrx/flake-lock";
    nixpkgs.follows = "flake-lock/nixpkgs";
    flake-parts.follows = "flake-lock/flake-parts";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" ];
    perSystem = { pkgs, ... }:
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
