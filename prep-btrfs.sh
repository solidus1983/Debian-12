#!/bin/sh

# Variables 
echo "Getting UUID for /dev/sda1"
sda1=$(blkid -s UUID -o value /dev/sda1)
sda1_uuid="UUID=$sda1"
echo "UUID for /dev/sda1: $sda1_uuid"

echo "Getting UUID for /dev/sda2"
sda2=$(blkid -s UUID -o value /dev/sda2)
sda2_uuid="UUID=$sda2"
echo "UUID for /dev/sda2: $sda2_uuid"

echo "Getting VG names"
vg=$(lvs --noheadings -o vg_name | sed 's/^ *//;s/ *$//;s/-/--/')
echo "VG names: $vg"

echo "Getting LV names"
lv=$(lvs --noheadings -o lv_name | sed 's/^ *//;s/ *$//')
echo "LV names: $lv"

part="$vg"-"$lv"
echo "Partition: $part"

crypt=$(awk '$4 ~ /^sda[0-9]+_crypt$/ {print "/dev/" $4}' /proc/partitions)
echo "Crypt partition: $crypt"

echo "Getting UUID for encrypted partition"
crypt_uuid=$(blkid -s UUID -o value /dev/$crypt)
echo "UUID for encrypted partition: $crypt_uuid"

# Unmounting and Remounting
echo "Unmounting /target/boot/efi"
umount /target/boot/efi
echo "Unmounting /target/boot/"
umount /target/boot/
echo "Unmounting /target"
umount /target
echo "Mounting /dev/mapper/$part to /mnt"
mount /dev/mapper/$part /mnt

# Renaming rootfs
echo "Renaming rootfs"
cd /mnt
mv @rootfs/ @

# Creating BTRFS subvolumes
echo "Creating BTRFS subvolumes"
btrfs subvolume create @snapshots
btrfs subvolume create @home
btrfs subvolume create @root
btrfs subvolume create @log
btrfs subvolume create @containers
btrfs subvolume create @images
btrfs subvolume create @var
btrfs subvolume create @opt
btrfs subvolume create @AccountsService
btrfs subvolume create @gdm
btrfs subvolume create @tmp

# Mounting root subvolume
echo "Mounting root subvolume"
mount -o subvol=@,noatime,compress=zstd:1 /dev/mapper/$part /target

# Creating Directories in Target
echo "Creating Directories in Target"
cd /target
mkdir -p boot/efi
mkdir -p etc
mkdir -p .snapshots
mkdir -p home
mkdir -p root
mkdir -p var/log
mkdir -p var/lib/containers
mkdir -p var/lib/libvirt/images
mkdir -p var/lib/AccountsService
mkdir -p var/lib/gdm3
mkdir -p tmp
mkdir -p opt

# Mount Directories to their respective subvolumes
echo "Mounting Directories to their respective subvolumes"
mount -o subvol=@snapshots,noatime,compress=zstd:1 /dev/mapper/$part /target/.snapshots
mount -o subvol=@home,noatime,compress=zstd:1 /dev/mapper/$part /target/home
mount -o subvol=@root,noatime,compress=zstd:1 /dev/mapper/$part /target/root
mount -o subvol=@log,noatime,compress=zstd:1 /dev/mapper/$part /target/var/log
mount -o subvol=@containers,noatime,compress=zstd:1 /dev/mapper/$part /target/var/lib/containers
mount -o subvol=@images,noatime,compress=zstd:1 /dev/mapper/$part /target/var/lib/libvirt/images
mount -o subvol=@AccountsService,noatime,compress=zstd:1 /dev/mapper/$part /target/var/lib/AccountsService
mount -o subvol=@gdm,noatime,compress=zstd:1 /dev/mapper/$part /target/var/lib/gdm3
mount -o subvol=@tmp,noatime,compress=zstd:1 /dev/mapper/$part /target/tmp
mount -o subvol=@opt,noatime,compress=zstd:1 /dev/mapper/$part /target/opt

# Mount bootable volumes
echo "Mounting bootable volumes"
mount /dev/sda2 /target/boot
mount /dev/sda1 /target/boot/efi

# Creating new fstab for BTRFS
echo "Creating new fstab for BTRFS"
rm /target/etc/fstab
touch /target/etc/fstab
echo -e "/dev/mapper/$part	/ 			  btrfs   subvol=@,noatime,compress=zstd:1								0   0" >> /target/etc/fstab
echo -e "/dev/mapper/$part	/.snapshots   btrfs   subvol=@snapshots,noatime,compress=zstd:1   					0   0" >> /target/etc/fstab
echo -e "/dev/mapper/$part	/root 		  btrfs   subvol=@root,noatime,compress=zstd:1							0   0" >> /target/etc/fstab
echo -e "/dev/mapper/$part	/home 	   	  btrfs   subvol=@home,noatime,compress=zstd:1							0   0" >> /target/etc/fstab
echo -e "/dev/mapper/$part	/var/log  	  btrfs   subvol=@log,noatime,compress=zstd:1							0   0" >> /target/etc/fstab
echo -e "/dev/mapper/$part	/var/lib/AccountsService   btrfs   subvol=@AccountsService,noatime,compress=zstd:1   0   0" >> /target/etc/fstab
echo -e "/dev/mapper/$part	/var/lib/gdm3  btrfs   subvol=@gdm,noatime,compress=zstd:1							0   0" >> /target/etc/fstab
echo -e "/dev/mapper/$part	/tmp  		  btrfs   subvol=@tmp,noatime,compress=zstd:1							0   0" >> /target/etc/fstab
echo -e "/dev/mapper/$part	/opt  		  btrfs   subvol=@opt,noatime,compress=zstd:1							0   0" >> /target/etc/fstab
echo -e "/dev/mapper/$part	/var/lib/libvirt/images	btrfs   subvol=@images,noatime,compress=zstd:1				0   0" >> /target/etc/fstab
echo -e "/dev/mapper/$part	/var/lib/containers 	btrfs   subvol=@containers,noatime,compress=zstd:1   			0   0" >> /target/etc/fstab
echo -e "$sda2_uuid	/boot   	   ext2 	defaults 	0   2" >> /target/etc/fstab
echo -e "$sda1_uuid	/boot/efi   vfat 	umask=0077  0   1" >> /target/etc/fstab

# Creating crypttab
echo "Creating crypttab"
touch /target/etc/crypttab
echo -e "$crypt UUID=$crypt_uuid none luks,discard" >> /target/etc/crypttab

# Cleaning Up
echo "Cleaning Up"
cd /
umount /mnt
