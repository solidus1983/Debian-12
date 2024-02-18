#!/bin/bash

# Logging function
log() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1"
}

# Function to install base packages
install_base_packages() {
    log "Installing base packages..."
    sudo apt install gnupg dirmngr apt-transport-https console-setup git ca-certificates curl build-essential checkinstall zlib1g-dev libssl-dev micro inotify-tools htop -y || { log "Failed to install base packages. Exiting."; exit 1; }
    log "Base packages installed."
}

# Function to install packages
install_packages() {
    log "Installing packages: $@"
    sudo apt install "$@" -y || { log "Failed to install packages: $@. Exiting."; exit 1; }
    log "Packages installed: $@"
}

# Function to add a repository
add_repository() {
    local file_path="$1"
    local repo_content="$2"
    log "Adding repository to $file_path..."
    echo "$repo_content" | sudo tee "$file_path" > /dev/null || { log "Failed to add repository to $file_path. Exiting."; exit 1; }
    log "Repository added to $file_path."
}

# Function to add a key
add_key() {
    local key_url="$1"
    local key_destination="$2"
    log "Downloading key from $key_url and adding to $key_destination..."
    # Remove existing key if it exists
    sudo rm -f "$key_destination"
    # Add the new key
    curl -fsSL "$key_url" | sudo gpg --dearmor -o "$key_destination" || { log "Failed to add key from $key_url to $key_destination. Exiting."; exit 1; }
    log "Key added to $key_destination."
}

# Function to update package lists
update_packages() {
    log "Updating package lists..."
    sudo apt update || { log "Failed to update package lists. Exiting."; exit 1; }
    log "Package lists updated."
}

# Function to install Regolith Desktop and additional packages
install_regolith() {
    log "Installing Regolith Desktop and additional packages..."
    # Add Regolith repository
    add_key "https://regolith-desktop.org/regolith.key" "/usr/share/keyrings/regolith-archive-keyring.gpg"
    add_repository "/etc/apt/sources.list.d/regolith.list" 'deb [arch=amd64 signed-by=/usr/share/keyrings/regolith-archive-keyring.gpg] https://regolith-desktop.org/release-3_1-debian-bookworm-amd64  bookworm main'
    # Install Regolith
    sudo apt update && sudo apt install regolith-desktop regolith-session-flashback regolith-lightdm-config regolith-control-center i3xrocks-focused-window-name i3xrocks-rofication i3xrocks-info i3xrocks-app-launcher i3xrocks-memory i3xrocks-battery -y || { log "Failed to install Regolith Desktop. Exiting."; exit 1; }
    log "Regolith Desktop and additional packages installed."
}

# Function to install Regolith Look package and additional themes
install_regolith_look() {
    log "Installing Regolith Look package and additional themes..."
    sudo apt install regolith-look-ayu regolith-look-ayu-dark regolith-look-ayu-mirage regolith-look-blackhole regolith-look-gruvbox regolith-look-nord regolith-look-nevil regolith-look-dracula -y || { log "Failed to install Regolith Look package and additional themes. Exiting."; exit 1; }
    log "Regolith Look package and additional themes installed."
}

# Function to install Flatpak
install_flatpak() {
    log "Installing Flatpak..."
    sudo apt install flatpak gnome-software-plugin-flatpak -y || { log "Failed to install Flatpak. Exiting."; exit 1; }
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || { log "Failed to add Flathub repository. Exiting."; exit 1; }
    log "Flatpak installed."
}

# Function to install Snap
install_snap() {
    log "Installing Snap..."
    sudo apt install snap gnome-software-plugin-snap -y || { log "Failed to install Snap. Exiting."; exit 1; }
    log "Snap installed."
}

# Function to install Microsoft Edge
install_microsoft_edge() {
    add_key "https://packages.microsoft.com/keys/microsoft.asc" "/usr/share/keyrings/microsoft-edge.gpg"
    add_repository "/etc/apt/sources.list.d/microsoft-edge.list" "deb [signed-by=/usr/share/keyrings/microsoft-edge.gpg] https://packages.microsoft.com/repos/edge stable main"
    log "Installing Microsoft Edge..."
    sudo apt install microsoft-edge-stable -y || sudo snap install microsoft-edge-stable || { log "Failed to install Microsoft Edge. Exiting."; exit 1; }
    log "Microsoft Edge installed."
}

