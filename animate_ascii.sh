_display_help() {
    printf "This script animates an ascii art that traverse the terminal from top to bottom\n"
    printf "USAGE:\n"
    printf "\tbash ${script_name} [name]\n"
    printf "EXAMPLE:"
    printf "\n\tbash ${script_name} 'asciiArts'\n"
    printf "PARAMETERS:\n"
    printf "\t[name]\t\tFile or directory containing the ascii art(s)\n"
}

_get_width() {
    w=0
    for ((i = 0; i < ${#img[@]}; i++)); do
        if ((${#img[$i]} > $w)); then
            w=${#img[$i]}
        fi
    done
    echo $w
}

_get_height() {
    h=${#img[@]}
    echo $h
}

_check_img_size() {
    if (($width >= $columns)); then
        printf "ascii art is too wide for this tertminal ($width >= $columns)\n"
        exit 1
    fi
    if (($height >= $rows)); then
        printf "ascii art is too high for this tertminal ($height >= $rows)\n"
        exit 1
    fi
}

_display_img() {
    clear
    for ((line = 0 - ${#img[@]}; line < $rows; line++)); do
        pos_y=$line
        if ((${pos_y} - 1 > 0)) && ((${pos_y} - 1 < $rows)); then
            string="\033[$((pos_y - 1));1f"
            for ((j = 0; j < $columns; j++)); do
                string+=" "
            done
            printf "${string}"
        fi
        for ((i = 0; i < ${#img[@]}; i++)); do
            if ((${pos_y} > 0)) && ((${pos_y} < $rows)); then
                string="\033[${pos_y};1f\r"
                for ((j = 0; j < $padding; j++)); do
                    string+=" "
                done
                string+="${img[$i]}"
                for ((j = 0; j < $padding; j++)); do
                    string+=" "
                done
                printf "${string}"
            fi
            pos_y=$((pos_y + 1))
        done
        sleep 0.2
    done
    clear
}

script_name=$0
input=$1
columns=$(tput cols)
rows=$(tput lines)
files=()

if [[ -d $input ]]; then
    for entry in "$input/"*; do
        files+=("${entry}")
    done
elif [[ -f $input ]]; then
    files+=("${input}")
fi
if ((${#files[@]} < 1)); then
    _display_help
    exit 1
fi
for file in "${files[@]}"; do
    readarray -t img <${file}
    width=$(_get_width)
    height=$(_get_height)
    _check_img_size
    padding=$((($columns - $width) / 2))
    _display_img
done
