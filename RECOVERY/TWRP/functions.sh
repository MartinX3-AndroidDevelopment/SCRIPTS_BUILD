#!/usr/bin/env bash
#
# Copyright (c) 2020 Martin Dünkelmann
# All rights reserved.
#

function functions_twrp_build_customROM_helper() {
    functions_build_customROM_helper $1 omni_$2-eng

    cd $1
    make -j bootimage TARGET_STOCK=$3 # -j uses all threads for the build process
}

function functions_twrp_compress_builds() {
    echo "####COMPRESSING $2 BUILD START####"
    cd $1/$2
    tar -zcvf $1/$(date +%Y-%m-%d_%H-%M-%S)_twrp_$2.tar.gz *
    echo "####COMPRESSING $2 BUILD END####"
}

function functions_twrp_clean_builds() {
    echo "####CLEANING $1 BUILD START####"
    rm -f $1/*
    echo "####CLEANING $1 BUILD END####"
}