# Function to install Google Chrome
install_google_chrome() {
    log "Installing Google Chrome..."
    add_key "https://dl.google.com/linux/linux_signing_key.pub" "/usr/share/keyrings/google-chrome.gpg"
    add_repository "/etc/apt/sources.list.d/google-chrome.list" "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main"
    sudo apt update && sudo apt install google-chrome-stable -y || { log "Failed to install Google Chrome. Exiting."; exit 1; }
    log "Google Chrome installed."
}

# Function to install Firefox
install_firefox() {
    add_key "https://packages.mozilla.org/apt/repo-signing-key.gpg" "/usr/share/keyrings/packages.mozilla.org.gpg"
    add_repository "/etc/apt/sources.list.d/mozilla-firefox.list" "deb [signed-by=/usr/share/keyrings/packages.mozilla.org.gpg] https://packages.mozilla.org/apt mozilla main"
    log "Installing Firefox..."
    sudo apt install firefox-esr -y || { log "Failed to install Firefox. Exiting."; exit 1; }
    log "Firefox installed."
}

# Function to install Brave
install_brave() {
    log "Installing Brave..."
    add_key "https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg" "/usr/share/keyrings/brave-browser-archive-keyring.gpg"
    add_repository "/etc/apt/sources.list.d/brave-browser.list" "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main"
    sudo apt update && sudo apt install brave-browser -y || { log "Failed to install Brave. Exiting."; exit 1; }
    log "Brave installed."
}

# Function to install VSCode and set up extensions
install_vscode() {
    log "Installing VSCode and setting up extensions..."
    add_key "https://packages.microsoft.com/keys/microsoft.asc" "/usr/share/keyrings/packages.microsoft.gpg"
    add_repository "/etc/apt/sources.list.d/vscode.list" "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main"
    sudo apt update && sudo apt install code -y || { log "Failed to install VSCode. Exiting."; exit 1; }
    # Install VSCode extensions from file
    while IFS= read -r extension || [[ -n "$extension" ]]; do
        code --install-extension "$extension" || { log "Failed to install VSCode extension: $extension"; }
    done < extensions
    log "VSCode and extensions installed."
}

# Function to detect hardware and install appropriate packages
detect_hardware() {
    log "Detecting hardware..."
    if sudo dmidecode -t system | grep -q "ThinkPad T440p"; then
        log "Detected ThinkPad T440p. Installing additional packages..."
        install_thinkpad_t440p_packages
    elif sudo dmidecode -t system | grep -q "Precision 5760"; then
        log "Detected Dell Precision 5760. Installing additional packages..."
        install_dell_precision_5760_packages
    elif sudo dmidecode -t system | grep -q "XPS 13"; then
        log "Detected Dell XPS 13. Installing additional packages..."
        install_dell_precision_13_packages
    else
        log "Hardware not recognized. Skipping additional package installation."
    fi
}

# Function to install common packages
install_common_packages() {
    install_base_packages
    install_packages fprintd libfprint-2-2 fprintd libpam-fprintd tlp tlp-rdw simplescreenrecorder -y
}

# Function to install Dell Precision 5760specific packages
install_dell_precision_5760_packages() {
    log "Installing Dell Precision 5760 specific packages..."
    # Additional Dell drivers
    sudo add-apt-repository ppa:oem-solutions-engineers/oem-projects-meta
    sudo tee /etc/apt/sources.list.d/oem-somerville-stantler-meta.list > /dev/null <<p5760-1
    deb http://dell.archive.canonical.com/ jammy somerville
    deb http://dell.archive.canonical.com/ jammy somerville-stantler
p5760-1
    sudo tee /etc/apt/sources.list.d/oem-solutions-engineers-ubuntu-oem-projects-meta-jammy.list > /dev/null <<p5760-2
    deb https://ppa.launchpadcontent.net/oem-solutions-engineers/oem-projects-meta/ubuntu/ jammy main
    deb-src https://ppa.launchpadcontent.net/oem-solutions-engineers/oem-projects-meta/ubuntu/ jammy main
p5760-2
    sudo apt update
    sudo apt install ubuntu-oem-keyring oem-somerville-stantler-meta firmware-sof-signed inxi alsa-base -y || { log "Failed to install Dell Precision 5760-specific packages. Exiting."; exit 1; }
    log "Dell Precision 5760-specific packages installed."
}

