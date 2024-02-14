{pkgs}:
pkgs.stdenv.mkDerivation {
  name = "eg-admin-zones";
  pname = "eg-admin-zones";
  src = ./.;
  installPhase = ''
    cp ./eg_admin_boundaries.gpkg $out
  '';
}
