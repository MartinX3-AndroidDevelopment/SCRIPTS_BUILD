#!/usr/bin/env bash
#
# Copyright (c) 2019-2020 Martin Dünkelmann
# All rights reserved.
#

function set_variables() {
    echo "####SET VARIABLES START####"
    android_code_folder=/home/developer/android
    android_stuff_folder=/media/martin/extLinux/developer/android # A shiny variable name, isn't it?
    android_stuff_folder_cache=${android_stuff_folder}/cache
    android_stuff_folder_cache_twrp=${android_stuff_folder_cache}/twrp/stock/10
    build_cache_customROM=${android_stuff_folder_cache}/twrp_omni_minimal/9 #CustomROM out dir
    build_out=${android_stuff_folder}/out/twrp/stock/10
    build_cache_SODP_TWRP=${android_stuff_folder_cache_twrp}/SODP_TWRP
    build_cache_stock_kernel=${android_stuff_folder_cache_twrp}/stockKernelBinary
    current_dir=$(pwd)
    current_dir_tools_aik=${android_stuff_folder}/tools/Android-Image-Kitchen
    customROM_dir=${android_code_folder}/rom/platform_manifest_twrp_omni_android_9.0
    stock_kernel_dir=${android_code_folder}/MartinX3-AndroidDevelopment/sonyxperiadev-KERNEL_SONY_XPERIA_STOCK
    echo "####SET VARIABLES END####"
}

function add_custom_hacks() {
    echo "####CUSTOMROM HACKS ADDING START####"
    echo "####CUSTOMROM HACKS ADDING END####"
}

function build_omniROM_twrp() {
    echo "####OmniROM TWRP BUILD START####"
    echo "####$1 START####"
    # functions_twrp_build_customROM_helper customROM_dir device_name PLATFORM_SECURITY_PATCH_OVERRIDE TARGET_STOCK
    functions_twrp_build_customROM_helper ${customROM_dir} $1 true

    yes | cp -rf ${build_cache_customROM}/target/product/$1/boot.img ${build_cache_SODP_TWRP}/$1/
    echo "####$1 END####"

    case "$1" in
        "akari")
            echo "####Aurora START####"
            yes | cp -rf ${build_cache_customROM}/target/product/$1/boot.img ${build_cache_SODP_TWRP}/aurora/
            echo "####Aurora END####"
        ;;
    esac
    echo "####OmniROM TWRP BUILD END####"
}

function update_stock_kernel_repo() {
    echo "####STOCK KERNEL REPO UPDATE START####"
    cd ${stock_kernel_dir}
    if [[ ! -d .git ]]
    then
        git clone https://github.com/MartinX3-AndroidDevelopment/sonyxperiadev-KERNEL_SONY_XPERIA_STOCK.git -b tama .
    else
        git reset --hard
        git pull
        git checkout tama
    fi
    echo "####STOCK KERNEL REPO UPDATE END####"
}

function build_stockROM_kernel() {
    echo "####STOCK KERNEL BUILD START####"
    # absolute path, no shell variables or the compilation of the stock kernel fails
    export ARCH=arm64
    export CROSS_COMPILE=aarch64-linux-android-
    export DTC_EXT=/media/martin/extLinux/developer/android/tools/stock_kernel/dtc
    export DTC_OVERLAY_TEST_EXT=/media/martin/extLinux/developer/android/tools/stock_kernel/ufdt_apply_overlay_host
    export KCFLAGS=-mno-android
    export O=/home/developer/android/MartinX3-AndroidDevelopment/sonyxperiadev-kernel-copyleft/out
    PATH_backup=$PATH
    export PATH=/media/martin/extLinux/developer/android/tools/stock_kernel/aarch64-linux-android-4.9/bin/:$PATH

    cd ${stock_kernel_dir}

    boot_img_name=boot.img
    boot_img_kernel_name=${boot_img_name}-zImage

    echo "####$1 START####"
    export KBUILD_DIFFCONFIG=$1_diffconfig

    if [[ ! -f ${build_cache_stock_kernel}/$1/${boot_img_kernel_name} ]]; then
        make mrproper && make clean && rm -rf ./out
        make CONFIG_BUILD_ARM64_DT_OVERLAY=y O=./out sdm845-perf_defconfig -j8
        make CONFIG_BUILD_ARM64_DT_OVERLAY=y O=./out -j8
        cp -rf ${stock_kernel_dir}/out/arch/arm64/boot/Image.gz-dtb ${build_cache_stock_kernel}/$1/${boot_img_kernel_name}
    else
        echo "####$1 KERNEL ALREADY BUILT####"
    fi
    echo "####$1 END####"
    # empty it or the SODP kernel compilation fails
    export ARCH=""
    export CROSS_COMPILE=""
    export DTC_EXT=""
    export DTC_OVERLAY_TEST_EXT=""
    export KCFLAGS=""
    export O=""
    # Restore it instead or the bash environment is destroyed
    export PATH=$PATH_backup
    echo "####STOCK KERNEL BUILD END####"
}

