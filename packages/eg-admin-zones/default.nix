{pkgs}:
pkgs.stdenv.mkDerivation {
  name = "eg-admin-zones";
  pname = "eg-admin-zones";
  src = ./.;
  installPhase = ''
    mkdir -p $out
    install -v -D -t $out/data/ ./eg_admin_boundaries.gpkg
  '';
}
