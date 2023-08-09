    command! -bar -nargs=1 AddRcVim  call AddRcVim(<q-args>, 0)
    command! -bar -nargs=1 AddRcGvim call AddRcGvim(<q-args>, 0)
    command! -bar -nargs=1 AddRcLayer  call AddRcLayer(<q-args>, 0)

    command! -bar -nargs=+ AddIDEDir  call AddIDEDir(<f-args>)

    command! -nargs=1 -bar PathAddPP call PathAddPP(<f-args>)
    command! -nargs=1 -bar PathAddRTP call PathAddRTP(<f-args>)
    command! -nargs=1 -bar PathAddAfterPP call PathAddAfterPP(<f-args>)
    command! -nargs=1 -bar PathAddAfterRTP call PathAddAfterRTP(<f-args>)
    command! -nargs=1 -bar Src execute printf("source %s", _cmdPath(<f-args>))
    command! -bang -nargs=1 ReadPathE echon join(['# '.<q-args>] + split(eval(<f-args>), ","), "\n")."\n"
    command! -bang -nargs=1 ReadPath call append(line('.'), ['# '.<q-args>] + split(eval(<f-args>), ","))

if $VIMS_PRINT_DBG ==# "1"
    if has('nvim')
        let s:log_debug = "/tmp/nvim_dbg_initial.txt"
    else
        let s:log_debug = "/tmp/vim_dbg_initial.txt"
    endif
    call writefile([&rtp, &packpath], s:log_debug)
endif


    fun! VimFlavor() abort
        if has("nvim")
            return "nvim"
        else
            return "vim"
        endif
    endfun


    fun! AddIDEDir(dir, projectname) abort
        call AddRcLayer(a:dir . "/layer", 1)
        call AddRcVim(a:dir . "/vimrc", 0)
        call AddRcGvim(a:dir . "/gvimrc", 1)
    endfun

    fun! AddRcVim(rcfile, optional) abort
        call add(g:vimruntime.stock_vim_init.vimrc_spec.rc, a:rcfile)
    endfun
    fun! AddRcGvim(rcfile, optional) abort
        call add(g:vimruntime.stock_vim_init.gvimrc_spec.rc, a:rcfile)
    endfun
    fun! AddRcLayer(dir, optional) abort
        call AddRcVim(a:dir . "/" . "shared" . "/vimrc", a:optional)
        call AddRcGvim(a:dir . "/" . "shared" . "/gvimrc", 1)
        call AddRcVim(a:dir . "/" . VimFlavor() . "/vimrc", a:optional)
        call AddRcGvim(a:dir . "/" . VimFlavor() . "/gvimrc", 1)
        call PathAddPP(a:dir . "/" . "shared")
        call PathAddPP(a:dir . "/" . VimFlavor())
        call PathAddAfterRTP(a:dir . "/shared")
        call PathAddPP(a:dir . "/" . VimFlavor())
        call PathAddAfterRTP(a:dir . "/" . "shared" . "/after")
        call PathAddAfterRTP(a:dir . "/" . VimFlavor() . "/after")
    endfun

    fun! PathAddPP(arg) abort
        call add(g:vimruntime.stock_vim_init.prependPPList, a:arg)
    endfun
    fun! PathAddRTP(arg) abort
        call add(g:vimruntime.stock_vim_init.prependRTPList, a:arg)
    endfun
    fun! PathAddAfterPP(arg) abort
        call add(g:vimruntime.stock_vim_init.appendPPList, a:arg)
    endfun
    fun! PathAddAfterRTP(arg) abort
        call add(g:vimruntime.stock_vim_init.appendRTPList, a:arg)
    endfun


    " fun! _AdaptToBuildInSourcetree() abort
	    " " detect if vim is used just after "configure; make" and change runtimepath accordingly
	    " if ! empty(glob(g:_vim_instance.probable_source_rtdir))
		" echom "found vim source runtime to be more precise: " . g:_vim_instance.probable_source_rtdir
		" let $VIMRUNTIME=g:_vim_instance.probable_source_rtdir
		" let $VIM=g:_vim_instance.probable_source_vimdir
		" " echom "rtp orig:" . &rtp
		" let &runtimepath = substitute(&runtimepath, '\V'.escape(g:_vim_instance.orig_VIMRUNTIME, '\'), g:_vim_instance.probable_source_rtdir, 'g')
		" let &runtimepath = substitute(&runtimepath, '\V'.escape(g:_vim_instance.orig_VIM, '\'), g:_vim_instance.probable_source_vimdir, 'g')
		" let &packpath = substitute(&packpath, '\V'.escape(g:_vim_instance.orig_VIMRUNTIME, '\'), g:_vim_instance.probable_source_rtdir, 'g')
		" let &packpath = substitute(&packpath, '\V'.escape(g:_vim_instance.orig_VIM, '\'), g:_vim_instance.probable_source_vimdir, 'g')
		" let &helpfile = substitute(&helpfile, '\V'.escape(g:_vim_instance.orig_VIMRUNTIME, '\'), g:_vim_instance.probable_source_rtdir, 'g')
		" let &helpfile = substitute(&helpfile, '\V'.escape(g:_vim_instance.orig_VIM, '\'), g:_vim_instance.probable_source_vimdir, 'g')
		" " echom "rtp afte:" . &rtp
	    " endif
    " endf

    fun! _path_rel_to(base, rel) abort
        return trim(system(printf("readlink -f %s", shellescape(a:base."/".a:rel))))
    endf

    fun! _cmdPath(...) abort
        let args=[]
        for a in a:000
            if match(a, '^[s]:') > -1
                throw "script-level variables are not supported in _cmdPath commands"
            elseif match(a, '^[glab]:') > -1
                call add(args, eval(a))
            else
                call add(args, a)
            endif
        endfor
        return join(args, "/")
    endf

    fun! _PathSettingPrepend(setting, part) abort
        " echom printf("DBG: _PathSettingPrepend('%s', '%s')", string(a:setting), string(a:part))
        if a:setting ==# "runtimepath" || a:setting ==# "rtp"
		let oldsetting = &runtimepath
		let &runtimepath=a:part.",".oldsetting
	elseif a:setting ==# "packpath" || a:setting ==# "pp"
		let oldsetting = &packpath
		let &packpath=a:part.",".oldsetting
	else
		echoe "unknown setting: ".a:setting
        endif
    endf

    fun! _KeepPathPart(part, pathname) abort
        let p = expand(a:part)
        let matchesHOMEVIM = 0
        if has("nvim")
            let tomatchHOMEVIM = fnamemodify(expand("$HOME")."/.config/nvim", ':p:h')
        else
            let tomatchHOMEVIM = fnamemodify(expand("$HOME")."/.vim", ':p:h')
        endif
        let tomatchVIMRUNTIME = fnamemodify(expand("$VIMRUNTIME"), ':p:h:h')
        let exists=0
        " echom "looking if ".p." matches ".tomatchHOMEVIM
        if stridx(p, tomatchHOMEVIM) == 0
            let matchesHOMEVIM=1
            " echom "matched HOMEVIM!"
        endif
        " echom "looking if ".p." matches ".tomatchVIMRUNTIME
        if isdirectory(p)
            let exists = 1
            " echom "exists!"
        endif
        " if ! matchesHOMEVIM && exists

        if ! matchesHOMEVIM
            return 1
        else
            return 0
        endif
    endf

    fun! _VimRuntimeLog(msg, ...) abort "{{{
        " optional parameter: 1 if is fatal -- then quit
        call writefile([a:msg], vimruntime.logfile, 'a')
        if a:0 > 0 && a:1 == 1
            echoerr a:msg
            q!
        endif
    endf

