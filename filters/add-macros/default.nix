{ stdenvNoCC
, haskellPackages
}:
stdenvNoCC.mkDerivation {
  name = "add-macros";
  src = ./.;
  buildInputs = [
    (haskellPackages.ghcWithPackages (ps: with ps; [
      pandoc
      unicode-show
      raw-strings-qq
    ]))
  ];
  buildPhase = "ghc Main";
  installPhase = ''
    mkdir -p $out/bin
    cp Main $out/bin/$name
  '';
}
