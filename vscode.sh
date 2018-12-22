#!/bin/sh
label=vscode

source "$(dirname $0)/common.sh"

kernel="$(uname)"
if [ "$kernel" = "Darwin" ]; then
    vscode_dir="$HOME/Library/Application Support/Code/User"
else
    vscode_dir="$HOME/.config/Code/User"
fi

function backup() {
    tmpdir=$PWD
    cd "$vscode_dir"; exit_if_err
    rsync -r . $tmpdir --exclude="workspaceStorage/**" --exclude="globalStorage/**" --exclude=".git/*"; exit_if_err
    cd $tmpdir; exit_if_err
    code --list-extensions > extensions.txt; exit_if_err
}

function restore() {
    anyfailed=0
    for extension in $(cat extensions.txt); do
        code --install-extension "$extension"
        rc=$?
        if [ $rc -ne 0 ]; then anyfailed=$rc; fi
    done
    if [ $anyfailed -ne 0 ]; then exit $anyfailed; fi

    rm extensions.txt
    rsync -rv . "$vscode_dir" --exclude=".git/*"
}

gitbackup $*
