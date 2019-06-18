# SonyAOSP

## Links
- [XDA SonyAOSP](https://forum.xda-developers.com/xperia-xz2/development/aosp-aosp-8-1-h8266-t3843269)

## Requirements
- [Local manifest](https://github.com/MartinX3sAndroidDevelopment/LOCAL_MANIFESTS_SonyAOSP)

## Instructions
- Enter the following commands in a terminal window: 
    ```bash
    mkdir sonyaosp
    cd sonyaosp
    repo init -u https://github.com/SonyAosp/platform_manifest -b android-9.0
    ```
- Checkout the content of the local manifest:
    ```bash
    cd sonyaosp/.repo
    git clone https://github.com/MartinX3sAndroidDevelopment/LOCAL_MANIFESTS_SonyAOSP.git local_manifests
    ```
- Download the code into the device repos created above:
    ```bash
    cd omniROM
    repo sync -j$((`nproc`));
    ```
- Build the image ("-userdebug" build):
    ```bash
    cd sonyaosp
    source build/envsetup.sh;
    lunch; # your device
    make -j$((`nproc`));
    ```
    Or execute the `build.sh`