function build_stockROM_twrp() {
    echo "####Stock TWRP $1 BUILD START####"
    boot_img_new_name=image-new.img
    boot_img_name=boot.img
    boot_img_kernel_name=${boot_img_name}-zImage

    echo "####TWRP.img START####"
    rm -rf ${build_out}/$1/*

    # Unzip twrp boot img
    yes | cp -rf ${build_cache_SODP_TWRP}/$1/${boot_img_name} ${current_dir_tools_aik}/
    bash ${current_dir_tools_aik}/unpackimg.sh --nosudo
    # copy the stock fstab
    yes | cp -rf ${current_dir}/etc/* ${current_dir_tools_aik}/ramdisk/etc

    rm ${current_dir_tools_aik}/${boot_img_name}

    # copy the self compiled stock kernel with merged dtbo
    yes | cp -rf ${build_cache_stock_kernel}/$1/${boot_img_kernel_name} ${current_dir_tools_aik}/split_img/${boot_img_kernel_name}

    # workaround -> on stock rom # [ro.boot.hardware]: [qcom] # [ro.hardware]: [qcom]
    # on aosp / custom rom (example) # [ro.boot.hardware]: [akari] # [ro.hardware]: [akari]
    model_name=$1
    if [[ "$1" == "aurora" ]]; then
        model_name=akari
    fi
    cp ${current_dir_tools_aik}/ramdisk/init.recovery.${model_name}.rc ${current_dir_tools_aik}/ramdisk/init.recovery.qcom.rc

    # repack to create the stock twrp boot.img
    bash ${current_dir_tools_aik}/repackimg.sh
    yes | cp -rf ${current_dir_tools_aik}/${boot_img_new_name} ${build_out}/$1/twrp-$1.img
    yes | cp -rf ${current_dir_tools_aik}/${boot_img_new_name} ${current_dir_tools_aik}/${boot_img_name}
    rm ${current_dir_tools_aik}/${boot_img_new_name}
    bash ${current_dir_tools_aik}/cleanup.sh
    echo "####TWRP.img END####"

    # Copy the template files into the output folder to get bundled
    yes | cp -rf ${current_dir}/../template/*.* ${build_out}/$1/
    echo "####Stock TWRP $1 BUILD END####"
}

# exit script immediately if a command fails or a variable is unset
set -e

echo "Did you set the correct stock version number?"
echo "Did you update the stock firmware files?"
echo "Are the template files up-to-date?"
echo "Did you update the kernel compilation tools?"
echo "IS THIS SHELL IN THE REPOSITORY? Or did you modify the current_dir variable?"
read -n1 -r -p "Press space to continue..."

source ../../../../TOOLS/functions.sh # Functions for every script
source ../../functions.sh # Functions for every TWRP script

functions_init

set_variables

functions_create_folders ${build_cache_customROM}
functions_create_folders ${build_cache_stock_kernel}
functions_create_folders ${build_cache_stock_kernel}/akari
functions_create_folders ${build_cache_stock_kernel}/aurora
functions_create_folders ${build_cache_stock_kernel}/apollo
functions_create_folders ${build_cache_stock_kernel}/akatsuki
functions_create_folders ${build_cache_SODP_TWRP}
functions_create_folders ${build_cache_SODP_TWRP}/akari
functions_create_folders ${build_cache_SODP_TWRP}/aurora
functions_create_folders ${build_cache_SODP_TWRP}/apollo
functions_create_folders ${build_cache_SODP_TWRP}/akatsuki
functions_create_folders ${build_out}
functions_create_folders ${build_out}/akari
functions_create_folders ${build_out}/aurora
functions_create_folders ${build_out}/apollo
functions_create_folders ${build_out}/akatsuki

functions_test_repo_up_to_date

functions_twrp_clean_builds ${build_cache_stock_kernel}/akari
functions_twrp_clean_builds ${build_cache_stock_kernel}/aurora
functions_twrp_clean_builds ${build_cache_stock_kernel}/apollo
functions_twrp_clean_builds ${build_cache_stock_kernel}/akatsuki
functions_twrp_clean_builds ${build_out}/akari
functions_twrp_clean_builds ${build_out}/aurora
functions_twrp_clean_builds ${build_out}/apollo
functions_twrp_clean_builds ${build_out}/akatsuki

functions_update_customROM ${customROM_dir}

add_custom_hacks

build_omniROM_twrp akari # xz2 includes aurora/xz2p
build_omniROM_twrp apollo # xz2c
build_omniROM_twrp akatsuki # xz3

update_stock_kernel_repo

build_stockROM_kernel akari
build_stockROM_kernel aurora
build_stockROM_kernel apollo
build_stockROM_kernel akatsuki

build_stockROM_twrp akari
build_stockROM_twrp aurora
build_stockROM_twrp apollo
build_stockROM_twrp akatsuki

functions_twrp_compress_builds ${build_out}/akari twrp_stock_akari
functions_twrp_compress_builds ${build_out}/aurora twrp_stock_aurora
functions_twrp_compress_builds ${build_out}/apollo twrp_stock_apollo
functions_twrp_compress_builds ${build_out}/akatsuki twrp_stock_akatsuki

functions_twrp_clean_builds ${build_cache_stock_kernel}/akari
functions_twrp_clean_builds ${build_cache_stock_kernel}/aurora
functions_twrp_clean_builds ${build_cache_stock_kernel}/apollo
functions_twrp_clean_builds ${build_cache_stock_kernel}/akatsuki
functions_twrp_clean_builds ${build_out}/akari
functions_twrp_clean_builds ${build_out}/aurora
functions_twrp_clean_builds ${build_out}/apollo
functions_twrp_clean_builds ${build_out}/akatsuki

echo "Output ${build_out}"
read -n1 -r -p "Press space to continue..."
echo "Upload to androidfilehost.com !"
read -n1 -r -p "Press space to continue..."
echo "Upload to dhacke strato server !"
read -n1 -r -p "Press space to continue..."

set +e

exit 0
