#!/usr/bin/env bash

function functions_init() {
    # No ccache anymore since Android Q/10
    # Need to get installed/initiated
    # https://sx.ix5.org/info/post/android-q-changes/
    # https://sx.ix5.org/info/building-android/#optimize-the-build
    # Do not use the ccache!
    # There is no real performance increase over incremental builds.
    # If you add or remove the ccache usage on a build by accident,
    #  aosp wipes your "out" folder and you need to compile everything again.
    export WITHOUT_CHECK_API=true
}

function functions_create_folders() {
    echo "####Test if the $1 device folder exist or creates it START####"
    if [[ ! -d ${1:?} ]]
    then
        mkdir "${1:?}"
    fi
    echo "####Test if the $1 device folder exist or creates it END####"
}

function functions_test_repo_up_to_date() {
    echo "####Test if git repo is up-to-date START####"
    UPSTREAM=${1:-'@{u}'}
    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse "${UPSTREAM:?}")
    BASE=$(git merge-base @ "${UPSTREAM:?}")

    if [[ ${LOCAL:?} = "${REMOTE:?}" ]]; then
        echo "Git repo is up-to-date!"
        git prune # Remove unneeded elements to save space and time.
    elif [[ ${LOCAL:?} = "${BASE:?}" ]]; then
        echo "Git repo not up to date!"
        read -n1 -r -p "Press space to continue..."
    elif [[ ${REMOTE:?} = "${BASE:?}" ]]; then
        echo "Git repo as uncommitted changes"
        read -n1 -r -p "Press space to continue..."
    else
        echo "Git repo is in a weird state."
        echo "Try 'git reset --hard'."
        read -n1 -r -p "Press space to continue..."
    fi
    echo "####Test if git repo is up-to-date END####"
}

function functions_update_customROM() {
    echo "####CustomROM UPDATE START####"
    cd "${1:?}"/.repo/local_manifests || exit
    git reset --hard
    git pull

    cd "${1:?}" || exit
    repo forall -vc "git reset --hard"

    repo sync repo_update --force-sync
    ./repo_update.sh

    repo prune # Remove unneeded elements to save space and time.
    echo "####CustomROM UPDATE END####"
}

function functions_build_customROM_helper() {
    cd "${1:?}" || exit
    # shellcheck disable=SC1090 # Since it is from the rom source code
    source "${1:?}"/build/envsetup.sh

    lunch "${2:?}"

    make installclean # Clean build while saving the buildcache.
}
