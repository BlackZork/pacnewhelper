#!/bin/bash

CONF_DIR=./out

CONF_FILES=$(find ${CONF_DIR} -type f -print)
for fname in ${CONF_FILES};
do
    fdest="/"$(echo ${fname} | cut -d'/' -f3-)

    echo "${fname} => ${fdest}"

    # preserve target file permissions
    cat ${fname} > ${fdest}
done
