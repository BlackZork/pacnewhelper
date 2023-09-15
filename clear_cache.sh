#!/bin/bash
# This script removes all package files
# from pacman and yay cache directories 
# leaving the youngest one needed for collect.sh
# 
#set -x

PACMAN_CACHE=/var/cache/pacman/pkg
YAY_CACHE=$1

WORKING_DIR=$(pwd)

function clear_cache_dir {
    declare -A packages=()
    echo "Creating package list in $1"
    pattern="$1/*.pkg.*"
    for filepath in ${pattern}; do
        if [ "${filepath}" == "${pattern}" ]; then
            # no files found
            continue;
        fi;
        filename=$(basename {$filepath})
        # get package name witohut version and add it to array
        package_name=$(echo ${filename} | sed -n 's/^\(.*\)-.*-[0-9]\+-\(x86_64\|any\)\.pkg\..*$/\1/p')
        if [ ! -z ${package_name} ]; then
            packages[${package_name}]=1
        else
            echo "WARNING: failed to parse package name ${package_name}, ignoring"
        fi
    done;

    # got package list to remove, find old files and remove them all
    echo "Removing old files for ${#packages[@]} package(s) from $1"
    for pkg in "${!packages[@]}"; do
        pkgpattern="$1/${pkg}*"
        # do not touch other files that do not 
        # follow package naming pattern
        pkgfiles=$(ls -t ${pkgpattern} |grep -E '^.*-.*-[0-9]+-(x86_64|any)\.pkg\..*$')
        remove=0
        for pkgpath in ${pkgfiles}; do
            if [ ${remove} -eq 1 ]; then
                echo "rm -f ${pkgpath}"
                rm -f ${pkgpath}
                if [ $? -ne 0 ]; then
                    exit 1;
                fi                    
            fi
            remove=1
        done;
    done
}


clear_cache_dir ${PACMAN_CACHE}
if [ ! -z  $1 ]; then
    echo "Cleaning makepkg cache dir $1"
    clear_cache_dir $1
fi