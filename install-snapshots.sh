#!/bin/bash

# Function to set Snapper configuration
set_snapper_config() {
    local config_name=$1
    local config_dir=$2
    snapper -c $config_name create-config $config_dir
    snapper -c $config_name set-config 'TIMELINE_CREATE=no'
    snapper -c $config_name set-config 'ALLOW_GROUPS=sudo'
    snapper -c $config_name set-config 'SYNC_ACL=yes'
    sed -i 's/TIMELINE_LIMIT_HOURLY="10"/TIMELINE_LIMIT_HOURLY="5"/g' /etc/snapper/configs/$config_name
    sed -i 's/TIMELINE_LIMIT_DAILY="10"/TIMELINE_LIMIT_DAILY="7"/g' /etc/snapper/configs/$config_name
    sed -i 's/TIMELINE_LIMIT_MONTHLY="10"/TIMELINE_LIMIT_MONTHLY="0"/g' /etc/snapper/configs/$config_name
    sed -i 's/TIMELINE_LIMIT_YEARLY="10"/TIMELINE_LIMIT_MONTHLY="0"/g' /etc/snapper/configs/$config_name
}

# Add repository for btrfs-assistant
echo 'deb http://download.opensuse.org/repositories/home:/iDesmI:/more/Debian_12/ /' | sudo tee /etc/apt/sources.list.d/home:iDesmI:more.list
curl -fsSL https://download.opensuse.org/repositories/home:iDesmI:more/Debian_12/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_iDesmI_more.gpg > /dev/null
sudo apt update

# Install snapper-gui and btrfs-assistant
apt install snapper-gui btrfs-assistant -y

# Set up Snapper configurations
set_snapper_config "root" "/"
set_snapper_config "home" "/home"

# Disable snapper-boot.timer
systemctl disable snapper-boot.timer

# Clean up and remount /.snapshots
umount /.snapshots
btrfs su del /.snapshots
mkdir -p /.snapshots
mount -av

# Install and configure grub-btrfs
cd ~/
git clone https://github.com/Antynea/grub-btrfs.git
cd ~/grub-btrfs
make install
update-grub
systemctl enable --now grub.btrfsd
rm -rf ~/grub-btrfs

