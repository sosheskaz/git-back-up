#!/bin/sh
label=htop

source "$(dirname $0)/common.sh"

function backup() {
    tmpdir=$PWD
    cd "$HOME/.config/htop"
    rsync -rv . $tmpdir
    cd tmpdir
}

function restore() {
    mkdir -p -m 700 "$HOME/.config/htop"
    rsync -rv . "$HOME/.config/htop"
}

gitbackup $*
