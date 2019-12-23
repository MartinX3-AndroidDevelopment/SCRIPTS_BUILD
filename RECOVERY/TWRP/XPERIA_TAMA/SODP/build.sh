#!/usr/bin/env bash
#
# Copyright (c) 2019 Martin Dünkelmann
# All rights reserved.
#

function set_variables() {
    echo "####SET VARIABLES START####"
    build_cache=/media/martin/extLinux/developer/android/cache/omniROM/9 #CustomROM out dir
    build_out=/media/martin/extLinux/developer/android/out/twrp/sodp/9
    current_dir=$(pwd)
    customROM_dir=/home/developer/android/rom/omniROM/9
    echo "####SET VARIABLES END####"
}

function add_custom_hacks() {
    echo "####CUSTOMROM HACKS ADDING START####"
    cd ${customROM_dir}
    # Execute the SODP cherry-pick script
    bash repo_update.sh
    echo "####CUSTOMROM HACKS ADDING END####"
}

function build_omniROM_twrp() {
    echo "####OmniROM TWRP BUILD START####"
    cd ${customROM_dir}
    source ${customROM_dir}/build/envsetup.sh

    echo "####$1 START####"
    case "$1" in
        "xz2")
            model_name=akari
            lunch omni_akari-eng
        ;;
        "xz2c")
            model_name=apollo
            lunch omni_apollo-eng
        ;;
        "xz3")
            model_name=akatsuki
            lunch omni_akatsuki-eng
        ;;
        *)
            echo "Unknown Option $1 in build_omniROM_twrp()"
            exit 1 # die with error code 9999
    esac

    make installclean # Clean build while saving the buildcache.

    make -j$((`nproc` - 1)) bootimage

    yes | cp -rf ${build_cache}/target/product/${model_name}/boot.img ${build_out}/$1/twrp-$1.img

    yes | cp -rf ${current_dir}/../template/*.* ${build_out}/$1/ # Copy the template files into the outputfolder to get bundled
    echo "####$1 END####"
    echo "####OmniROM TWRP BUILD END####"
}

echo "Are the template files up-to-date?"
echo "IS THIS SHELL IN THE REPOSITORY? Or did you modify the current_dir variable?"
read -n1 -r -p "Press space to continue..."

source ../../../../TOOLS/functions.sh

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

exit 0
