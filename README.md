# pacnewhelper
Set of bash scripts for updating Arch Linux configuration changes after system update.

Those scripts use kdiff3 as three way merge tool to incorporate .pacnew files into existing configuration files.
You can collect all files that needs merge on target machine, merge changed on workstation and update files on target machine.

This way there is no need to install kdiff3 with all dependencies on servers running Arch Linux.

# Features:
 
 - uses kdiff3 as three way merge tool
 - supports extracting base configuration files from packages installed with pacman and AUR helpers.
 - allows to merge .pacnew files with existing configuration on diffrent machine - you do not need to install kdiff3 and all dependencies on servers.

# Preparation
Scripts works for AUR packages if they are stored in common folder. You need to set PKGDEST in /etc/makepkg.conf for this to work on each machine.

1. On each machine reconfigure makepkg to create packages in one common directory:

         mkdir /var/cache/makepkg
         chown u=rwx,g=rwx,o=rwxt /var/cache/makepkg            

1. Configure makepkg to create packages in directory above. Add to /etc/makepkg.conf

         PKGDEST=/var/cache/makepkg 


1. Move all package files to newly created directory

         # assumes that current user is the only package maker for packages installed from AUR
         find ~/.cache/yay -name "*.pkg.*" -exec mv {} /var/cache/makepkg/ \;

1. Copy collect.sh and update.sh to root@target or just git clone panewhelper as root on target machine.

You can use ansible makepkg.playbook to do steps (1) and (2) automatically.

# How to use

1. After pacman -Syu and/or yay -Syu **DO NOT** delete cached packages.
1. On target machine, run collect.sh <makepkg_cache_dir>:

        ./collect.sh /var/cache/makepkg

1. Copy pacnewhelper_in to workstation:

        scp -r pacnewhelper_in user@workstation:
    
    pacnewhelper_in should be copied to the same directory where merge.sh script resides.

1. On workstation, run merge.sh. This will run kdiff3 for all configuration files 
   and place results in ./out dirctory
   
1. Copy ./out directory to root@target
1. Run update.sh to update configuration files.
1. Restart and check all services where confiugration was updated.
1. (Optionally) use clear_cache.sh to remove all old packages from cache directories. This script will 
   leave the last version needed for extracting files needed by merget.sh at next update.

Scripts can be also used on the same machine - without copying between server and workstation.

# TODO:

 - clean_cache.sh: do not leave last version of package if it is not installed in the system.