# Function to install Dell XPS 13 specific packages
install_dell_xps_13_packages() {
    log "Installing Dell XPS 13 specific packages..."
    # Additional Dell drivers
    sudo add-apt-repository ppa:oem-solutions-group/intel-ipu6
    sudo add-apt-repository ppa:oem-solutions-engineers/oem-projects-meta
    sudo tee /etc/apt/sources.list.d/oem-somerville-tentacool-meta.list > /dev/null <<xps13-1
    deb http://dell.archive.canonical.com/ jammy somerville
    deb http://dell.archive.canonical.com/ jammy somerville-tentacool
xps13-1
    sudo tee /etc/apt/sources.list.d/oem-solutions-engineers-ubuntu-oem-projects-meta-jammy.list > /dev/null <<xps13-2
    deb https://ppa.launchpadcontent.net/oem-solutions-engineers/oem-projects-meta/ubuntu/ jammy main
    deb-src https://ppa.launchpadcontent.net/oem-solutions-engineers/oem-projects-meta/ubuntu/ jammy main
xps13-2
    sudo apt install ubuntu-oem-keyring oem-somerville-tentacool-meta firmware-sof-signed inxi alsa-base \
    gstreamer1.0-icamera libcamhal-ipu6ep0 tlp tlp-rdw -y || { log "Failed to install Dell Precision 5760-specific packages. Exiting."; exit 1; }
    log "Dell XPS 13 specific packages installed."
}

# Function to install ThinkPad T440p-specific packages
install_thinkpad_t440p_packages() {
    log "Installing ThinkPad T440p-specific packages..."
    # Additional ThinkPad drivers
    sudo apt install lm-sensors thinkfan acpitool tp-smapi-dkms tpb tlp tlp-rdw nvidia-tesla-470-driver -y || { log "Failed to install ThinkPad T440p-specific packages. Exiting."; exit 1; }
    
    # Configure thinkfan
    echo "options thinkpad_acpi fan_control=1" | sudo tee /etc/modprobe.d/thinkpad_acpi.conf > /dev/null || { log "Failed to write thinkpad_acpi options. Exiting."; exit 1; }
    sudo modprobe -rv thinkpad_acpi || { log "Failed to load thinkpad_acpi module. Exiting."; exit 1; }
    sudo modprobe -v thinkpad_acpi || { log "Failed to load thinkpad_acpi module. Exiting."; exit 1; }
    echo 'THINKFAN_ARGS="-c /etc/thinkfan.conf"' | sudo tee -a /etc/default/thinkfan
    sudo tee /etc/thinkfan.conf > /dev/null <<EOT || { log "Failed to configure thinkfan. Exiting."; exit 1; }
# /etc/thinkfan.conf
#sensor /proc/acpi/ibm/thermal (0, 10, 15, 2, 10, 5, 0, 3, 0, 3)
#sensor /proc/acpi/ibm/thermal (0, 0, 0, 0, 0, 0, 0, 0, 10, 0, 0, 0, 0, 0, 0, 0)
sensor /sys/devices/virtual/thermal/thermal_zone1/temp
sensor /sys/devices/platform/thinkpad_hwmon/temp1_input
sensor /sys/devices/platform/thinkpad_hwmon/temp2_input
sensor /sys/devices/platform/thinkpad_hwmon/temp3_input
sensor /sys/devices/platform/thinkpad_hwmon/temp4_input
sensor /sys/devices/platform/thinkpad_hwmon/temp9_input (10)

(0,	0,	55)
(1,	48,	57)
(2,	50,	59)
(3,	52,	60)
(4,	54,	61)
(5,	56,	62)
("level full-speed",	57,	32767)
EOT

    # Restart thinkfan
    sudo systemctl restart thinkfan || { log "Failed to restart thinkfan. Exiting."; exit 1; }
    
    # Configure TLP
    sudo tlp start || { log "Failed to start TLP. Exiting."; exit 1; }

    # Log  
    log "ThinkPad T440p-specific packages installed and configured."
}

# Function to install development compiling tools
install_dev_compiling() {
    log "Installing development compiling tools..."
    sudo apt install device-tree-compiler build-essential gawk gcc-multilib flex git gettext libncurses5-dev libssl-dev python3-distutils \
    libncursesw5-dev xsltproc rsync wget unzip python3 rsync subversion swig time libelf-dev java-propose-classpath ccache ecj fastjar file g++ python3-setuptools \
    openjdk-17-jdk bcc libxml-parser-perl libusb-dev bin86 sharutils zip fakeroot make sed bison autoconf automake python3 patch perl-modules* python3-dev bash binutils \
    bzip2 gcc util-linux intltool help2man python3 python3-pip python-is-python3 openjdk-17-jdk wireshark nmap whois mtr traceroute tcptraceroute cutecom putty subversion -y || { log "Failed to install development compiling tools. Exiting."; exit 1; }
    log "Development compiling tools installed."
}

