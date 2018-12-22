#!/bin/sh
label=shprofile

source "$(dirname $0)/common.sh"

function backup() {
    tmpdir=$PWD
    cd $HOME
    filelist=".bash_profile .bash_login .profile .bashrc .bash_logout .zshrc"
    rsync -v $filelist "$tmpdir"
    cd $tmpdir
    git add $filelist
}

function restore() {
    rsync -rv . "$HOME"
}

gitbackup $*
