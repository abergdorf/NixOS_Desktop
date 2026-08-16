{ config, lib, pkgs, ... }:

{
  fileSystems."/F" = {
    device = "/dev/disk/by-uuid/b77a30a3-fcc6-46f4-8210-50b5fea3846c";
    fsType = "btrfs";
    options = ["defaults" "users"];
  };

fileSystems."/Z" = {
    device = "/dev/disk/by-uuid/B81087B24107AE8B0";
    fsType = "ntfs";
    options = ["defaults" "users" "nofail"]; #nofail for HDD
  };

}
