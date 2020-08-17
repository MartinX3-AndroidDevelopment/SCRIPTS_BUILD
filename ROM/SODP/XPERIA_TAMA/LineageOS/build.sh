#!/usr/bin/env bash
#
# Copyright (c) 2020 Martin Dünkelmann
# All rights reserved.
#

function set_variables() {
    echo "####SET VARIABLES START####"
    build_cache=/run/media/martin/extLinux/developer/android/cache/lineageOS/10 #CustomROM out dir
    build_out=/run/media/martin/extLinux/developer/android/out/lineageOS/10
    current_dir=$(pwd)
    customROM_dir=/home/developer/android/rom/lineageOS/10
    echo "####SET VARIABLES END####"
}

function add_custom_hacks() {
    echo "####CUSTOMROM HACKS ADDING START####"
    echo "####CUSTOMROM HACKS ADDING END####"
}

function build_lineageOS() {
    echo "####SONY AOSP BUILD START####"
    echo "####$1 Sim START####"
    functions_build_customROM_helper ${customROM_dir} lineage_$1-userdebug

    cd ${customROM_dir}

    mka bacon # mka "Builds using SCHED_BATCH on all processors." and bacon creates a flashable zip

    mv ${build_cache}/target/product/$1/lineage-*.zip ${build_out}/ # Only the correct file gets found with "lineage-*.zip"
    echo "####$1 Sim END####"
    echo "####SONY AOSP BUILD END####"
}

# exit script immediately if a command fails or a variable is unset
set -e

echo "IS THIS SHELL IN THE REPOSITORY? Or did you modify the current_dir variable?"
read -n1 -r -p "Press space to continue..."

source ../../../../TOOLS/functions.sh

functions_init

set_variables

functions_create_folders ${build_cache}
functions_create_folders ${build_out}

functions_test_repo_up_to_date

functions_update_customROM ${customROM_dir}

add_custom_hacks

build_lineageOS akari # XZ2_SS
build_lineageOS apollo # XZ2C_SS
build_lineageOS akatsuki # XZ3_SS

echo "Output ${build_out}"
read -n1 -r -p "Press space to continue..."
echo "Upload to androidfilehost.com !"
read -n1 -r -p "Press space to continue..."
echo "Upload to dhacke strato server !"
read -n1 -r -p "Press space to continue..."

set +e

exit 0
