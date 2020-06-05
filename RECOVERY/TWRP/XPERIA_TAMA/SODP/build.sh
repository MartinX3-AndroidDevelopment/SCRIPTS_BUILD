#!/usr/bin/env bash
#
# Copyright (c) 2019-2020 Martin Dünkelmann
# All rights reserved.
#

function set_variables() {
    echo "####SET VARIABLES START####"
    functions_set_variables
    build_out=/media/martin/extLinux/developer/android/out/twrp/sodp/10
    PLATFORM_SECURITY_PATCH_OVERRIDE=2020-05-05
    echo "####SET VARIABLES END####"
}

function add_custom_hacks() {
    echo "####CUSTOMROM HACKS ADDING START####"
    cd ${customROM_dir}
    echo "####CUSTOMROM HACKS ADDING END####"
}

function build_omniROM_twrp() {
    echo "####OmniROM TWRP BUILD START####"
    echo "####$1 START####"
    functions_build_omniROM_twrp $1 ${PLATFORM_SECURITY_PATCH_OVERRIDE} # OmniROM 9.0 doesn't get new security patch level.

    yes | cp -rf ${build_cache}/target/product/${model_name}/boot.img ${build_out}/$1/twrp-$1.img

    yes | cp -rf ${current_dir}/../template/*.* ${build_out}/$1/ # Copy the template files into the outputfolder to get bundled
    echo "####$1 END####"
    echo "####OmniROM TWRP BUILD END####"
}

# exit script immediately if a command fails or a variable is unset
set -eu

echo "Are the template files up-to-date?"
echo "IS THIS SHELL IN THE REPOSITORY? Or did you modify the current_dir variable?"
read -n1 -r -p "Press space to continue..."

source ../../../../TOOLS/functions.sh # Functions for every script
source ../../functions.sh # Functions for every TWRP script

functions_init

set_variables

functions_create_folders ${build_cache}
functions_create_folders ${build_out}
functions_create_folders ${build_out}/xz2
functions_create_folders ${build_out}/xz2c
functions_create_folders ${build_out}/xz3

functions_test_repo_up_to_date

functions_clean_builds ${build_out}/xz2
functions_clean_builds ${build_out}/xz2c
functions_clean_builds ${build_out}/xz3

functions_update_customROM ${customROM_dir}

add_custom_hacks

build_omniROM_twrp xz2
build_omniROM_twrp xz2c
build_omniROM_twrp xz3

functions_compress_builds ${build_out}/xz2 twrp_sodp_xz2
functions_compress_builds ${build_out}/xz2c twrp_sodp_xz2c
functions_compress_builds ${build_out}/xz3 twrp_sodp_xz3

functions_clean_builds ${build_out}/xz2
functions_clean_builds ${build_out}/xz2c
functions_clean_builds ${build_out}/xz3

echo "Output ${build_out}"
read -n1 -r -p "Press space to continue..."
echo "Upload to androidfilehost.com !"
read -n1 -r -p "Press space to continue..."
echo "Upload to dhacke strato server !"
read -n1 -r -p "Press space to continue..."

set +eu

exit 0
