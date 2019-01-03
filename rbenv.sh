#!/bin/sh
label=rbenv

source "$(dirname $0)/common.sh"

backup() {
    rbenv versions --bare > versions.txt
    rbenv global > global.txt
}

restore() {
    xargs rbenv install --skip-existing < versions.txt
    rbenv global "$(cat global.txt)"
}

gitbackup $*
