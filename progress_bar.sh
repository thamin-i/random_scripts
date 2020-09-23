_display_help() {
    printf "This script runs a command in background and display a progress bar depending of the elapsed time\n"
    printf "USAGE:\n"
    printf "\tbash ${name} [progress_bar_size] [expected_duration] [command]\n"
    printf "EXAMPLE:"
    printf "\n\tbash ${name} 100 10 sleep 10\n"
    printf "PARAMETERS:\n"
    printf "\t[progress_bar_size]\tSize of the displayed progress bar (cannot be 0)\n"
    printf "\t[expected_duration]\tExpected command duration in seconds (cannot be 0)\n"
    printf "\t[command]\t\tCommand to run in background\n"
}

_display_progress_bar() {
    percentage=$(bc <<<"scale=2; (${SECONDS}/${expected_duration})*100")
    progress=${percentage%%.*}
    progress_bar="\r[\e[1m"
    if ((SECONDS > expected_duration)); then
        for (( i=1; i<=$progress_bar_size; i++ )); do
            progress_bar+="\e[31m#\e[0m"
        done
    else
        for (( i=1; i<=$progress_bar_size; i++ )); do
            if ((progress / (100 / $progress_bar_size) >= i)); then
                progress_bar+="\e[32m#\e[0m"
            else
                progress_bar+="."
            fi
        done
    fi
    progress_bar+="]"
    echo -ne "${progress_bar}"
}

_exec_in_background() {
    echo "Launching command '$command' in background"
    SECONDS=0
    eval $command > /dev/null 2>&1 &
    pid=$!
    trap "kill $pid 2> /dev/null" EXIT
    while kill -0 $pid 2>/dev/null; do
        _display_progress_bar
        sleep 0.5
    done
    trap - EXIT
    wait $pid
    status_code=$?
    _display_progress_bar
    printf "\nCommand '$command' exitied with status code: ${status_code}\n"
    return $status_code
}

name=$0
progress_bar_size=$1
expected_duration=$2
command=${@:3}

if [ -z "${progress_bar_size}" ] ||  [ -z "${expected_duration}" ] || [ -z "${command}" ] || ((expected_duration == 0)) || ((progress_bar_size == 0)); then
    _display_help
    exit 1
fi

_exec_in_background $command
