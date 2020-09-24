_setup() {
    clear
    tput civis
}

_abort() {
    tput cnorm
    exit $status_code
}

_display_help() {
    printf "This script executes an ordered list of command in the background and display a progress bar during the execution\n"
    printf "USAGE:\n"
    printf "\tbash ${name} [progress_bar_size] [tasks]\n"
    printf "EXAMPLE:"
    printf "\n\tbash ${name} 100 'sleep 1' 'sleep 2' 'exit 1' 'sleep3'\n"
    printf "PARAMETERS:\n"
    printf "\t[progress_bar_size]\tSize of the displayed progress bar (cannot be 0)\n"
    printf "\t[tasks]\t\tCommands to run in the background\n"
}

_display_progress_bar() {
    percentage=$(bc <<<"scale=2; (${current_task}/${tasks_number})*100")
    progress=${percentage%%.*}
    progress_bar="\r["
    for (( i=1; i<=$progress_bar_size; i++ )); do
        if ((progress / (100 / $progress_bar_size) >= i)); then
            progress_bar+="${color}#\e[0m"
        else
            progress_bar+="."
        fi
    done
    progress_bar+="] [${current_task}/${tasks_number}]"
    printf "\033[2;1f$progress_bar"
}

_exec_in_background() {
    _display_progress_bar
    printf "\033[1;1fCurrent task is: \e[1m'${task}'\e[0m"
    SECONDS=0
    eval $task > /dev/null 2>&1 &
    pid=$!
    trap "kill $pid 2> /dev/null" EXIT
    while kill -0 $pid 2>/dev/null; do
        sleep 1
    done
    trap - EXIT
    wait $pid
    status_code=$?
    if [[ "${status_code}" != "0" ]]; then
        color="\e[31m"
    fi
    current_task=$((current_task + 1))
    _display_progress_bar
}

current_task=0
color="\e[32m"
name="${0}"
progress_bar_size="${1}"
shift
tasks=( "${@}" )
tasks_number="${#tasks[@]}"

if [ -z "${progress_bar_size}" ] || ((progress_bar_size == 0)) || ((tasks_number == 0)); then
    _display_help
    exit 1
fi

_setup

for task in "${tasks[@]}"; do
    _exec_in_background
    if [[ "${status_code}" != "0" ]]; then
        _abort
    fi
done

_abort
