self: super: {
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
}
