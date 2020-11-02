#!/bin/bash

CONF_DIR=./out

backup=0
delete_pacnew=1

usage="Usage: $(basename "$0") [-p|--preserve] [-d|--delete]
where:
    -b|--backup     copy original configuration file to <name>.prev
    -p|--preserve   do not remove .pacnew file after merging
    -h|--help       show this help and exit
"

#set -x
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -b|--backup) backup=1; ;;
        -p|--preserve-pacnew) delete_pacnew=0 ;;
        -h|--help) echo "${usage}"; exit 0 ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

CONF_FILES=$(find ${CONF_DIR} -type f -print)
for fname in ${CONF_FILES};
do
    # remove ./${CONF_DIR} from path
    fdest="/"$(echo ${fname} | cut -d'/' -f3-)

    # backup original file
    if [ ${backup} == 1 ]; then
        # do not override if backup file exists
        if [ ! -f ${fdest}.prev ]; then
            cp -a ${fdest} ${fdest}.prev
        fi
    fi

    echo "${fname} => ${fdest}"
    # preserve target file permissions
    cat ${fname} > ${fdest}

    if [ ${delete_pacnew} == 1 ]; then
        rm -f ${fdest}.pacnew
    fi
done
