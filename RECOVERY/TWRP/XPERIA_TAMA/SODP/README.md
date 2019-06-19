# SODP TWRP

## Links
- [XDA TWRP](https://forum.xda-developers.com/xperia-xz2/development/recovery-twrp-3-2-2-0-touch-recovery-t3821597)

## Requirements
- [Local manifest](https://github.com/MartinX3sAndroidDevelopment/OMNIROM_TWRP_local_manifests)

## Instructions for the normal omnirom build environment
- Enter the following commands in a terminal window: 
    ```bash
    mkdir omniROM
    cd omniROM
    repo init -u git://github.com/omnirom/android.git -b android-9.0
    ```
- Checkout the content of the local manifest
    ```bash
    cd omniROM/.repo
    git clone https://github.com/MartinX3sAndroidDevelopment/OMNIROM_TWRP_local_manifests local_manifests
    ```
- Download the code into the device repos created above:
    ```bash
    cd omniROM
    repo sync -j$((`nproc`));
    ```
- Build the TWRP bootimage ("-eng" build)
    ```bash
    # Apply the hacks from the build.sh needed for the SODP TWRP to work.
    cd omniROM
    source build/envsetup.sh;
    lunch; # your device
    make bootimage -j$((`nproc`));
    ```
    Or execute the `build.sh`

## Instructions for the minimal TWRP build environment
- Enter the following commands in a terminal window: 
    ```bash
    mkdir omniROM
    cd omniROM
    repo init -u git://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git -b twrp-9.0
    ```
- Checkout the content of the local manifest
    ```bash
    cd omniROM/.repo
    git clone https://github.com/MartinX3sAndroidDevelopment/OMNIROM_TWRP_local_manifests local_manifests
    rm local_manifests/twrp.xml
    ```
- Download the code into the device repos created above:
    ```bash
    cd omniROM
    repo sync -j$((`nproc`));
    ```
- Build the TWRP bootimage ("-eng" build)
    ```bash
    # Apply the hacks from the build.sh needed for the SODP TWRP to work.
    cd omniROM
    source build/envsetup.sh;
    lunch; # your device
    export ALLOW_MISSING_DEPENDENCIES=true
    make bootimage -j$((`nproc`));
    ```
    Or execute the `build.sh`
