#!/bin/sh
label=brew

source "$(dirname $0)/common.sh"

function backup() {
    brew list > brew.txt; exit_if_err
    brew cask list > brewcask.txt; exit_if_err
}

function restore() {
    which brew >> /dev/null
    if [ $? -ne 0 ]; then
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi

    brew update; exit_if_err

    # These can error, but it's generally (sort of) okay
    xargs brew install < brew.txt
    xargs brew cask install < brewcask.txt

    brew cleanup; exit_if_err
}

gitbackup $*
