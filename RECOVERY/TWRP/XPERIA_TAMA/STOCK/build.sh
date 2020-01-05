#!/usr/bin/env bash
#
# Copyright (c) 2019 Martin Dünkelmann
# All rights reserved.
#

function set_variables() {
    build_cache=/media/martin/extLinux/developer/android/cache/omniROM/9 #CustomROM out dir
    build_cache_SODP_TWRP=/media/martin/extLinux/developer/android/cache/twrp/stock/9/SODP_TWRP
    build_cache_stock_kernel=/media/martin/extLinux/developer/android/cache/twrp/stock/9/stockKernelBinary
    build_out=/media/martin/extLinux/developer/android/out/twrp/stock/9
    current_dir=$(pwd)
    current_dir_tools_aik=/media/martin/extLinux/developer/android/tools/Android-Image-Kitchen
    customROM_dir=/home/developer/android/rom/omniROM/9
    stock_kernel_dir=/home/developer/android/MartinX3sAndroidDevelopment/sonyxperiadev-KERNEL_SONY_XPERIA_STOCK
    stock_version_number=52.0.A.11.32
    # absolute path, no shell variables or the compilation of the stock kernel fails
    export ARCH=arm64
    export CROSS_COMPILE=aarch64-linux-android-
    export DTC_EXT=/media/martin/extLinux/developer/android/tools/stock_kernel/dtc
    export DTC_OVERLAY_TEST_EXT=/media/martin/extLinux/developer/android/tools/stock_kernel/ufdt_apply_overlay_host
    export KCFLAGS=-mno-android
    export O=/home/developer/android/MartinX3sAndroidDevelopment/sonyxperiadev-kernel-copyleft/out
    export PATH=/media/martin/extLinux/developer/android/tools/stock_kernel/aarch64-linux-android-4.9/bin/:$PATH
}

function add_custom_hacks() {
    echo "####CUSTOMROM HACKS ADDING START####"
    cd ${customROM_dir}

    #TODO: Make TWRP buildable -> Remove if it got merged
    git fetch "https://gerrit.twrp.me/android_bootable_recovery" refs/changes/57/1757/1 && git cherry-pick FETCH_HEAD

    # Enabling hack to load TWRP via 'fastboot boot twrp.img'
    echo "CONFIG_DEBUG_RENAME_SKIP_INITRAMFS_BOOTPARAM=y" >> ${customROM_dir}/kernel/sony/msm/arch/arm64/configs/sony/base_tama_common_defconfig

    # patching the prepdecrypt.sh files to adapt the differences of the stock firmware
    sed -i -e 's/oem_a/vendor$suffix/g' ${customROM_dir}/device/sony/tama-common/recovery/prepdecrypt.sh

    # Added the file needed to fix the touch in the service definition right after the decryption preparations
    sed -i -e 's/exec u:r:recovery:s0 root root -- \/sbin\/prepdecrypt.sh/exec u:r:recovery:s0 root root -- \/sbin\/prepdecrypt.sh\n    exec u:r:recovery:s0 root root -- \/sbin\/preptouch.sh/g' ${customROM_dir}/device/sony/tama-common/recovery/init.recovery.twrp.rc
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

    yes | cp -rf ${build_cache}/target/product/${model_name}/boot.img ${build_cache_SODP_TWRP}/$1/
    echo "####$1 END####"

    case "$1" in
        "xz2")
            echo "####XZ2P START####"
            yes | cp -rf ${build_cache}/target/product/${model_name}/boot.img ${build_cache_SODP_TWRP}/xz2p/
            echo "####XZ2P END####"
        ;;
    esac
    echo "####OmniROM TWRP BUILD END####"
}

function update_stock_kernel_repo() {
    echo "####STOCK KERNEL REPO UPDATE START####"
    cd ${stock_kernel_dir}
    if [[ ! -d .git ]]
    then
        git clone https://github.com/MartinX3sAndroidDevelopment/sonyxperiadev-KERNEL_SONY_XPERIA_STOCK.git -b ${stock_version_number} .
    else
        git reset --hard
        git pull
        git checkout ${stock_version_number}
    fi
    echo "####STOCK KERNEL REPO UPDATE END####"
}

