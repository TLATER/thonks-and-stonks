{
  self,
  pkgs,
}: {
  deploy-pages = {
    type = "app";
    program = toString (pkgs.lib.getBin (pkgs.python311.pkgs.buildPythonApplication {
      name = "deploy-pages";
      src = ./scripts/deploy-pages.py;

      propagatedBuildInputs = with pkgs; [
        git
        python311.pkgs.mistune
      ];

      format = "other";
      unpackCmd = ''
        mkdir src
        cp $curSrc src/deploy-pages.py
      '';

      installPhase = ''
        mkdir -p $out/bin/
        cp deploy-pages.py $out/bin/deploy-pages
        chmod +x $out/bin/deploy-pages
      '';
    })) + "/bin/deploy-pages";
  };
}
