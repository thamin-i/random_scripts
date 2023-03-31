#!/usr/bin/env bash

BASE_URL="https://source.unsplash.com/random"
IMAGE_SIZE="1080x1920"
IMAGE_FILE="/tmp/unsplash.jpg"
SLEEP_SECONDS=30

function display_help() {
    echo "$(basename "$0") [OPTION]...
Fetch random image from unslpash API, convert it to ASCII-art and display it for a fixed period of time.

Oprions:
    --help             show this help text
    --image-size       Set the downloaded image size (Default: '1080x1920')
    --image-file       Set the downloaded image file name (Default: '/tmp/unsplash.jpg')
    --sleep-seconds    Set the sleep time in seconds (Default: '30')

Examples:
  $(basename "$0") --help
  $(basename "$0") --image-file /tmp/unsplash.jpg --image-size 1920x1080 --sleep-seconds 10
"
}

function main_loop() {
    while true; do
        SECONDS=0
        curl -Sso "${IMAGE_FILE}" -L "${BASE_URL}/${IMAGE_SIZE}" >/dev/null
        OUTPUT="$(jp2a --colors -z --fill "${IMAGE_FILE}")"
        clear
        <<< "${OUTPUT}" cat
        sleep "$(("${SLEEP_SECONDS}-${SECONDS}"))"
    done
}

while [[ $# -gt 0 ]]; do
    case $1 in
    --image-size)
        IMAGE_SIZE="${2}"
        shift
        shift
        ;;
    --image-file)
        IMAGE_FILE="${2}"
        shift
        shift
        ;;
    --sleep-seconds)
        SLEEP_SECONDS="${2}"
        shift
        shift
        ;;
    --help)
        display_help
        exit 0
        ;;
    *)
        echo "Unknown parameter ${1}"
        exit 1
        ;;
    esac
done

main_loop

exit 0
