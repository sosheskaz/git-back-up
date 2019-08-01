#!/bin/bash
label=docker-stack

. "$(dirname $0)/../common.sh"

gbu_dest=/usr/local/etc/docker-service

backup() {
    cp $gbu_dest/*.yml .
}

restore() {
    mkdir -p $gbu_dest
    cp *.yml $gbu_dest
}

gitbackup $*
