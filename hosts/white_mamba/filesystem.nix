{ config, lib, pkgs, ... }:

{
  fileSystems."/F" = {
    device = "/dev/disk/by-uuid/b77a30a3-fcc6-46f4-8210-50b5fea3846c";
    fsType = "btrfs";
    options = ["defaults" "users" "compress=zstd" "exec"];
  };

fileSystems."/home" = {
    device = "/dev/disk/by-uuid/b6a563be-844e-4d8d-a5f7-ba8162a6ae50";
    fsType = "btrfs";
    options = ["defaults" "users" "compress=zstd" "exec"];
  };

fileSystems."/Z" = {
    device = "/dev/disk/by-uuid/B8107B24107AE8B0";
    fsType = "ntfs";
    options = ["defaults" "users" "nofail" "exec"]; #nofail for HDD
  };

}
