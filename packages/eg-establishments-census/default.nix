{pkgs}:
pkgs.stdenv.mkDerivation {
  name = "eg-establishments-census";
  pname = "eg-establishments-census";
  src = ./.;
  installPhase = ''
    mkdir -p $out
    install -v -D -t $out/data/ ./data/establishments/cairo.pdf
    install -v -D -t $out/data/ ./data/establishments/giza.pdf
    install -v -D -t $out/data/ ./data/establishments/qalyubia.pdf
  '';
}
