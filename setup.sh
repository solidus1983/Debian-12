# Define the directories containing the resource files
resource_directories=(
    "drivers"
    "desktop_experience/regolith"
    "software"
    "software/gnome-extensions"
    "software/vscode"
    "software/browsers"
    "software/developer"
    "tools"
)

# Enable extended pattern matching
shopt -s extglob

# Function to load resource files from a directory
load_resource_files() {
    local directory="$1"
    # Check if the directory exists
    if [ -d "resources/$directory" ]; then
        # Load all files in the directory except for those ending with ".list"
        for file in resources/$directory/!(*.list); do
            # Check if the file is readable
            if [ -r "$file" ]; then
                source "$file"
            fi
        done
    fi
}

# Loop through each directory and load its resource files
for directory in "${resource_directories[@]}"; do
    load_resource_files "$directory"
done

# Logging function
log() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1"
}

# Function to prompt user for Yes/No input
confirm() {
    while true; do
        read -rp "$1 [y/n]: " yn
        case $yn in
        [Yy]*) return 0 ;; # Yes, continue
        [Nn]*) return 1 ;; # No, skip
        *) echo "Please answer yes or no." ;;
        esac
    done
}

# Function to install packages
install_packages() {
    log "Installing packages: $@"
    sudo apt install "$@" -y || {
        log "Failed to install packages: $@. Exiting."
        exit 1
    }
    log "Packages installed: $@"
}

# Function to install packages
upgrade_packages() {
    log "Upgrading packages: $@"
    sudo apt upgrade -y || {
        log "Failed to upgrade packages. Exiting."
        exit 1
    }
    log "Packages Upgraded: $@"
}

# Function to add a repository
add_repository() {
    local file_path="$1"
    local repo_content="$2"
    log "Adding repository to $file_path..."
    echo "$repo_content" | sudo tee "$file_path" >>/dev/null || {
        log "Failed to add repository to $file_path. Exiting."
        exit 1
    }
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
    curl -fsSL "$key_url" | sudo gpg --dearmor -o "$key_destination" || {
        log "Failed to add key from $key_url to $key_destination. Exiting."
        exit 1
    }
    log "Key added to $key_destination."
}

# Function to update package lists
update_packages() {
    log "Updating package lists..."
    sudo apt update || {
        log "Failed to update package lists. Exiting."
        exit 1
    }
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

clone_a_repo() {
    local repo_url="$1"
    local target_dir="$2"
    git clone "$repo_url" "$target_dir"
    cd "$target_dir" || return 1 # Exit function if cd fails
    pwd                          # Print the current directory (path of the cloned repository)
}

update_grub() {
    sudo update-grub
}

# Function to enable a systemd service
enable_service() {
    local service_name="$1"
    local start_service="${2:-false}" # Default to false if not provided

    sudo systemctl enable "$service_name"

    if [ "$start_service" = true ]; then
        sudo systemctl start "$service_name"
    fi
}

# Function to disable a systemd service
disable_service() {
    local service_name="$1"
    sudo systemctl disable "$service_name"
}

# Main script execution
log "Starting installation script..."

# Install base packages
install_base_packages

# Detect hardware and install appropriate packages
detect_hardware

# Update package lists
update_packages

# Install regolith-i3
if confirm "Install Regolith i3?"; then
    install_regolith
    install_regolith_look
fi

# Install gnome-extensions
if confirm "Install GNOME extensions?"; then
    install_flatpak
    install_snap
fi

# Install browsers
if confirm "Install Browsers?"; then
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
if confirm "Install Developer tools?"; then
    install_dev_compiling
    setup_python
    NODE_MAJOR=20 # Set Node.js version
    install_nodejs
    install_go
    install_dotnet
    install_yarn
    install_rust
    install_docker
fi

# Install Snapshots BTFS

#if confirm "Enable BTFS Snapshots?"; then
#    install_snapper_repo
#    disable_snapper_timer
#    snapper_setup
#    install_btrfs_grub
#fi

log "Installation completed successfully."
