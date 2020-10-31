#!/bin/bash
#set -x

IN_DIR=./pacnewhelper_in
OUT_DIR=./out

function merge3_tool {
    kdiff3 ${1} ${2} ${3} -o ${4}
}

function merge2_tool {
    kdiff3 ${1} ${2} -o ${3}
}


if [ ! -d ${OUT_DIR} ]; then
    mkdir ${OUT_DIR}
fi

PACNEW_FILES=$(find ${IN_DIR} -type f -name '*.pacnew' -print)
for fname in ${PACNEW_FILES};
do
    # create paths to all files
    fcurrent=$(echo "$fname" | sed -e 's/\.[^.]*$//')
    forg=${fcurrent}.org
    fout_file=$(echo ${fcurrent} | cut -d'/' -f3-)

    fout_path=${OUT_DIR}/${fout_file}

    # create out dir if not exists
    fout_dir=$(dirname ${fout_path})
    mkdir -p ${fout_dir}

    if [ -f  ${forg} ]; then
        merge3_tool ${forg} ${fcurrent} ${fname} ${fout_path}
    else
        merge2_tool ${fcurrent} ${fname} ${fout_path}
    fi
done;
