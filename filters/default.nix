{ pkgs }:
let
  inherit (pkgs)
    callPackage
    mkShell
    ;
in
rec {
  packages = {
    center-revealjs = callPackage ./center-revealjs { };
    add-macros = callPackage ./add-macros { };
    render-graphviz = callPackage ./render-graphviz { };
    render-theorem = callPackage ./render-theorem { };
  };
  devShells = {
    center-revealjs = mkShell { inputsFrom = [ packages.center-revealjs ]; };
    add-macros = mkShell { inputsFrom = [ packages.add-macros ]; };
    render-graphviz = mkShell { inputsFrom = [ packages.render-graphviz ]; };
    render-theorem = mkShell { inputsFrom = [ packages.render-theorem ]; };
  };
}