function build_stockROM_kernel() {
    echo "####STOCK KERNEL BUILD START####"
    cd ${stock_kernel_dir}

    boot_img_name=boot.img
    boot_img_kernel_name=${boot_img_name}-zImage

    echo "####$1 START####"
    case "$1" in
        "xz2")
            export KBUILD_DIFFCONFIG=akari_diffconfig
        ;;
        "xz2p")
            export KBUILD_DIFFCONFIG=aurora_diffconfig
        ;;
        "xz2c")
            export KBUILD_DIFFCONFIG=apollo_diffconfig
        ;;
        "xz3")
            export KBUILD_DIFFCONFIG=akatsuki_diffconfig
        ;;
        *)
            echo "Unknown Option $1 in build_stockROM_kernel()"
            exit 1 # die with error code 9999
    esac

    if [[ ! -f ${build_cache_stock_kernel}/$1/${boot_img_kernel_name} ]]; then
        make mrproper && make clean && rm -rf ./out
        make CONFIG_BUILD_ARM64_DT_OVERLAY=y O=./out sdm845-perf_defconfig -j8
        make CONFIG_BUILD_ARM64_DT_OVERLAY=y O=./out -j8
        cp -rf ${stock_kernel_dir}/out/arch/arm64/boot/Image.gz-dtb ${build_cache_stock_kernel}/$1/${boot_img_kernel_name}
    else
        echo "####$1 KERNEL ALREADY BUILT####"
    fi
    echo "####$1 END####"
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
    # copy the stock touch drivers
    yes | cp -rf ${current_dir}/sbin/* ${current_dir_tools_aik}/ramdisk/sbin

    rm ${current_dir_tools_aik}/${boot_img_name}

    # copy the self compiled stock kernel with merged dtbo
    yes | cp -rf ${build_cache_stock_kernel}/$1/${boot_img_kernel_name} ${current_dir_tools_aik}/split_img/${boot_img_kernel_name}

    case "$1" in
        "xz2")
            model_name=akari
        ;;
        "xz2p")
            model_name=akari # we're using the akari aosp file
        ;;
        "xz2c")
            model_name=apollo
        ;;
        "xz3")
            model_name=akatsuki
        ;;
        *)
            echo "Unknown Option $1 in build_stockROM_twrp()"
            exit 1 # die with error code 9999
    esac
    # workaround -> on stock rom # [ro.boot.hardware]: [qcom] # [ro.hardware]: [qcom]
    # on aosp / custom rom (example) # [ro.boot.hardware]: [akari] # [ro.hardware]: [akari]
    cp ${current_dir_tools_aik}/ramdisk/init.recovery.${model_name}.rc ${current_dir_tools_aik}/ramdisk/init.recovery.qcom.rc

    # repack to create the stock twrp boot.img
    bash ${current_dir_tools_aik}/repackimg.sh
    yes | cp -rf ${current_dir_tools_aik}/${boot_img_new_name} ${build_out}/$1/twrp-$1.img
    yes | cp -rf ${current_dir_tools_aik}/${boot_img_new_name} ${current_dir_tools_aik}/${boot_img_name}
    rm ${current_dir_tools_aik}/${boot_img_new_name}
    bash ${current_dir_tools_aik}/cleanup.sh
    echo "####TWRP.img END####"

    yes | cp -rf ${current_dir}/../template/*.* ${build_out}/$1/
    yes | cp -rf ${current_dir}/template/*.* ${build_out}/$1/
    echo "####Stock TWRP $1 BUILD END####"
}

echo "Did you set the correct stock version number?"
echo "Did you update the stock firmware files?"
echo "Are the template files up-to-date?"
echo "Did you update the tools?"
echo "IS THIS SHELL IN THE REPOSITORY? Or did you modify the current_dir variable?"
read -n1 -r -p "Press space to continue..."

source ../../../../TOOLS/functions.sh

functions_init

set_variables

functions_create_folders ${build_cache}
functions_create_folders ${build_cache_stock_kernel}
functions_create_folders ${build_cache_stock_kernel}/xz2
functions_create_folders ${build_cache_stock_kernel}/xz2p
functions_create_folders ${build_cache_stock_kernel}/xz2c
functions_create_folders ${build_cache_stock_kernel}/xz3
functions_create_folders ${build_cache_SODP_TWRP}
functions_create_folders ${build_cache_SODP_TWRP}/xz2
functions_create_folders ${build_cache_SODP_TWRP}/xz2p
functions_create_folders ${build_cache_SODP_TWRP}/xz2c
functions_create_folders ${build_cache_SODP_TWRP}/xz3
functions_create_folders ${build_out}
functions_create_folders ${build_out}/xz2
functions_create_folders ${build_out}/xz2p
functions_create_folders ${build_out}/xz2c
functions_create_folders ${build_out}/xz3

functions_test_repo_up_to_date

functions_clean_builds ${build_cache_stock_kernel}
functions_clean_builds ${build_out}/xz2
functions_clean_builds ${build_out}/xz2p
functions_clean_builds ${build_out}/xz2c
functions_clean_builds ${build_out}/xz3

functions_update_customROM ${customROM_dir}

add_custom_hacks

build_omniROM_twrp xz2 # Includes xz2p
build_omniROM_twrp xz2c
build_omniROM_twrp xz3

update_stock_kernel_repo

build_stockROM_kernel xz2
build_stockROM_kernel xz2p
build_stockROM_kernel xz2c
build_stockROM_kernel xz3

build_stockROM_twrp xz2
build_stockROM_twrp xz2p
build_stockROM_twrp xz2c
build_stockROM_twrp xz3

functions_compress_builds ${build_out}/xz2 twrp_stock_xz2_${stock_version_number}
functions_compress_builds ${build_out}/xz2p twrp_stock_xz2p_${stock_version_number}
functions_compress_builds ${build_out}/xz2c twrp_stock_xz2c_${stock_version_number}
functions_compress_builds ${build_out}/xz3 twrp_stock_xz3_${stock_version_number}

functions_clean_builds ${build_cache_stock_kernel}
functions_clean_builds ${build_out}/xz2
functions_clean_builds ${build_out}/xz2p
functions_clean_builds ${build_out}/xz2c
functions_clean_builds ${build_out}/xz3

echo "Output ${build_out}"
read -n1 -r -p "Press space to continue..."
echo "Upload to androgidfilehost.com !"
read -n1 -r -p "Press space to continue..."
echo "Upload to dhacke strato server !"
read -n1 -r -p "Press space to continue..."

exit 0
