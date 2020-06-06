#!/usr/bin/env bash
#
# Copyright (c) 2019-2020 Martin Dünkelmann
# All rights reserved.
#

function set_variables() {
    echo "####SET VARIABLES START####"
    android_stuff_folder=/media/martin/extLinux/developer/android # A shiny variable name, isn't it?
    build_cache_customROM=${android_stuff_folder}/cache/twrp_omni_minimal/9 #CustomROM out dir
    build_out=${android_stuff_folder}/out/twrp/sodp/10
    current_dir=$(pwd)
    customROM_dir=/home/developer/android/rom/platform_manifest_twrp_omni_android_9.0
    PLATFORM_SECURITY_PATCH_OVERRIDE=2020-05-05 # OmniROM 9.0 doesn't get new security patch level.
    echo "####SET VARIABLES END####"
}

function add_custom_hacks() {
    echo "####CUSTOMROM HACKS ADDING START####"
    echo "####CUSTOMROM HACKS ADDING END####"
}

function build_omniROM_twrp() {
    echo "####OmniROM TWRP BUILD START####"
    echo "####$1 START####"
    functions_twrp_build_customROM_helper ${customROM_dir} $1 ${PLATFORM_SECURITY_PATCH_OVERRIDE}

    # Copy the template files into the output folder to get bundled
    yes | cp -rf ${current_dir}/../template/*.* ${build_out}/$1/
    yes | cp -rf ${build_cache_customROM}/target/product/$1/boot.img ${build_out}/$1/twrp-$1.img
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

functions_create_folders ${build_cache_customROM}
functions_create_folders ${build_out}
functions_create_folders ${build_out}/akari
functions_create_folders ${build_out}/apollo
functions_create_folders ${build_out}/akatsuki

functions_test_repo_up_to_date

functions_twrp_clean_builds ${build_out}/akari
functions_twrp_clean_builds ${build_out}/apollo
functions_twrp_clean_builds ${build_out}/akatsuki

functions_update_customROM ${customROM_dir}

add_custom_hacks

build_omniROM_twrp akari # xz2
build_omniROM_twrp apollo # xz2c
build_omniROM_twrp akatsuki # xz3

functions_twrp_compress_builds ${build_out}/akari twrp_sodp_akari
functions_twrp_compress_builds ${build_out}/apollo twrp_sodp_apollo
functions_twrp_compress_builds ${build_out}/akatsuki twrp_sodp_akatsuki

functions_twrp_clean_builds ${build_out}/akari
functions_twrp_clean_builds ${build_out}/apollo
functions_twrp_clean_builds ${build_out}/akatsuki

echo "Output ${build_out}"
read -n1 -r -p "Press space to continue..."
echo "Upload to androidfilehost.com !"
read -n1 -r -p "Press space to continue..."
echo "Upload to dhacke strato server !"
read -n1 -r -p "Press space to continue..."

set +eu

exit 0
