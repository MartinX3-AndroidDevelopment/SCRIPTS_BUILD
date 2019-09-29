#!/usr/bin/env bash
#
# Copyright (c) 2019 Martin Dünkelmann
# All rights reserved.
#

function set_variables() {
    echo "####SET VARIABLES START####"
    build_cache=/media/martin/extLinux/developer/android/cache/omniROM/9 #CustomROM out dir
    build_out=/media/martin/extLinux/developer/android/out/omniROM/9
    current_dir=$(pwd)
    customROM_dir=/home/developer/android/rom/omniROM/9
    echo "####SET VARIABLES END####"
}

function add_custom_hacks() {
    echo "####CUSTOMROM HACKS ADDING START####"
    cd ${customROM_dir}

    #Revert 'fastboot boot twrp.img' support to make OmniROM bootable
    cd ${customROM_dir}/kernel/sony/msm
    git revert --no-edit 8319c00bb88bae449480ccc7139de87e37831f71
    echo "####CUSTOMROM HACKS ADDING END####"
}

function build_omniROM() {
    echo "####OMNI ROM BUILD START####"
    cd ${customROM_dir}
    source ${customROM_dir}/build/envsetup.sh

    echo "####$1 Single Sim START####"
    case "$1" in
        "xz2_SS")
            product_name=akari
        ;;
        "xz2c_SS")
            product_name=apollo
        ;;
        "xz3_SS")
            product_name=akatsuki
        ;;
        *)
            echo "Unknown Option $1 in build_omniROM()"
            exit 1 # die with error code 9999
    esac

    lunch omni_${product_name}-userdebug

    make -j$((`nproc`+1)) installclean # Clean build while saving the buildcache.

    make -j$((`nproc`+1)) update-api

    make -j$((`nproc`+1))

    cp ${build_cache}/target/product/${product_name}/*.img ${build_out}/$1/

    rm ${build_out}/$1/ramdisk*
    rm ${build_out}/$1/dtbo-arm64.img
    echo "####$1 Single Sim END####"
    echo "####OMNI ROM BUILD END####"
}

echo "IS THIS SHELL IN THE REPOSITORY? Or did you modify the current_dir variable?"
echo "Don't forget to upgrade the TWRP minimal sources!"
read -n1 -r -p "Press space to continue..."

source ../../../../../TOOLS/functions.sh

functions_init

set_variables

functions_create_folders ${build_cache}
functions_create_folders ${build_out}
functions_create_folders ${build_out}/xz2_SS
functions_create_folders ${build_out}/xz2c_SS
functions_create_folders ${build_out}/xz3_SS

functions_test_repo_up_to_date

functions_clean_builds ${build_out}/xz2_SS
functions_clean_builds ${build_out}/xz2c_SS
functions_clean_builds ${build_out}/xz3_SS

functions_update_customROM ${customROM_dir}

add_custom_hacks

build_omniROM xz2_SS
build_omniROM xz2c_SS
build_omniROM xz3_SS

functions_compress_builds ${build_out}/xz2_SS omnirom_xz2_ss
functions_compress_builds ${build_out}/xz2c_SS omnirom_xz2c_ss
functions_compress_builds ${build_out}/xz3_SS omnirom_xz3_ss

functions_clean_builds ${build_out}/xz2_SS
functions_clean_builds ${build_out}/xz2c_SS
functions_clean_builds ${build_out}/xz3_SS

echo "Output ${build_out}"
read -n1 -r -p "Press space to continue..."
echo "Upload to androidfilehost.com !"
read -n1 -r -p "Press space to continue..."
echo "Upload to dhacke strato server !"
read -n1 -r -p "Press space to continue..."

exit 0

