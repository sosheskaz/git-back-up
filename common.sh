#!/bin/sh
if [ -z "$label" ]; then
    echo "Error: Label not set by git-back-up function!"
    exit 2
fi

repo='https://github.com/sosheskaz/git-back-up-util'
branch="$label-$(whoami)@$(hostname | cut -d '.' -f 1)"
utildir="/tmp/$branch"
startdir=$PWD

function exit_if_err() {
    rc=$?
    if [ $rc -ne 0 ]; then
        cleanup
        exit $rc;
    fi
}

function pre_backup() {
    mkdir -m 0700 -p "$utildir"
    cd "$utildir"
    git clone -b "$branch" "$repo" . || (git init && git checkout -b "$branch" && git remote add origin "$repo"); exit_if_err
}

function post_backup() {
    cd "$utildir"
    git add *
    git commit -m "Automated Commit $(date)"
    git push --set-upstream origin "$branch"
}

function pre_restore() {
    restore_branch="$1"
    cd "$utildir"
    mkdir -m 0700 -p "$utildir"
    cd "$utildir"
    git clone -b "$restore_branch" "$repo" .; exit_if_err
}

function cleanup() {
    cd $startdir
    rm -rf "$utildir" || true
}

function gitbackup() {
    command="$1"
    if [ "$command" = "backup" ]; then
        cleanup
        pre_backup
        backup
        post_backup
        cleanup
    elif [ "$command" = "restore" ]; then
        restore_branch="$2"
        if [ -z "$restore_branch" ]; then
            echo "You must add a branch to restore from, when using in restore mode."
            exit 1
        fi
        cleanup
        pre_restore $restore_branch
        restore
        cleanup
    elif [ -z "$command" ]; then
        echo "No command given; select backup or restore."
        exit 1
    else
        echo "Invalid command '$command'; select backup or restore."
    fi
}