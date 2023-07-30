if ! exists("g:vimruntime.ignore_further_bootstrapping") || g:vimruntime.ignore_further_bootstrapping != 1
    let g:vimruntime.ignore_further_bootstrapping = 1
    if expand("$VIMINIT") !=# '$VIMINIT'
        unlet $VIMINIT
    endif
    " vimruntime.bootstrap.vimrc | setup variable scopes / bootstrap{{{
    if ! exists("vimruntime")
        call _VimRuntimeLog("vimruntime dictionary not found; it seems stock_vim_init.vim was not loaded", 1)
    endif
    if ! exists("vimruntime.bootstrap")
        let vimruntime.bootstrap = {}
    endif
    if ! exists("vimruntime.bootstrap.vimrc")
        let vimruntime.bootstrap.vimrc = {}
    endif

    let vimruntime.bootstrap.dir = expand('<sfile>:p:h')
    let vimruntime.bootstrap.vimrc.scriptfile = expand('<sfile>:p')
    let vimruntime.bootstrap.vimrc.optutils = fnamemodify(vimruntime.bootstrap.vimrc.scriptfile, ':p:h')."/opt/bootstrap_vimrc_utils.vim"
    "}}}
    " source optional utils from .../opt/{{{
    if filereadable(vimruntime.bootstrap.vimrc.optutils)
        exec printf('source %s', vimruntime.bootstrap.vimrc.optutils)
    endif
    "}}}

    let vimruntime.bootstrap.vimrc.sourced = []
    let vimruntime.bootstrap.vimrc.sourced_lastrun = []

    "sourcing definitions in function and command, execution for first time
    "TODO: should this function declare 'abort'?
    fun! _SourceAllVimrc()
        let g:vimruntime.bootstrap.vimrc.sourced_lastrun = []
        " try
        for rcfile in g:vimruntime.stock_vim_init.vimrc_spec.rc
            execute printf("source %s", rcfile)
            call add(g:vimruntime.bootstrap.vimrc.sourced, rcfile)
            call add(g:vimruntime.bootstrap.vimrc.sourced_lastrun, rcfile)
        endfor
        " finally
            " let wrapupRcfile = g:vimruntime.bootstrap.dir . "/wrapup/wrapup.vim"
            " execute printf("source %s", wrapupRcfile)
            " call add(g:vimruntime.bootstrap.vimrc.sourced, wrapupRcfile)
            " call add(g:vimruntime.bootstrap.vimrc.sourced_lastrun, wrapupRcfile)
        " endtry
    endf

    " Set it off...
    let $MYVIMRC=expand("<sfile>:p")
    fun! _calcRuntimepath()
        let recalculatedParts = g:vimruntime.stock_vim_init.newRTPList
        let beforeParts = g:vimruntime.stock_vim_init.prependRTPList
        let afterParts = g:vimruntime.stock_vim_init.appendRTPList
        let &runtimepath = join(beforeParts+recalculatedParts+afterParts, ",")
    endfun
    fun! _calcPackpath()
        let recalculatedParts = g:vimruntime.stock_vim_init.newPPList
        let beforeParts = g:vimruntime.stock_vim_init.prependPPList
        let afterParts = g:vimruntime.stock_vim_init.appendPPList
        let &packpath = join(beforeParts+recalculatedParts+afterParts, ",")
    endfun

    call _calcRuntimepath()
        " echom "Runtimepath:" 
        " ReadPathE &runtimepath
    call _calcPackpath()
        " echom "Packpath:" 
        " ReadPathE &packpath
endif

call _SourceAllVimrc()
