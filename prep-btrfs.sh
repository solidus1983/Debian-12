#!/bin/sh

# Variables 
sda1=$(blkid -s UUID -o value /dev/sda1)
sda1_uuid="UUID=$sda1"
sda2=$(blkid -s UUID -o value /dev/sda2)
sda2_uuid="UUID=$sda2"
vg=$(lvs --noheadings -o vg_name | sed 's/^ *//;s/ *$//;s/-/--/') | echo $vg
lv=$(lvs --noheadings -o lv_name | sed 's/^ *//;s/ *$//') | echo $lv
part="$vg-$lv"

# Unmounting and Remounting
umount /target/boot/efi
umount /target/boot/
umount /target
mount /dev/mapper/$part /mnt

# Renaming rootfs
cd /mnt
mv @rootfs/ @

# Creating BTRFS subvolumes
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
mount -o subvol=@,noatime,compress=zstd:1 /dev/mapper/$part /target

# Creating Directories in Target
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

# Mount Directories to their repective subvolumes
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
mount /dev/sda2 /target/boot
mount /dev/sda1 /target/boot/efi

# Creating new fstab for BTRFS
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

# Cleaning Up
cd /
umount /mnt
