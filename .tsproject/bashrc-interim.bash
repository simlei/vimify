_declare_dirvar() { local _dir="${BASH_SOURCE[0]}"; _dir="${_dir%/*}"; local varname="${1:-dir}"; local count="${2:-1}"; while [[ "$count" -gt 0 ]]; do _dir="${_dir%/*}"; let count-- || :; done; eval "$varname"'="$_dir"'; }

_declare_dirvar project__vims__Droot 1

export project__vims__Dprojroot="$project__vims__Droot/.tsproject"
export project__vims__Droot

source "$project__vims__Droot/bash/lib.bash"

vims_ide() {
    "$project__vims__Dprojroot/bin/vims_ide" "$@"
}
