#!/bin/bash
#set -x

PACMAN_CACHE=/var/cache/pacman/pkg
YAY_CACHE=$1

DEST_DIR=./pacnewhelper_in

if [ -z ${YAY_CACHE} ]; then
    echo "Warning: yay cache not set, cannot find base config files for aur pacakges"
fi

WORKING_DIR=$(pwd)

if [ -d ${DEST_DIR} ]; then
    echo "Target directory ${DEST_DIR} exists"
    #exit 1;
fi

mkdir -p ${DEST_DIR}

PACNEW_FILES=$(find / -path ${WORKING_DIR} -prune -o -regextype posix-extended -regex "/(sys|srv|proc)" -prune -o ! -readable -prune -o -type f -name '*.pacnew' -print)
for fname in ${PACNEW_FILES};
do
    #echo "Processing $fname"
    # create target directory
    fdir=$(dirname ${fname})
    dest_config_dir=${DEST_DIR}${fdir}
    mkdir -p ${dest_config_dir}

    # cut .pacnew extension
    current_fname=$(echo "$fname" | sed -e 's/\.[^.]*$//') 

    # copy files
    cp ${fname} ${dest_config_dir}
    cp ${current_fname} ${dest_config_dir}

    # get name of package that owns config file
    package_desc=$(pacman -Qo ${current_fname})

    if [ -z "${package_desc}" ]; then
        echo "Cannot find package that owns ${current_fname}"
        exit 2;
    fi

    package=$(echo ${package_desc} | sed -n "s/^.* is owned by \(\S*\).*$/\1/p")

    if [ -z "${package}" ]; then
        echo "Failed to extract package name from string '${package_desc}'"
        exit 3;
    fi

    # check if package is native or from aur
    pacman -Qn | grep -qE "^${package} .*" > /dev/null
    if [ $? -eq 0 ]; then
        prev_package_arch_pattern=${PACMAN_CACHE}/${package}*
    else 
        prev_package_arch_pattern=${YAY_CACHE}/${package}/*pkg*
    fi;

    # previous installed package will be in second line
    prev_package_file=$(ls -t ${prev_package_arch_pattern} | sed -n 2p)
    if [ -z ${prev_package_file} ]; then
        echo "Cannot find previous version of package ${package}"
        exit 4;
    fi

    # extract base config file into dest dir
    old_file=${current_fname:1}
    tar -tf ${prev_package_file} ${old_file} > /dev/null 2>&1;
    if [ "$?" == "0" ]; then
        tar -xvOf ${prev_package_file} ${old_file} > ${DEST_DIR}/${old_file}.org
    else
        echo "${old_file} is auto-generated at install"
    fi
done;
