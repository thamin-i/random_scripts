#! /usr/bin/env bash

display_help() {
  printf "usage: rename.sh order_type <path>\n"
  printf "\n"
  printf "positional arguments:\n"
  printf "order_type\tSorting type to use, can be 'date' or 'size'\n"
  printf "\n"
  printf "optional arguments:\n"
  printf "path\t\tpath to the directory to use (default is ".")\n"
}

get_ordered_file_names_by_date() {
  # exclude directories with "| grep -v '^d'"
  ls -Slt | grep -v '^d' | while IFS= read -r string; do echo "$string" |
    awk -F':[0-9]* ' '/:/{print $2}'; done
}

get_ordered_file_names_by_size() {
  # exclude directories with "| grep -v '^d'"
  ls -Slh | grep -v '^d' | while IFS= read -r string; do echo "$string" |
    awk -F':[0-9]* ' '/:/{print $2}'; done
}

rename_ordered_file_names() {
  files=$1
  counter=0
  for old_file in $files; do
    new_file="$(printf "%02d\n" ${counter})-${old_file}"
    ((counter++))
    if test -f "$new_file"; then
      # New filename already exists in path, bypassing this one
      echo "$new_file already exists"
    else
      mv $old_file $new_file
    fi
  done
}

order_type=$1
path=$2

if [ -z "${order_type}" ]; then
  display_help
  exit 1
elif [ -z "${path}" ]; then
  path="."
fi

cd "$path" || exit 1

case "$order_type" in
"date")
  files=$(get_ordered_file_names_by_date)
  ;;
"size")
  files=$(get_ordered_file_names_by_size)
  ;;
*)
  display_help
  exit 1
  ;;
esac

rename_ordered_file_names "$files"
