#!/usr/bin/env bash

function functions_build_customROM_helper() {
    cd "${1:?}" || exit
    # shellcheck disable=SC1090 # Since it is from the rom source code
    source "${1:?}"/build/envsetup.sh

    lunch "${2:?}"

    make installclean # Clean build while saving the buildcache and provides a clean state if the container crashed.
}

function functions_create_folders() {
    echo "####Test if the $1 device folder exist or creates it START####"
    if [[ ! -d ${1:?} ]]
    then
        mkdir "${1:?}"
    fi
    echo "####Test if the $1 device folder exist or creates it END####"
}

function functions_init() {
    # No ccache anymore since Android Q/10
    # Need to get installed/initiated
    # https://sx.ix5.org/info/post/android-q-changes/
    # https://sx.ix5.org/info/building-android/#optimize-the-build
    # Do not use the ccache!
    # There is no real performance increase over incremental builds.
    # If you add or remove the ccache usage on a build by accident,
    #  aosp wipes your "out" folder and you need to compile everything again.

    # Place environmental variables here
    # export WITHOUT_CHECK_API=true

    return 0
}

function functions_success() {
    echo "Upload to androidfilehost.com !"
    echo "Upload to dhacke strato server !"
    echo "The following android build is ready: $1" | msmtp -a default android-builder@localhost
}

function functions_update_customROM() {
    echo "####CustomROM UPDATE START####"
    cd "${1:?}"/.repo/local_manifests || exit
    git reset --hard
    git pull

    cd "${1:?}" || exit
    repo forall -vc "git reset --hard"

    repo sync -c --force-sync repo_update
    ./repo_update.sh

    repo prune # Remove unneeded elements to save space and time.
    echo "####CustomROM UPDATE END####"
}
