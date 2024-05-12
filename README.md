# Solidus1983 Debain 12 Scripts

## Device support

 - Lenovo Thinkpad T440p (T440P)
 - Dell XPS 13 (XPS13)
 - Dell Precision 5760 (P5760)

 ## Files and folders legend

 - [prep-btrfs.sh] Used during an Expert Install of Debian 12 just after Partitioning via the **CONSOLE (SHIFT+F2)**
 
 - [setup.sh] Used after install and on firstboot to the OS which will detect the hardware and install the relevant drivers and software I normally use personally.
 
 - [resources/] is a folder where scripts are stored making the whole installer module based and easier to maintain.     
      - [desktop_experience] folder where each desktop experience scripts are stored
      - [drivers] folder where all per device driver install scripts are stored
      - [software] folder of scripts related to installing software
      - [tools] folder of scripts related to installing tools that might be useful

      
 ## How to update vscode Extensions 
 
 Issue the command `code --list-extensions > resources/software/vscode-extensions.list` ** code can also be vscode or code-server **
 This will then be installed when you next run the script on your clean install.
         
         
## BTRFS Snapshot Support

Right now i am unable to get this working reliably enough so for now its disabled till i can fix the issue.
