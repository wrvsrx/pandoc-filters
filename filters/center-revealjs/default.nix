{ stdenvNoCC
, haskellPackages
}:
stdenvNoCC.mkDerivation {
  name = "center-revealjs";
  src = ./.;
  buildInputs = [
    (haskellPackages.ghcWithPackages (ps: with ps; [
      pandoc
    ]))
  ];
  buildPhase = "ghc Main";
  installPhase = ''
    mkdir -p $out/bin
    cp Main $out/bin/$name
  '';
}
