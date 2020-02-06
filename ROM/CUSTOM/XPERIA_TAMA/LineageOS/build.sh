#!/usr/bin/env bash
#
# Copyright (c) 2019 Martin Dünkelmann
# All rights reserved.
#

function set_variables() {
    echo "####SET VARIABLES START####"
    build_cache=/media/martin/extLinux/developer/android/cache/lineageOS/10 #CustomROM out dir
    build_out=/media/martin/extLinux/developer/android/out/lineageOS/10
    current_dir=$(pwd)
    customROM_dir=/home/developer/android/rom/lineageOS/10
    echo "####SET VARIABLES END####"
}

function add_custom_hacks() {
    echo "####CUSTOMROM HACKS ADDING START####"
    echo "####Executing LineageOS repo_update.sh START####"
    # Executing the LineageOS patches
    cd ${customROM_dir}
    bash ${customROM_dir}/repo_update.sh
    echo "####Executing LineageOS repo_update.sh END####"
    echo "####CUSTOMROM HACKS ADDING END####"
}

function build_lineageOS() {
    echo "####SONY AOSP BUILD START####"
    cd ${customROM_dir}
    source ${customROM_dir}/build/envsetup.sh

    echo "####$1 Sim START####"
    case "$1" in
        "XZ2_SS")
            product_name=akari
            dualsim=false
            lunch lineage_akari_RoW-userdebug
        ;;
        "XZ2C_SS")
            product_name=apollo
            dualsim=false
            lunch lineage_apollo_RoW-userdebug
        ;;
        "XZ3_SS")
            product_name=akatsuki
            dualsim=false
            lunch lineage_akatsuki_RoW-userdebug
        ;;
        "XZ2_DS")
            product_name=akari
            dualsim=true
            lunch lineage_akari_DSDS-userdebug
        ;;
        "XZ2C_DS")
            product_name=apollo
            dualsim=true
            lunch lineage_apollo_DSDS-userdebug
        ;;
        "XZ3_DS")
            product_name=akatsuki
            dualsim=true
            lunch lineage_akatsuki_DSDS-userdebug
        ;;
        *)
            echo "Unknown Option $1 in build_lineageOS()"
            exit 1 # die with error code 9999
    esac

    make installclean # Clean build while saving the buildcache.

    if ${dualsim}; then
        partitions="boot vendor"
        make -j$((`nproc`+1)) bootimage vendorimage
    else
        partitions="boot dtbo system userdata vbmeta vendor"
        make -j$((`nproc`+1))
    fi

    for partition in ${partitions}; do
        cp ${build_cache}/target/product/${product_name}/${partition}.img ${build_out}/$1/
    done
    echo "####$1 Sim END####"
    echo "####SONY AOSP BUILD END####"
}

# exit script immediately if a command fails
set -e

echo "IS THIS SHELL IN THE REPOSITORY? Or did you modify the current_dir variable?"
read -n1 -r -p "Press space to continue..."

source ../../../../TOOLS/functions.sh

functions_init

set_variables

functions_create_folders ${build_cache}
functions_create_folders ${build_out}
functions_create_folders ${build_out}/XZ2_SS
functions_create_folders ${build_out}/XZ2C_SS
functions_create_folders ${build_out}/XZ3_SS
functions_create_folders ${build_out}/XZ2_DS
functions_create_folders ${build_out}/XZ2C_DS
functions_create_folders ${build_out}/XZ3_DS

functions_test_repo_up_to_date

functions_clean_builds ${build_out}/XZ2_SS
functions_clean_builds ${build_out}/XZ2C_SS
functions_clean_builds ${build_out}/XZ3_SS
functions_clean_builds ${build_out}/XZ2_DS
functions_clean_builds ${build_out}/XZ2C_DS
functions_clean_builds ${build_out}/XZ3_DS

functions_update_customROM ${customROM_dir}

add_custom_hacks

build_lineageOS XZ2_SS
build_lineageOS XZ2_DS
build_lineageOS XZ2C_SS
build_lineageOS XZ2C_DS
build_lineageOS XZ3_SS
build_lineageOS XZ3_DS

functions_compress_builds ${build_out}/XZ2_SS lineageOS_XZ2_SS
functions_compress_builds ${build_out}/XZ2C_SS lineageOS_XZ2C_SS
functions_compress_builds ${build_out}/XZ3_SS lineageOS_XZ3_SS
functions_compress_builds ${build_out}/XZ2_DS lineageOS_XZ2_DS
functions_compress_builds ${build_out}/XZ2C_DS lineageOS_XZ2C_DS
functions_compress_builds ${build_out}/XZ3_DS lineageOS_XZ3_DS

functions_clean_builds ${build_out}/XZ2_SS
functions_clean_builds ${build_out}/XZ2C_SS
functions_clean_builds ${build_out}/XZ3_SS
functions_clean_builds ${build_out}/XZ2_DS
functions_clean_builds ${build_out}/XZ2C_DS
functions_clean_builds ${build_out}/XZ3_DS

echo "Output ${build_out}"
read -n1 -r -p "Press space to continue..."
echo "Upload to androidfilehost.com !"
read -n1 -r -p "Press space to continue..."
echo "Upload to dhacke strato server !"
read -n1 -r -p "Press space to continue..."

# because "set -e" is used above, when we get to this point, we know
# everything worked fine.
set +e

exit 0
