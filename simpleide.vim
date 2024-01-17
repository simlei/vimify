fun! _SetupIDEProjectVars() abort
    " if ! exists('g:project')
        let g:project = {}
        let g:project.loc = {}
        let g:project.vim = {}
        let g:project.vim.loc = {}
        let g:project.vim.dispatch = {}
    " endif
endf
fun! _SetupIDEProjectFromProjectRCAndRoot(project_rc, root) abort
    let shared_rc_abs = fnamemodify(a:project_rc, ":p")
    return _SetupIDEProject(
                \shared_rc_abs, 
                \0,
                \fnamemodify(shared_rc_abs, ":h"),
                \fnamemodify(shared_rc_abs, ":h:h"),
                \a:root
                \)
endfun

fun! IDELayerHere(project_rc, project_root) abort
    let shared_rc_abs = fnamemodify(a:project_rc, ":p")
    let ide_def_rc = fnamemodify(a:project_rc, ":p")
    let ide_layer_dir = fnamemodify(a:project_rc, ":p:h")
    return _SetupIDEProject(
                \ide_def_rc, 
                \ide_layer_dir,
                \ide_layer_dir,
                \ide_layer_dir,
                \a:project_root
                \)
endfun

fun! _SetupIDEProjectFromProjectRC(project_rc) abort
    let shared_rc_abs = fnamemodify(a:project_rc, ":p")
    return _SetupIDEProject(
                \shared_rc_abs, 
                \fnamemodify(shared_rc_abs, ":h") . "/layer",
                \fnamemodify(shared_rc_abs, ":h:h"),
                \fnamemodify(shared_rc_abs, ":h:h:h"),
                \fnamemodify(shared_rc_abs, ":h:h:h:h")
                \)
endfun
fun! _SetupIDEProject(
            \proj_rc,
            \proj_layer_d,
            \proj_vim_d,
            \proj_def_d,
            \proj_root_d
            \) abort

    call _SetupIDEProjectVars()

    let g:project.loc.Droot = a:proj_root_d
    let g:project.loc.Dprojdef = a:proj_def_d
    let g:project.loc.Dide = a:proj_vim_d

    " e.g. the dispatch file is something for the shell, too
    let g:project.vim.loc.Fdispatches = g:project.loc.Dide . "/dispatches.bash"

    let g:project.vim.loc.Droot = g:project.loc.Dide
    let g:project.vim.loc.Dsessions = g:project.vim.loc.Droot . "/" . "sessions"
    let g:project.vim.loc.Dregs = g:project.vim.loc.Droot . "/" . "regs"
    let g:project.vim.loc.F_rc = a:proj_rc

    " plugins are so common to configure that they are pulled in to main NS
    let g:project.vim.dispatch.Flist = g:project.vim.loc.Fdispatches

    let g:project.name = "#UNSET#"
    if ! exists("g:_simpleide_projname")
        let g:_simpleide_projname = "#UNSET#"
    endif

    if g:_simpleide_projname !=# "#UNSET#"
        let g:project.name = g:_simpleide_projname
    endif

    silent! call mkdir(g:project.vim.loc.Dsessions, "p")

    call _PerformProjectSettings()

    nmap <F10>S :source <C-r>=g:project.vim.loc.Dsessions<CR>/session_
    nmap <F10>s :Obsession! <C-r>=g:project.vim.loc.Dsessions<CR>/session_

    exec printf("cd %s", fnameescape(g:project.loc.Droot))

    nmap <F10>rcpe :e <C-r>=g:project.vim.loc.F_rc<CR><CR>

    " Debug
    nmap <F10>rcpP o<C-r>=string(g:project)<CR><Esc>:.s/'/"/g<CR>:.!python -mjson.tool<CR>

endf

fun! _PerformProjectSettings() abort
    let g:_dispatch_listfile = g:project.vim.dispatch.Flist
    let g:_regfiles_dir = g:project.vim.loc.Dregs
endf

command! -nargs=1 ShortcutExt call _shortcutExt(<f-args>)
fun! _shortcutExt(key) abort
    call feedkeys("\<plug>(ext)".a:key, "i")
endf

" fun! _project_currentproject_selection() abort
"     let selection = readfile($project__currentproject__Droot . "/lastselection.txt")
"     return selection
" endfun
" command! -nargs=+ GetExtSel call _project_currentproject_selection_reg(<f-args>)
" fun! _project_currentproject_selection_reg(regname, ...) abort
"     let mode=get(a:, 1, "V")
"     let sel = _project_currentproject_selection()
"     call filter(sel, {i,x -> ! empty(trim(x))})
"     if len(sel) == 0
"         call setreg(a:regname, "", mode)
"     elseif len(sel) == 1
"         call setreg(a:regname, sel[0], mode)
"     else
"         call setreg(a:regname, sel, mode)
"     endif
" endfun



" fun! _project_register_as_vimide() abort
"     if ! exists("v:servername") || empty(v:servername)
"         if g:project.name ==# "#UNSET#"
"             let servername = "ADHOC"
"         else
"             let servername = g:project.name
"         endif
"         call remote_startserver(servername)
"     endif
"     call system("currentproject_vimide_setservername " . v:servername)
" endfun