if ! exists('g:_vim_instance')
    let g:_vim_instance={}
    let g:_vim_instance.cmd = v:argv[0]
    if g:_vim_instance.cmd[0] != '/'
        let g:_vim_instance.executable = resolve(systemlist("which ".g:_vim_instance.cmd)[0])
    else
        let g:_vim_instance.executable = resolve(g:_vim_instance.cmd)
    endif
    let g:_vim_instance.probable_source_vimdir = fnamemodify(g:_vim_instance.executable, ":p:h")."/.."
    let g:_vim_instance.probable_source_rtdir  = g:_vim_instance.probable_source_vimdir . "/runtime"
    let g:_vim_instance.orig_VIMRUNTIME = $VIMRUNTIME
    let g:_vim_instance.orig_VIM = $VIM
    " echom "DBG: checking if nvim... " . has('nvim')
    " if has('nvim')
    "     echom "DBG: checking: isdir: " . ($VIMRUNTIME . "/runtime") . ": " . isdirectory($VIMRUNTIME . "/runtime")
    "     if isdirectory($VIMRUNTIME . "/runtime")
    "         let $VIMRUNTIME=$VIMRUNTIME . "/runtime"
    "         echom "setting VIMRUNTIME to " . $VIMRUNTIME . "as a bugfix."
    "         let runtimepathelements = split(&runtimepath, ',')
    "         let newruntimepathelements = []
    "         for rtp in runtimepathelements
    "             if rtp ==# g:_vim_instance.orig_VIMRUNTIME
    "                 let rtp_new = $VIMRUNTIME
    "             else
    "                 let rtp_new = rtp
    "             endif
    "         endfor
    "         let &runtimepath = join(newruntimepathelements, ',')
    "     endif
    " endif

    " call _AdaptToBuildInSourcetree()

    let g:vimruntime={}
    let g:vimruntime.logfile = expand('<sfile>:p:h') . '/vimruntime.log'
    let g:vimruntime.stock_vim_init={}
    let g:vimruntime.stock_vim_init.scriptfile = expand('<sfile>:p')

    " These are records of the original paths
    let g:vimruntime.stock_vim_init.origRTP = &runtimepath
    let g:vimruntime.stock_vim_init.origPP = &packpath
    " These are for vimrc/gvimrc sourcing
    let g:vimruntime.stock_vim_init.vimrc_spec = {}
    let g:vimruntime.stock_vim_init.vimrc_spec.rc = []
    let g:vimruntime.stock_vim_init.vimrc_spec.rc_is_optional = []
    let g:vimruntime.stock_vim_init.gvimrc_spec = {}
    let g:vimruntime.stock_vim_init.gvimrc_spec.rc = []
    " These are for rewriting the stock RTP
    let g:vimruntime.stock_vim_init.newRTPList = []
    let g:vimruntime.stock_vim_init.newPPList = []
    let g:vimruntime.stock_vim_init.appendRTPList = []
    let g:vimruntime.stock_vim_init.prependRTPList = []
    let g:vimruntime.stock_vim_init.appendPPList = []
    let g:vimruntime.stock_vim_init.prependPPList = []

    for p in split(g:vimruntime.stock_vim_init.origRTP, ",")
        " echom "checking ".p." for inclusion in ".g:_vim_instance.probable_source_rtdir
        if _KeepPathPart(p, 'runtimepath')
            call add(g:vimruntime.stock_vim_init.newRTPList, p)
        else
        endif
    endfor
    for p in split(g:vimruntime.stock_vim_init.origPP, ",")
        if _KeepPathPart(p, 'packpath')
            call add(g:vimruntime.stock_vim_init.newPPList, p)
        endif
    endfor

endif

