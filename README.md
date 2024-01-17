<!--toc:start-->

- [NixOS installation](#nixos-installation)
  - [pre steps](#pre-steps)
    - [wipe disk](#wipe-disk)
  - [Prep disk](#prep-disk)
  - [Creating Partitions](#creating-partitions)
  - [encrypt primary disk](#encrypt-primary-disk)
  - [format disks](#format-disks)
  - [mount disks](#mount-disks)
  - [Installation](#installation)
    - [delete old efi entries](#delete-old-efi-entries)
  - [chroot](#chroot)
- [the way when no preconfigured config exists](#the-way-when-no-preconfigured-config-exists)
  - [generate NixOS config](#generate-nixos-config)
  - [NixOS installation](#nixos-installation)
- [Troubleshooting](#troubleshooting)
- [Setup with multiple disks](#setup-with-multiple-disks)
<!--toc:end-->

# NixOS installation

## pre steps

```bash
sudo -i
loadkeys de-latin1
```

- verify UEFI mode: `ls /sys/firmware/efi/efivars` -> if not empty then UEFI is active
- connect to internet:

```bash
sudo systemctl start wpa_supplicant
wpa_cli
> add_network
0
> set_network 0 ssid "Judaeisch Volksfront"
OK
> set_network 0 psk "mypassword"
OK
> set_network 0 key_mgmt WPA-PSK
OK
> enable_network 0
OK
```

- enable ssh: `systemctl start sshd.service`
- set root passwd `passwd`
- show disks with: `fdisk -l`

### wipe disk

- overwrite disk with zeros

```bash
dd if=/dev/zero of=/dev/nvme0n1 bs=4096 status=progress
```

## Prep disk

```bash
# find your drive
lsblk
# wipe drive
wipefs -a /dev/nvme1n1
```

## Creating Partitions

create boot and LVM root partition, they will then have the labels `boot` and `root`

```bash
export ROOT_DISK=/dev/nvme1n1

# Create boot partition first
parted -a opt --script "${ROOT_DISK}" \
    mklabel gpt \
    mkpart primary fat32 0% 512MiB \
    mkpart primary 512MiB 100% \
    set 1 esp on \
    name 1 boot \
    set 2 lvm on \
    name 2 root
```

## encrypt primary disk

here we use the labels given to the partitions in the previous step

```bash
# encrypt primary disk
cryptsetup luksFormat /dev/disk/by-partlabel/root
# open it again
cryptsetup luksOpen /dev/disk/by-partlabel/root root
# create physical LVM volume
pvcreate /dev/mapper/root
# create volume group
vgcreate vg /dev/mapper/root
# create swap volume, tip: RAM + 2G
lvcreate -L 34G -n swap vg
# create logical root volume
lvcreate -l '100%FREE' -n root vg
# show volumes
lvdisplay
```

## format disks

```bash
mkfs.fat -F 32 -n boot /dev/disk/by-partlabel/boot
mkfs.ext4 -L root /dev/vg/root
mkswap -L swap /dev/vg/swap
swapon -s
```

## mount disks

```bash
mount /dev/disk/by-label/root /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot
swapon /dev/vg/swap
```

## Installation

- install needed packages into `nix-shell`
- clone this repo into `/mnt/etc/nixos`
- install the provided config via flake

```bash
nix-shell -p git nixFlakes efibootmgr
git clone https://github.com/muellerbernd/nixos-example.git /mnt/etc/nixos
nixos-install --root /mnt --flake /mnt/etc/nixos#t480
reboot # if needed
```

### delete old efi entries

if you want to delete old efi entries you can use the following command

> [more documentation](https://linuxconfig.org/how-to-manage-efi-boot-manager-entries-on-linux)

```bash
efibootmgr --delete-bootnum --bootnum 0
```

## chroot

- chroot into NixOS install and change passwords if needed

```bash
nixos-enter
passwd username
```

# the basic way when no preconfigured config exists

## generate NixOS config

generate config and modify `configuration.nix`

```bash
sudo nixos-generate-config --root /mnt
cd /mnt/etc/nixos/
sudo vim configuration.nix
```

## NixOS installation

install your configuration

```bash
cd /mnt
sudo nixos-install
```

after installation: Run passwd to change user password.

if internet broke/breaks, try one of the following:

```bash
nixos-rebuild switch --option substitute false # no downloads
nixos-rebuild switch --option binary-caches "" # no downloads
wpa_supplicant flags to connect to wifi
```

# Troubleshooting

```bash
package ‘spotify-1.2.11.916.geb595a67’ in /nix/store/7mw77xnyhapazhcj4yxngvdsmjxhnqvx-nixos-23.05.4112.5a237aecb572/nixos/pkgs/applications/audio/spotify/default.nix:14 has an unfree license (‘unfree’), refusing to evaluate.

a) To temporarily allow unfree packages, you can use an environment variable
  for a single invocation of the nix tools.

    $ export NIXPKGS_ALLOW_UNFREE=1

Note: For `nix shell`, `nix build`, `nix develop` or any other Nix 2.4+
(Flake) command, `--impure` must be passed in order to read this
environment variable.

b) For `nixos-rebuild` you can set
 { nixpkgs.config.allowUnfree = true; }
in configuration.nix to override this.

Alternatively you can configure a predicate to allow specific packages:
 { nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
     "spotify"
   ];
 }

c) For `nix-env`, `nix-build`, `nix-shell` or any other Nix command you can add
 { allowUnfree = true; }
to ~/.config/nixpkgs/config.nix.
```
