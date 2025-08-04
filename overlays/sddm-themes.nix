self: super:
{
  #--------theme1-----------------
  sddm-sugar-dark = super.stdenv.mkDerivation rec {
    pname = "sddm-sugar-dark-theme";
    version = "1.2";

    src = super.fetchFromGitHub {
      owner = "MarianArlt";
      repo = "sddm-sugar-dark";
      rev = "v${version}";
      # The sha256 you provided is likely outdated.
      # Replace the hash below with the one Nix gives you after a failed build.
      sha256 = "sha256-C3qB9hFUeuT5+Dos2zFj5SyQegnghpoFV9wHvE9VoD8=";
    };

    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/sddm/themes
      cp -aR $src $out/share/sddm/themes/sugar-dark
      runHook postInstall
    '';

    meta = with super.lib; {
      description = "Sugar Dark theme for SDDM";
      homepage = "https://github.com/MarianArlt/sddm-sugar-dark";
      license = licenses.gpl3Only;
      platforms = platforms.all;
    };
  };
  #--------theme2------------------
  sddm-astronaut-theme= super.stdenv.mkDerivation rec{
    pname = "sddm-astronaut-theme";
    version = "unstable 25-06-21";

    src = super.fetchFromGitHub {
      owner = "keyitdev";
      repo = "sddm-astronaut-theme";
      rev = "3ef9f511fd072ff3dbb6eb3c1c499a71f338967e";
      # Use the placeholder and let Nix tell you the correct hash on the next build
      sha256 = "sha256-33CzZ4vK1dicVzICbudk8gSRC/MExG+WnrE9wIWET14=";
    };

    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/sddm/themes
      # Copy ALL directories from the src/ folder
      cp -aR $src $out/share/sddm/themes/sddm-astronaut-theme
      substituteInPlace $out/share/sddm/themes/sddm-astronaut-theme/metadata.desktop \
        --replace "ConfigFile=Themes/astronaut.conf" "ConfigFile=Themes/pixel_sakura.conf"
      runHook postInstall
    '';

    meta = with super.lib; {
      description = "SDDM-Astronaut themes";
      homepage = "https://github.com/Keyitdev/sddm-astronaut-theme";
      license = licenses.gpl3Only;
    };
  };
  #-------------
}

