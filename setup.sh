#!/bin/bash

# Import external functions
source resources/devices
source resources/regolith-i3
source resources/gnome-ext
source resources/vscode
source resources/browsers
source resources/developer

# Logging function
log() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1"
}

# Function to prompt user for Yes/No input
confirm() {
    while true; do
        read -rp "$1 [y/n]: " yn
        case $yn in
            [Yy]*) return 0;;  # Yes, continue
            [Nn]*) return 1;;  # No, skip
            *) echo "Please answer yes or no.";;
        esac
    done
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

# Main script execution
log "Starting installation script..."

# Install common packages
install_common_packages

# Detect hardware and install appropriate packages
detect_hardware

# Update package lists
update_packages

# Install regolith-i3
if confirm "Install Regolith i3?"; then
    install_regolith
    install_regolith_look
fi

# Install gnome-ext
if confirm "Install GNOME extensions?"; then
    install_flatpak
    install_snap
fi

# Install browsers
if confirm "Install browsers?"; then
    install_google_chrome
    install_firefox
    install_brave
    install_microsoft_edge
fi

# Install vscode
if confirm "Install Visual Studio Code?"; then
    install_vscode
fi

# Install developer tools
if confirm "Install developer tools?"; then
    install_dev_compiling
    setup_python
    NODE_MAJOR=20  # Set Node.js version
    install_nodejs
    install_go
    install_dotnet
    install_yarn
    install_rust
fi

log "Installation completed successfully."
