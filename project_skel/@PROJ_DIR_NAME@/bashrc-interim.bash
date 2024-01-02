_declare_dirvar() { local _dir="${BASH_SOURCE[0]}"; _dir="${_dir%/*}"; local varname="${1:-dir}"; local count="${2:-1}"; while [[ "$count" -gt 0 ]]; do _dir="${_dir%/*}"; let count-- || :; done; eval "$varname"'="$_dir"'; }
_declare_dirvar _projdefdir 0
_declare_dirvar _projbasedir 1

_declare_dirvar project__@PROJ_NAME@__Droot 1
export project__@PROJ_NAME@__Dprojroot="$project__@PROJ_NAME@__Droot/@PROJ_DIR_NAME@"
export project__@PROJ_NAME@__Droot
export PATH="$project__@PROJ_NAME@__Dprojroot/bin:$PATH"
export PATH="$project__@PROJ_NAME@__Dprojroot/vim-bin:$PATH"
