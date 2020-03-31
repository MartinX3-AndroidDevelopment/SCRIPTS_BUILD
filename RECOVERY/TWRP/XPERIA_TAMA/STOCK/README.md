Copyright (c) 2020 Martin Dünkelmann  
All rights reserved.

# Stock TWRP

## Links
- [XDA TWRP](https://forum.xda-developers.com/xperia-xz2/development/recovery-twrp-3-3-1-0-t4074305)

## Requirements
- [Local manifest](https://github.com/MartinX3-AndroidDevelopment-OmniROM/local_manifests)

## Instructions for the minimal TWRP build environment
- Enter the following commands in a terminal window:
    ```bash
    mkdir minimal-manifest-twrp_OmniROM
    cd minimal-manifest-twrp_OmniROM
    repo init -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni -b twrp-9.0
    ```
- Checkout the content of the local manifest
    ```bash
    cd omniROM/.repo
    git clone https://github.com/MartinX3-AndroidDevelopment-OmniROM/local_manifests -b MartinX3/omnirom-9.0_twrp-10.0 local_manifests
    rm local_manifests/twrp.xml
    ```
- Download the code into the device repos created above:
    ```bash
    cd minimal-manifest-twrp_OmniROM
    repo sync -j$((`nproc`));
    ```
- Build the TWRP bootimage ("-eng" build)
    ```bash
    # Apply the hacks from the build.sh needed for the SODP TWRP to work.
    bash build.sh
    ```
