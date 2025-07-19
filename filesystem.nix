{ config, pkgs, ... }:

{

#uuid of 8tb 940f4332-3aaf-4e83-a244-5d0e3f788569
  fileSystems."/media" = { # Choose your desired mount point
    device = "/dev/disk/by-uuid/940f4332-3aaf-4e83-a244-5d0e3f788569"; # Replace with your actual UUID
    fsType = "ext4"; # Replace with your filesystem type (e.g., "btrfs", "xfs")
    options = [ "defaults" "users" "nofail" ]; # Common options, "nofail" is useful for HDDs
  };

}
