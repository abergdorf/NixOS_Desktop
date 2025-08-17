self: super:

{
 plexRaw = super.plexRaw.overrideAttrs (oldAttrs: rec {
    version = "1.42.1.10060-4e8b05daf";

    # The new source URL
    src = super.fetchurl {
      url = "https://downloads.plex.tv/plex-media-server-new/${version}/debian/plexmediaserver_${version}_amd64.deb";
      # The hash you generated with nix-prefetch-url
      sha256 = "1x4ph6m519y0xj2x153b4svqqsnrvhq9n2cxjl50b9h8dny2v0is";
    };

    # Update other attributes if necessary (e.g., source hash)
    # Be sure to replace the hash with the one from Step 1.
    # The 'meta' attributes might also need updating if there are significant changes.
    pname = "plexmediaserver";
  });
}
