# OmniROM

## Links
- [XDA OmniROM](https://forum.xda-developers.com/xperia-xz2/development/rom-omnirom-9-0r30-t3897951)

## Requirements
- [Local manifest](https://github.com/MartinX3sAndroidDevelopment/LOCAL_MANIFESTS_OmniROM_TWRP)

## Instructions
- Enter the following commands in a terminal window: 
    ```bash
    mkdir omniROM
    cd omniROM
    repo init -u git://github.com/omnirom/android.git -b android-9.0
    ```
- Checkout the content of the local manifest:
    ```bash
    cd omniROM/.repo
    git clone https://github.com/MartinX3sAndroidDevelopment/LOCAL_MANIFESTS_OmniROM_TWRP.git local_manifests
    ```
- Download the code into the device repos created above:
    ```bash
    cd omniROM
    repo sync -j$((`nproc`));
    ```
- Build the image ("-userdebug" build):
    ```bash
    cd omniROM
    source build/envsetup.sh;
    lunch; # your device
    make -j$((`nproc`));
    ```
    Or execute the `build.sh`
