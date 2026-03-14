{ config, pkgs, ... }:

{

#uuid of 8tb 940f4332-3aaf-4e83-a244-5d0e3f788569
  fileSystems."/media" = { # Choose your desired mount point
    device = "/dev/disk/by-uuid/940f4332-3aaf-4e83-a244-5d0e3f788569"; # Replace with your actual UUID
    fsType = "ext4"; # Replace with your filesystem type (e.g., "btrfs", "xfs")
    options = [ "defaults" "users" "nofail" ]; # Common options, "nofail" is useful for HDDs
  };

#service needed to get network drive
services.samba = {
  enable = true;
  # nmbd is often needed for NetBIOS name resolution (NixOS-NAS)
  nmbd.enable = true;
  openFirewall = true;
  securityType = "user";

  settings = {
    global = {
      "workgroup" = "WORKGROUP";
      "server string" = "NixOS-NAS";
      "netbios name" = "NixOS-NAS";
      "security" = "user";
      "hosts allow" = "192.168.1. 127.0.0.1 localhost";
      "hosts deny" = "0.0.0.0/0";
      "guest account" = "nobody";
      "map to guest" = "bad user";
    };
    storage = {
      "path" = "/media";
      "browseable" = "yes";
      "read only" = "no";
      "guest ok" = "no";
      "create mask" = "0644";
      "directory mask" = "0755";
      "force user" = "andrew";
    };
  };
};

# Keep this for Windows discovery
services.samba-wsdd = {
  enable = true;
  openFirewall = true;
};

networking.firewall.enable = true;
networking.firewall.allowPing = true;

}
