# arg 1: source file or directory
# arg 2: destination directory (where it will be put)
# varargs: TEMPLATEVAR=VALUE
bashtemplate_apply() {
    local sourcefile=
    local destination=
    local variables=()
    while [[ "$#" -gt 0 ]]; do
        if [[ -z "$sourcefile" ]]; then
            if [[ ! -e "$1" ]]; then
                echo "${FUNCNAME[0]}: Source file or directory does not exist: $1" >&2
                return 1
            fi
            sourcefile="$1"
            shift
            continue
        fi
        if [[ -z "$destination" ]]; then
            if [[ ! -d "$1" ]]; then
                echo "${FUNCNAME[0]}: Destination directory does not exist: $1" >&2
                return 1
            fi
            destination="$1"
            shift
            continue
        fi
        if [[ "$1" =~ ^([a-zA-Z_][0-9a-zA-Z_]*)=(.*)$ ]]; then
            variables+=("${BASH_REMATCH[1]}=${BASH_REMATCH[2]}")
            shift
            continue
        fi
        echo "${FUNCNAME[0]}: Unknown argument: >$1<" >&2
        return 1
    done

    # copy files and replace their contents
    if [[ -d "$sourcefile" ]]; then
        local destination_file="$destination/${sourcefile##*/}"
        cp -rf "$sourcefile" "$destination_file"
        bashtemplate_substitute_content "$destination_file" "${variables[@]}"
        bashtemplate_substitute_filenames "$destination_file" "${variables[@]}"
    elif [[ -f "$sourcefile" ]]; then
        local destination_file="$destination/${sourcefile##*/}"
        cp -f "$sourcefile" "$destination_file"
        bashtemplate_substitute_content "$destination_file" "${variables[@]}"
        bashtemplate_substitute_filenames "$destination_file" "${variables[@]}"
    else
        echo "${FUNCNAME[0]}: Source file or directory does not exist: $sourcefile" >&2
        return 1
    fi

    # replace the variable names in the NAMES of the copied files

    local file_and_directory_names=()
    while IFS= read -r -d '' file; do
        file_and_directory_names+=("$file")
    done < <(find "$destination" -print0)
    
        # for variable in "${variables[@]}"; do
        #     local varname="${variable%%=*}"
        #     local varvalue="${variable#*=}"
        # done


}
bashtemplate_substitute_content() {
    local filepath="$1"
    local variables=("${@:2}")
    if [[ -d "$filepath" ]]; then
        local files=()
        while IFS= read -r -d '' file; do
            files+=("$file")
        done < <(find "$filepath" -type f -print0)
        for file in "${files[@]}"; do
            bashtemplate_substitute_content "$file" "${variables[@]}"
        done
    else
        bashtemplate_substitute_content_file "$filepath" "${variables[@]}"
    fi
}
bashtemplate_substitute_content_file() {
    local file="$1"
    local variables=("${@:2}")
    local content="$(<"$file")"
    for variable in "${variables[@]}"; do
        local varname="${variable%%=*}"
        local varvalue="${variable#*=}"
        content="${content//@$varname@/$varvalue}"
    done
    echo "$content" > "$file"
}
bashtemplate_substitute_filenames() {
    local file="$1"
    local variables=("${@:2}")
    # if [[ -d "$file" ]]; then
    #     while IFS= read -r -d '' subdir; do
    #         subdirs+=("$subdir")
    #     done < <(find "$file" -type d -maxdepth 1 -mindepth 1 -print0)
    # fi
    # for subdir in "${subdirs[@]}"; do
    #     bashtemplate_substitute_filenames_dir "$subdir" "${variables[@]}"
    # done

    local subfiles=()
    if [[ -d "$file" ]]; then
        while IFS= read -r -d '' subfile; do
            subfiles+=("$subfile")
        done < <(find "$file" -maxdepth 1 -mindepth 1 -print0)
    fi
    for subfile in "${subfiles[@]}"; do
        bashtemplate_substitute_filenames "$subfile" "${variables[@]}"
    done
    bashtemplate_substitute_move_file "$file" "${variables[@]}"
}

bashtemplate_substitute_move_file() {
    local file="$1"
    # if the file is a basic name without path slashes:
    if [[ "$file" =~ ^[^/]*$ ]]; then
        file="./$file"
    fi
    local variables=("${@:2}")
    local filename_new="${file##*/}"
    for variable in "${variables[@]}"; do
        local varname="${variable%%=*}"
        local varvalue="${variable#*=}"
        filename_new="${filename_new//@$varname@/$varvalue}"
    done
    if [[ "$filename_new" = "" ]]; then
        echo "${FUNCNAME[0]}: Filename is empty after substitution: $file" >&2
        return 99;
    fi
    local path_new="${file%/*}/$filename_new"
    if [[ "$(readlink -f "$file")" == "$(readlink -f "$path_new")" ]]; then
        # no need to move
        return 0
    else
        mv "$file" "$path_new"
    fi
}


