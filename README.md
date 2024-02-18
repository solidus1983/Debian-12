# Solidus1983 Debain 12 Scripts

## Device Support

 - Lenovo Thinkpad T440p (T440P)
 - Dell XPS 13 (XPS13)
 - Dell Precision 5760 (P5760)

 ## Files Legend

 - [prep-btrfs.sh] Used during an Expert Install of Debian 12 just after Partitioning via the **CONSOLE (SHIFT+F2)**
 - [setup.sh] Used after install and on firstboot to the OS which will detect the hardware and install the relevant drivers and software I normally use personally.
 - [install-snapshots.sh] Sets the system to create snapshots and enable snapshot boot support.
 - [resources/] functions that have been split from ./setup.sh to make it more easier to use a module based system.

      - [devices] script function to install packages from resulting hardware detection
      - [browsers] script function to install all common web-browsers
      - [developer] script function to install all software for development i use
      - [gnome-ext] script function to install flatpak and snap
      - [regolith-i3] script function to install regolith 3.0 desktop ui and themes
      - [vscode] script function to install microsofts vscode
      - [extensions] extensions file for the vscode function to install all used extensions
         - Example :
                     "ms-vscode.live-server"
                     "ms-azuretools.vscode-docker"
                     "Catppuccin.catppuccin-vsc"
                     "Catppuccin.catppuccin-vsc-icons"
         
         - Update List: issue the command `code --list-extensions > resources/extensions` ** code can also be vscode or code-server **
         
