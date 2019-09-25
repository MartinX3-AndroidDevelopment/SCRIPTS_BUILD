#!/usr/bin/env bash
#
# Copyright (c) 2019 Martin Dünkelmann
# All rights reserved.
#

function set_variables() {
    echo "####SET VARIABLES START####"
    build_cache=/media/martin/extLinux/developer/android/cache/sonyAOSP/9 #CustomROM out dir
    build_out=/media/martin/extLinux/developer/android/out/sonyAOSP/9
    current_dir=$(pwd)
    customROM_dir=/home/developer/android/rom/sonyAOSP/9
    echo "####SET VARIABLES END####"
}

function add_custom_hacks() {
    echo "####CUSTOMROM HACKS ADDING START####"
    cd ${customROM_dir}

    # TODO: Workaround for the camera focus issue until it gets fixed in the camera driver
    cd ${customROM_dir}/kernel/sony/msm-4.9
    git fetch https://github.com/kholk/kernel 232r14-headless-sde && git cherry-pick d5c2a4926c7ba56a983588c2f354620d4f8dcdd8
    echo "####CUSTOMROM HACKS ADDING END####"
}

function build_sonyAOSP() {
    echo "####SONY AOSP BUILD START####"
    cd ${customROM_dir}
    source ${customROM_dir}/build/envsetup.sh

    echo "####$1 Sim START####"
    case "$1" in
        "xz2_SS")
            product_name=akari
            lunch aosp_h8216-userdebug
        ;;
        "xz2c_SS")
            product_name=apollo
            lunch aosp_h8314-userdebug
        ;;
        "xz3_SS")
            product_name=akatsuki
            lunch aosp_h8416-userdebug
        ;;
        *)
            echo "Unknown Option $1 in build_sonyAOSP()"
            exit 1 # die with error code 9999
    esac

    make installclean # Clean build while saving the buildcache.

    make -j8 Chromium # Needs to get executed seperately, because it doesn't gets automatically build
    make -j$((`nproc`-1))

    cp ${build_cache}/target/product/${product_name}/*.img ${build_out}/$1/

    rm ${build_out}/$1/ramdisk*
    rm ${build_out}/$1/dtbo-arm64.img
    echo "####$1 Sim END####"
    echo "####SONY AOSP BUILD END####"
}

echo "IS THIS SHELL IN THE REPOSITORY? Or did you modify the current_dir variable?"
read -n1 -r -p "Press space to continue..."

source ../../../../TOOLS/functions.sh

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

build_sonyAOSP xz2_SS
build_sonyAOSP xz2c_SS
build_sonyAOSP xz3_SS

functions_compress_builds ${build_out}/xz2_SS sonyaosp_xz2_ss
functions_compress_builds ${build_out}/xz2c_SS sonyaosp_xz2c_ss
functions_compress_builds ${build_out}/xz3_SS sonyaosp_xz3_ss

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
