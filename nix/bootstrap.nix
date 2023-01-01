{
  pack-meta,
  stdenv,
  lib,
  writeText,
  fetchurl,
  src,
  zip,
}: let
  # Basic PrismLauncher pack metadata
  mmc-pack-meta = writeText "mmc-pack.json" (builtins.toJSON {
    components = [
      {
        cachedName = "LWJGL 3";
        dependencyOnly = true;
        uid = "org.lwjgl3";
        version = "3.2.2.";
      }
      {
        cachedName = "Minecraft";
        cachedRequires = [
          {
            suggests = "3.2.2";
            uid = "org.lwjgl3";
          }
        ];
        important = true;
        uid = "net.minecraft";
        version = pack-meta.versions.minecraft;
      }
      {
        cachedName = "Forge";
        cachedRequires = [
          {
            equals = pack-meta.versions.minecraft;
            uid = "net.minecraft";
          }
        ];
        uid = "net.minecraftforge";
        version = pack-meta.versions.forge;
      }
    ];

    formatVersion = 1;
  });

  # Instance configuration
  instance-config = writeText "instance.cfg" ''
    InstanceType=OneSix
    JoinServerOnLaunch=false
    OverrideCommands=true
    OverrideConsole=false
    OverrideGameTime=false
    OverrideJavaArgs=false
    OverrideJavaLocation=false
    OverrideMemory=false
    OverrideMiscellaneous=false
    OverrideNativeWorkarounds=false
    OverridePerformance=false
    OverrideWindow=false
    PostExitCommand=
    PreLaunchCommand="$INST_JAVA" -jar packwiz-installer-bootstrap.jar https://tlater.github.io/thonks-and-stonks/${pack-meta.version}/pack.toml
    WrapperCommand=
    iconKey=WhateverThisIs
    name=Thonks & Stonks
  '';

  packwiz-installer-bootstrap = fetchurl {
    url = "https://github.com/packwiz/packwiz-installer-bootstrap/releases/download/v0.0.3/packwiz-installer-bootstrap.jar";
    sha256 = "sha256-qPuyTcYEJ46X9GiOgtPZGjGLmO/AjV2/y8vKtkQ9EWw=";
  };
in
  stdenv.mkDerivation {
    inherit src;
    inherit (pack-meta) version;

    pname = "thonks-and-stonks-bootstrap";

    noCC = true;
    buildInputs = [
      zip
    ];

    buildPhase = ''
      mkdir build && cd build

      # Create all the files and directories PrismLauncher expects in an export
      mkdir -p minecraft/{coremods,mods,resourcepacks,saves,screenshots,shaderpacks,texturepacks}
      cp ${instance-config} instance.cfg
      cp ${mmc-pack-meta} mmc-pack.json

      # Add the PrismLauncher icon
      cp ../src/icon.png WhateverThisIs.png

      # Add the packwiz installer bootstrap jar
      cp ${packwiz-installer-bootstrap} minecraft/packwiz-installer-bootstrap.jar

      # Zip 'er up
      zip -r 'Thonks & Stonks-${pack-meta.version}.zip' .
    '';

    installPhase = ''
      mkdir -p $out
      cp 'Thonks & Stonks-${pack-meta.version}.zip' $out/
    '';
  }
