{ pkgs ? import <nixpkgs> {}, generator ? import ../generator { inherit pkgs; } }:

pkgs.stdenv.mkDerivation {
  name = "candid-red-website";
  src = ./.;
  unpackPhase = ''
    cp -r $src/* .
    chmod -R +w .
  '';

  buildPhase = ''
    export LOCALE_ARCHIVE=${pkgs.glibcLocales}/lib/locale/locale-archive
    export LANG=en_US.utf8
    site build
  '';

  installPhase = ''
    cp -r _site/ $out/
  '';

  phases = [ "unpackPhase" "buildPhase" "installPhase" ];
  buildInputs = [ generator ];
}
