#!/usr/bin/env bash
#
# Copyright (c) 2020 Martin Dünkelmann
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
            breakfast lineage_akari_RoW-userdebug # using LineageOS specific breakfast instead of lunch
        ;;
        "XZ2C_SS")
            product_name=apollo
            breakfast lineage_apollo_RoW-userdebug # using LineageOS specific breakfast instead of lunch
        ;;
        "XZ3_SS")
            product_name=akatsuki
            breakfast lineage_akatsuki_RoW-userdebug # using LineageOS specific breakfast instead of lunch
        ;;
        *)
            echo "Unknown Option $1 in build_lineageOS()"
            exit 1 # die with error code 9999
    esac

    make installclean # Clean build while saving the buildcache.

    mka -j$((`nproc`+1)) bacon # mka "Builds using SCHED_BATCH on all processors." and bacon creates a flashable zip

    cp ${build_cache}/target/product/${product_name}/lineage-*.zip ${build_out}/ # Only the correct file gets found with "lineage-*.zip"
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

functions_test_repo_up_to_date

functions_update_customROM ${customROM_dir}

add_custom_hacks

build_lineageOS XZ2_SS
build_lineageOS XZ2C_SS
build_lineageOS XZ3_SS

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
