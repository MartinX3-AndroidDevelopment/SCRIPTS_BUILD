#!/usr/bin/env bash
#
# Copyright (c) 2020 Martin Dünkelmann
# All rights reserved.
#

function functions_set_variables() {
    export build_cache=/media/martin/extLinux/developer/android/cache/twrp_omni_minmal/9 #CustomROM out dir
    export current_dir=$(pwd)
    export customROM_dir=/home/developer/android/rom/platform_manifest_twrp_omni_android_9.0
}

function functions_build_omniROM_twrp() {
    cd ${customROM_dir}
    set +u
    source ${customROM_dir}/build/envsetup.sh
    set -u

    case "$1" in
        "xz2")
            export model_name=akari
            lunch omni_akari-eng
        ;;
        "xz2c")
            export model_name=apollo
            lunch omni_apollo-eng
        ;;
        "xz3")
            export model_name=akatsuki
            lunch omni_akatsuki-eng
        ;;
        *)
            echo "Unknown Option $1 in build_omniROM_twrp()"
            exit 1 # die with error code 9999
    esac

    make installclean # Clean build while saving the buildcache.

    make -j$((`nproc` - 1)) bootimage PLATFORM_SECURITY_PATCH_OVERRIDE=$2
}
