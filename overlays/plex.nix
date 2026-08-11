self: super:

{
 plexRaw = super.plexRaw.overrideAttrs (oldAttrs: rec {
    version = "1.43.2.10687-563d026ea";

    # The new source URL
    src = super.fetchurl {
      url = "https://downloads.plex.tv/plex-media-server-new/${version}/debian/plexmediaserver_${version}_amd64.deb";
      # The hash you generated with nix-prefetch-url
      sha256 = "13mfmlwvpimyrm3dkdlsr0b9qpbyy5l62q2ckh1xvzgj978j62bn";
    };

    # Update other attributes if necessary (e.g., source hash)
    # Be sure to replace the hash with the one from Step 1.
    # The 'meta' attributes might also need updating if there are significant changes.
    pname = "plexmediaserver";
  });
}
  #do the following command in terminal to get the SHA. Replace the version with the one you want to update to
  #nix-prefetch-url https://downloads.plex.tv/plex-media-server-new/1.43.2.10687-563d026ea/debian/plexmediaserver_1.43.2.10687-563d026ea_amd64.deb
