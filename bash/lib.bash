_declare_dirvar() { local _dir="$(readlink -f "${BASH_SOURCE[0]}")"; _dir="${_dir%/*}"; local varname="${1:-dir}"; local count="${2:-1}"; while [[ "$count" -gt 0 ]]; do _dir="${_dir%/*}"; let count-- || :; done; eval "$varname"'="$_dir"'; }

_declare_dirvar __vims_bash_libroot 0
__vims_bash_libdir="$__vims_bash_libroot/lib"

for __vims_bash_lib in "$__vims_bash_libdir"/*.bash; do
    source "$__vims_bash_lib"
done
