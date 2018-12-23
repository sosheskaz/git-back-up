#!/bin/sh
label=brew

source "$(dirname $0)/common.sh"
restore_helpmsg="Brew's restore mode can be used in 4 ways.
$0 restore <branch>: Restore formulae, casks, and taps.
$0 restore <branch> brew: Restore formulae.
$0 restore <branch> cask: Restore casks.
$0 restore <branch> taps: Restore taps."

function backup() {
    echo "Grabbing formulae..."
    brew list > brew.txt; exit_if_err
    echo "Grabbing casks..."
    brew cask list > brewcask.txt; exit_if_err
    echo "Grabbing taps..."
    # If we don't update breforehand, tap might try to update, which will work its way into the output.
    brew update > /dev/null; exit_if_err
    brew tap > brewtap.txt; exit_if_err
}

function restore() {
    if [ ! -z "$1" ] && [ "$1" != "brew" ] && [ "$1" != "cask" ] && [ "$1" != "taps" ]; then
        echo $restore_helpmsg
        exit 1
    fi

    which brew >> /dev/null
    if [ $? -ne 0 ]; then
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi

    brew update; exit_if_err


    restore_rc=0
    # These can error, but it's generally (sort of) okay
    if [ -z "$1" -o "$1" = "taps" ]; then
        echo "Restoring taps..."
        for tap in $(cat brewtap.txt); do
            brew tap "$tap"
            rc=$?
            if [ $rc -ne 0 ]; then restore_rc=$rc; fi
        done
    fi
    # Since taps can be used later, we ought to just update it again...
    brew update
    if [ -z "$1" -o "$1" = "brew" ]; then
        echo "Restoring formulae..."
        for formula in $(cat brew.txt); do
            brew install "$formula"
            rc=$?
            if [ $rc -ne 0 ]; then restore_rc=$rc; fi
        done
    fi
    if [ -z "$1" -o "$1" = "cask" ]; then
        echo "Restoring casks..."
        for cask in $(cat brewcask.txt); do
            brew cask install "$cask"
            rc=$?
            if [ $rc -ne 0 ]; then restore_rc=$rc; fi
        done
    fi

    brew cleanup; exit_if_err

    if [ $restore_rc -ne 0 ]; then
        echo "Something went wrong in the restore process; see above."
        cleanup
        exit $restore_rc
    fi
}

gitbackup $*
