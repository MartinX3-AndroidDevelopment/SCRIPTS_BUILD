#!/usr/bin/env bash
#
# Copyright (c) 2020 Martin Dünkelmann
# All rights reserved.
#

function functions_twrp_build_customROM_helper() {
    functions_build_customROM_helper $1 omni_$2-eng

    cd $1
    make -j$(nproc --all) bootimage TARGET_STOCK=$3
}

function functions_twrp_compress_builds() {
    echo "####COMPRESSING $1 BUILD START####"
    cd $1
    tar -zcvf $1/../$(date +%Y-%m-%d_%H-%M-%S)_$2.tar.gz *
    echo "####COMPRESSING $1 BUILD END####"
}

function functions_twrp_clean_builds() {
    echo "####CLEANING $1 BUILD START####"
    rm -f $1/*
    echo "####CLEANING $1 BUILD END####"
}
