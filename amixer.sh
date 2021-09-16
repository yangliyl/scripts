#!/bin/bash

volume() {
    if [ "$1" == "x" ];then
        amixer -qM set Master toggle
    else
        amixer -qM set Master 5%$1 umute
    fi
}

volume $1
