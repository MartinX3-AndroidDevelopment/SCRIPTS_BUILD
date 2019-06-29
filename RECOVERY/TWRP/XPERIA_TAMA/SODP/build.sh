#!/usr/bin/env bash

function set_variables() {
    echo "####SET VARIABLES START####"
    build_cache=/media/martin/extLinux/developer/android/cache/omniROM #CustomROM out dir
    build_out=/media/martin/extLinux/developer/android/out/twrp/sodp
    current_dir=$(pwd)
    customROM_dir=/home/developer/android/omniROM90
    echo "####SET VARIABLES END####"
}

function add_custom_hacks() {
    echo "####CUSTOMROM HACKS ADDING START####"
    cd ${customROM_dir}

    # TWRP needs -eng
    printf "add_lunch_combo omni_akari-eng" >> ${customROM_dir}/device/sony/akari/vendorsetup.sh
    printf "add_lunch_combo omni_apollo-eng" >> ${customROM_dir}/device/sony/apollo/vendorsetup.sh
    printf "add_lunch_combo omni_akatsuki-eng" >> ${customROM_dir}/device/sony/akatsuki/vendorsetup.sh

    # TODO: Needed for 'fastboot boot twrp.img' support
    cd ${customROM_dir}/kernel/sony/msm
    git fetch https://github.com/MartinX3sAndroidDevelopment/KERNEL_SODP.git MartinX3/LE.UM.2.3.2.r1.4 && git cherry-pick 6a101ff64e06069837a6c30db3af1dc95c1fb358

    # TODO: Needed for logcat support, until it got merged into omnirom
    cd ${customROM_dir}/device/sony/tama-common
    git fetch https://gerrit.omnirom.org/android_device_sony_tama-common refs/changes/64/33364/6 && git cherry-pick FETCH_HEAD

    # TODO: Hack until Marijn uploads his gerrit CR's. Or they can't get upstreamed and will be here forever. Needed to fix build.
    cd ${customROM_dir}/bootable/recovery
    git fetch https://github.com/MarijnS95/android_bootable_recovery && git cherry-pick 2f5c920c6d911b5900c0d1566a9f7d682d7fce00
    git fetch https://github.com/MarijnS95/android_bootable_recovery && git cherry-pick 116edf6dd9ffb69602226863ad244dce4f14db90
    git fetch https://github.com/MarijnS95/android_bootable_recovery && git cherry-pick c72a02510da5c24b9693f3a33424d20936db13ad
    git fetch https://github.com/MarijnS95/android_bootable_recovery && git cherry-pick 984f54a211489259895acaacae68778a390b02c2
    git fetch https://github.com/MarijnS95/android_bootable_recovery && git cherry-pick 103f178615d1c6daac3c771c6d64ac46ab8eef5a
    git fetch https://github.com/MarijnS95/android_bootable_recovery && git cherry-pick af2e389f92f43822297bae19022747c8a56c2ac3
    git fetch https://github.com/MarijnS95/android_bootable_recovery && git cherry-pick 948c4f2d5894208afd40829a3429c3101f00c9ab
    git fetch https://github.com/MarijnS95/android_bootable_recovery && git cherry-pick 4bd587db4a881b129d0b36a82187ca8d3390b2b8

    # TODO: Needed for decryption support, until it got merged into omnirom
    cd ${customROM_dir}/system/sepolicy
    git fetch https://gerrit.omnirom.org/android_system_sepolicy refs/changes/19/33719/4 && git cherry-pick FETCH_HEAD
    cd ${customROM_dir}/build/make
    git fetch https://gerrit.omnirom.org/android_build refs/changes/20/33720/3 && git cherry-pick FETCH_HEAD
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
