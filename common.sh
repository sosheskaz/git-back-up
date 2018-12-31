#!/bin/sh
if [ -z "$label" ]; then
    echo "Error: Label not set by git-back-up function!"
    exit 2
fi

gitbackup_dir=$(dirname $0)
startdir=$PWD
cd "$gitbackup_dir"
gitbackup_dir=$PWD
cd "$startdir"

repofile="$gitbackup_dir/repo.txt"
repo=$(cat "$repofile" 2>/dev/null)
branch="$label-$(whoami)@$(hostname | cut -d '.' -f 1)"
utildir="/tmp/$branch"

exit_if_err() {
    rc=$?
    if [ $rc -ne 0 ]; then
        cleanup
        exit $rc;
    fi
}

pre_backup() {
    mkdir -m 0700 -p "$utildir"
    cd "$utildir"
    git clone -b "$branch" "$repo" . || (git init && git checkout -b "$branch" && git remote add origin "$repo"); exit_if_err
    git rm -rf .
    git clean -fxd
}

post_backup() {
    cd "$utildir"
    git add -A; exit_if_err
    git commit -am "Automated Commit $(date)"; exit_if_err
    git push --set-upstream origin "$branch"; exit_if_err
    cd "$startdir"
    rm -rf "$utildir"
}

pre_restore() {
    restore_branch="$1"
    mkdir -m 0700 -p "$utildir"
    cd "$utildir"
    mkdir -m 0700 -p "$utildir"
    cd "$utildir"
    git clone -b "$restore_branch" "$repo" .; exit_if_err

    # Otherwise tools like rsync will capture it
    rm -rf .git
}

cleanup() {
    cd $startdir
    if [ -d "$utildir" ]; then rm -rf "$utildir"; exit_if_err; fi
}

show_help() {
    echo "Usage:

Set repository to use:
    $0 repo <your_repo>

View current repository in use:
    $0 repo

Perform a backup:
    $0 backup

Perform a restore:
    $0 restore <restore_branch>

View this help page:
    $0 help"
}

gitbackup() {
    command="$1"
    if [ "$command" = "backup" ]; then
        if [ ! -f "$repofile" ]; then
            echo "Repo not set! You need to set the repo first."
            show_help
            exit -1
        fi
        cleanup
        pre_backup
        backup "${@:2}"
        post_backup
        cleanup
    elif [ "$command" = "restore" ]; then
        if [ ! -f "$repofile" ]; then
            echo "Repo not set! You need to set the repo first."
            show_help
            exit -1
        fi
        restore_branch="$2"
        if [ -z "$restore_branch" ]; then
            echo "You must add a branch to restore from, when using in restore mode."
            echo "Run $0 help to show a help page."
            exit 1
        fi
        cleanup
        pre_restore $restore_branch
        restore "${@:3}"
        cleanup
    elif [ "$command" = "repo" ]; then
        if [ -z "$2" ]; then
            if [ -f "$repofile" ]; then
                cat "$repofile"
                echo
            else
                echo "No repo set. Run '$0 help' to see how to do that."
            fi
        else
            printf "$2" > "$gitbackup_dir/repo.txt"
        fi
    elif [ "$command" = "help" ]; then
        show_help
    elif [ -z "$command" ]; then
        echo "No command given; select repo, backup, or restore."
        echo "Or run $0 help to show a help page."
        exit 1
    else
        echo "Invalid command '$command'; select repo, backup, or restore."
        echo "Or run $0 help to show a help page."
    fi
}