# Function to install Docker
install_docker() {
    log "Installing Docker..."
    add_key "https://download.docker.com/linux/ubuntu/gpg" "/usr/share/keyrings/docker-archive-keyring.gpg" || { log "Failed to add Docker key. Exiting."; exit 1; }
    add_repository "/etc/apt/sources.list.d/docker.list" "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" || { log "Failed to add Docker repository. Exiting."; exit 1; }
    sudo apt update && sudo apt install docker-ce docker-ce-cli docker-compose containerd.io -y || { log "Failed to install Docker. Exiting."; exit 1; }
    # Add user to docker group
    sudo groupadd -f docker || { log "Failed to create docker group. Exiting."; exit 1; }
    sudo usermod -aG docker,adm,dialout "$USER" || { log "Failed to add user to groups. Exiting."; exit 1; }
    log "Docker installed."
}

# Function to set up Python
setup_python() {
    log "Setting up Python..."
    sudo python3 -m pip install -U pip setuptools wheel --break-system-packages || { log "Failed to update pip, setuptools, and wheel. Exiting."; exit 1; }
    log "Python setup completed."
}

# Function to install Node.js
install_nodejs() {
    log "Installing Node.js..."
    add_key "https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key" "/etc/apt/keyrings/nodesource.gpg" || { log "Failed to add Node.js key. Exiting."; exit 1; }
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list || { log "Failed to add Node.js repository. Exiting."; exit 1; }
    sudo apt update && sudo apt install -y nodejs || { log "Failed to install Node.js. Exiting."; exit 1; }
    log "Node.js installed."
}


# Function to install Go
install_go() {
    log "Installing Go..."
    sudo add-apt-repository ppa:longsleep/golang-backports -y
    sudo apt update && sudo apt install -y golang-go || { log "Failed to install Go. Exiting."; exit 1; }
    log "Go installed."
}

# Function to install .NET Core
install_dotnet() {
    log "Installing .NET Core..."
    wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
    sudo dpkg -i packages-microsoft-prod.deb
    sudo rm packages-microsoft-prod.deb
    sudo apt-get update
    sudo apt-get install -y dotnet-sdk-6.0 || { log "Failed to install .NET Core. Exiting."; exit 1; }
    log ".NET Core installed."
}

# Function to install Yarn
install_yarn() {
    log "Installing Yarn..."
    # Add Yarn GPG key
    add_key "https://dl.yarnpkg.com/debian/pubkey.gpg" "/usr/share/keyrings/yarn-keyring.gpg" || { log "Failed to add Yarn GPG key. Exiting."; exit 1; }
    # Add Yarn repository
    add_repository "/etc/apt/sources.list.d/yarn.list" "deb [signed-by=/usr/share/keyrings/yarn-keyring.gpg] https://dl.yarnpkg.com/debian/ stable main" || { log "Failed to add Yarn repository. Exiting."; exit 1; }
    # Update package lists and install Yarn
    sudo apt update && sudo apt install yarn -y || { log "Failed to install Yarn. Exiting."; exit 1; }
    log "Yarn installed."
}


# Function to install Rust
install_rust() {
    log "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y || { log "Failed to install Rust. Exiting."; exit 1; }
    log "Rust installed."
}

# Main script execution
log "Starting installation script..."

# Install common packages
install_common_packages

# Detect hardware and install appropriate packages
detect_hardware

# Update package lists
update_packages

# Install Regolith Desktop and additional packages
install_regolith
install_regolith_look

# Install Flatpak and Snap
install_flatpak
install_snap

# Install browsers
install_google_chrome
install_firefox
install_brave
install_microsoft_edge

# Install VSCode and extensions
install_vscode

# Install development & compiling tools
install_dev_compiling

# Setup Python
setup_python

# Install Node.js
NODE_MAJOR=20  # Set Node.js version
install_nodejs

# Install Go
install_go

# Install .NET Core
install_dotnet

# Install Yarn
install_yarn

# Install Rust
install_rust

log "Installation completed successfully."
