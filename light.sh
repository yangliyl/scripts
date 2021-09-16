#!/bin/bash

light() {
    if [ "$1" == "+" ]; then
        xbacklight -inc 5
    else
        xbacklight -dec 5
    fi
}

light $1
