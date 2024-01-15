{ ... }: {
  nix.settings.trusted-users = [ "bernd" ];
  users.users.bernd = {
    isNormalUser = true;
    description = "Bernd Müller";
    extraGroups = [
      "adbusers"
      "wheel"
      "disk"
      "libvirtd"
      "docker"
      "audio"
      "video"
      "input"
      "systemd-journal"
      "networkmanager"
      "network"
      "davfs2"
      "sudo"
      "adm"
      "lp"
      "storage"
      "users"
      "tty"
      "nixosvmtest"
    ];
    openssh.authorizedKeys.keys = [
    ];
    initialPassword = "bernd";
  };
  users.extraGroups.vboxusers.members = [ "bernd" ];
  users.extraGroups.video.members = [ "bernd" ];
}
