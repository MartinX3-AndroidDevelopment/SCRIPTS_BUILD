#!/usr/bin/env bash
#
# Copyright (c) 2019 Martin Dünkelmann
# All rights reserved.
#

function functions_init() {
    # Important to avoid compiler errors on nonenglish systems
    export LANG=de_DE.UTF-8
    export LC_ALL=C

    # No ccache anymore since Android Q/10
    # Need to get installed/initiated
    # https://sx.ix5.org/info/post/android-q-changes/
    # https://sx.ix5.org/info/building-android/#optimize-the-build
    export CCACHE_EXEC=/usr/bin/ccache
    export USE_CCACHE=1
    export CCACHE_COMPRESS=1
    export WITHOUT_CHECK_API=true
}

function functions_create_folders() {
    echo "####Test if the $1 device folder exist or creates it START####"
    if [[ ! -d $1 ]]
    then
        mkdir $1
    fi
    echo "####Test if the $1 device folder exist or creates it END####"
}

function functions_test_repo_up_to_date() {
    echo "####Test if git repo is up-to-date START####"
    UPSTREAM=${1:-'@{u}'}
    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse "$UPSTREAM")
    BASE=$(git merge-base @ "$UPSTREAM")

    if [[ ${LOCAL} = ${REMOTE} ]]; then
        echo "Git repo is up-to-date!"
    elif [[ ${LOCAL} = ${BASE} ]]; then
        echo "Git repo not up to date!"
        read -n1 -r -p "Press space to continue..."
    elif [[ ${REMOTE} = ${BASE} ]]; then
        echo "Git repo as uncommited changes"
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
    cd $1/.repo/local_manifests
    git reset --hard
    git pull

    cd $1
    repo forall -vc "git reset --hard"
    repo sync --force-sync -j32
    echo "####CustomROM UPDATE END####"
}

function functions_compress_builds() {
    echo "####COMPRESSING $1 BUILD START####"
    cd $1
    tar -zcvf $1/../$(date +%Y-%m-%d_%H-%M-%S)_$2.tar.gz *
    echo "####COMPRESSING $1 BUILD END####"
}

function functions_clean_builds() {
    echo "####CLEANING $1 BUILD START####"
    rm $1/*
    echo "####CLEANING $1 BUILD END####"
}

