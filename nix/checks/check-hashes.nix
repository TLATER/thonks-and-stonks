# Ensure that all non-metafile hashes have been correctly updated
{
  mkCheck,
  python311,
}:
mkCheck {
  name = "check-hashes";
  inputs = [
    python311
  ];
  check = ''
    python nix/checks/scripts/check-checksums.py | tee check.log
  '';
}
