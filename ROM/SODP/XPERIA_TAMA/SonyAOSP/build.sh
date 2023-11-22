#!/usr/bin/env bash

function set_variables() {
    echo "####SET VARIABLES START####"
    aosp_version=14
    build_out=/out
    customROM_dir=/code
    echo "####SET VARIABLES END####"
}

function add_custom_hacks() {
    echo "####CUSTOMROM HACKS ADDING START####"
    echo "####CUSTOMROM HACKS ADDING END####"
}

function build_sonyAOSP() {
    echo "####SONY AOSP BUILD START####"
    echo "####$1 Sim START####"
    functions_build_customROM_helper ${customROM_dir:?} "${1:?}"-userdebug

    cd ${customROM_dir:?}
    echo "Log build to ${build_out}/aosp-${aosp_version}_""${2:?}""-build.log"
    make -j dist > ${build_out}/aosp-${aosp_version}_"${2:?}"-build.log
    mv out/dist/"${1:?}"-ota-eng.*.zip ${build_out}/aosp-${aosp_version}-"$(date +%Y%m%d)"_"${2:?}".zip
    echo "####$1 Sim END####"
    echo "####SONY AOSP BUILD END####"
}

# exit script immediately if a command fails or a variable is unset
set -e

source TOOLS/functions.sh

functions_init

set_variables

functions_create_folders ${build_out:?}

# functions_update_customROM ${customROM_dir:?} # TODO Workaround until the manifest got fixed upstream
#  The following lines need to be removed https://github.com/ShujathMohd/local_manifests/blob/android-14.0.0_r1_legacy/qcom.xml#L36
#    <project path="vendor/qcom/opensource/bootctrl" name="vendor-qcom-opensource-bootctrl" groups="device" remote="sony" revision="aosp/LA.UM.9.12.r1" />
#  The following lines need to be removed https://github.com/ShujathMohd/local_manifests/blob/android-14.0.0_r1_legacy/untracked_hardware.xml#L5
#    <remove-project name="platform/hardware/qcom/bootctrl" />

add_custom_hacks

build_sonyAOSP aosp_h8216 akari # XZ2_SS
# build_sonyAOSP aosp_h8314 apollo # XZ2C_SS # Disabled because Shujath provides it on XDA
# build_sonyAOSP aosp_h8416 akatsuki # XZ3_SS # Disabled because Shujath provides it on XDA

functions_success "Sony AOSP"

set +e

exit 0
