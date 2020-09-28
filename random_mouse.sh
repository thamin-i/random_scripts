#!/usr/bin/env bash

_display_help() {
    printf "This script randomly moves the mouse cursor on the screen\n"
    printf "USAGE:\n"
    printf "\tbash ${script_name} [min_sleep] [max sleep]\n"
    printf "EXAMPLE:"
    printf "\n\tbash ${script_name} 1 3600\n"
    printf "PARAMETERS:\n"
    printf "\t[min_sleep]\tMinimal sleep time between random moves (in seconds)\n"
    printf "\t[max_sleep]\tMaximal sleep time between random moves (in seconds)\n"
}

script_name=$0
sleep_min=$1
sleep_max=$2

if [ -z "${sleep_min}" ] ||  [ -z "${sleep_max}" ]; then
    _display_help
    exit 1
fi

while true; do
    angle=$(shuf -i 0-360 -n 1)
    distance=$(shuf -i 0-100 -n 1)
    sleep=$(shuf -i $sleep_min-$sleep_max -n 1)
    for (( i=0; i<$distance; i++ )); do
        xdotool mousemove_relative --polar $angle 10
    done
    sleep $sleep
done
