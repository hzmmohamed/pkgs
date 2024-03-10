{pkgs}:
pkgs.stdenv.mkDerivation {
  name = "eg-buildings-census";
  pname = "eg-buildings-census";
  src = ./.;
  installPhase = ''
    mkdir -p $out
    install -v -D -t $out/data/ ./data/buildings/cairo.pdf
    install -v -D -t $out/data/ ./data/buildings/giza.pdf
    install -v -D -t $out/data/ ./data/buildings/qalyubia.pdf
  '';
}
