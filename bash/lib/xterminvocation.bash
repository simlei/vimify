# arg 1: filename
# arg 2: content
xterminvocation_put_temp() {
    local filename="$1"
    for line in "${@:2}"; do
        echo "$line" >> "$filename"
    done
    chmod +x "$filename"
}


xterminvocation_make_lines() {
    local lines=()
    lines+=("#!/usr/bin/env bash")
    lines+=("set -euo pipefail")
    while [[ $# -gt 0 ]]; do
        lines+=("$1")
        shift
    done
    rv_arr=( "${lines[@]}" )
}
xterminvocation() {
    local tempfile="$(mktemp -u)"
    declare -a rv_arr=()
    declare quoted="${@@Q}"
    xterminvocation_make_lines "${quoted[@]}"
    declare -a lines=( "${rv_arr[@]}" )
    xterminvocation_put_temp "$tempfile" "${lines[@]}"
    echo xterm -e "$tempfile"
    xterm "$tempfile"
}

# xterminvocation_lines() {
#     local tempfile="$(mktemp -u)"
#     declare -a rv_arr=()
#     xterminvocation_make_lines "$@"
#     declare -a lines=( "${rv_arr[@]}" )
#     xterminvocation_put_temp "$tempfile" "${lines[@]}"
#     echo xterm -e "$tempfile"

#     retvaltemp="$(mktemp -u)"
#     xterm "$tempfile "' || { echo $? > '"$retvaltemp"'; }'
#     if [[  ]]; then
#     fi
# }
