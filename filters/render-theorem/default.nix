{ stdenvNoCC
, haskellPackages
}:
stdenvNoCC.mkDerivation {
  name = "render-theorem";
  src = ./.;
  buildInputs = [
    (haskellPackages.ghcWithPackages (ps: with ps; [
      pandoc
      base16-bytestring
      utf8-string
    ]))
  ];
  buildPhase = "ghc Main";
  installPhase = ''
    mkdir -p $out/bin
    cp Main $out/bin/$name
  '';
}
