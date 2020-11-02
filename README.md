# pacnewhelper
Set of bash scripts for updating Arch Linux configuration changes after system update.

Those scripts use kdiff3 as three way merge tool to incorporate .pacnew files into existing configuration files.
You can collect all files that needs merge on target machine, merge changed on workstation and update files on target machine.

This way there is no need to install kdiff3 with all dependencies on servers running Arch Linux.

Features:
 
 - uses kdiff3 as three way merget tool
 - supports extracting base configuration files from pacman and yay cache.
 - allows to run merge tool on different machine.

How to use:

1. After pacman -Syu and/or yay -Syu **DO NOT** delete cached packages.
1. Copy collect.sh and update.sh to root@server
1. On server, run collect.sh <yay_cache_dir>:

        ./collect.sh /home/admin_user/.cache/yay

1. Copy pacnewhelper_in to workstation:

        scp -r pacnewhelper_in user@workstation:
    
    pacnewhelper_in should be copied to the same directory where merge.sh script resides.

1. On workstation, run merge.sh. This will run kdiff3 for all configuration files 
   and place results in ./out dirctory
   
1. Copy ./out directory to root@server
1. Run update.sh to update configuration files.
1. Restart and check all services where confiugration was updated.

TODO:

clean_cache.sh - script that will remove all cached packages 
excluding ones needed for merge.sh (last two)