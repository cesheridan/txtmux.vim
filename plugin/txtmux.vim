" ==============================================================================
"  txtmux.vim
" ==============================================================================
" Version:       1.1.0
" Author:        Charles E. Sheridan
" Script:        https://vim.sourceforge.io/scripts/index.php
" Documention:   https://raw.githubusercontent.com/cesheridan/txtmux.vim/master/README.md
" License:       GPL (Gnu Public License) version 3


" ==============================================================================
"  PLUGIN MGT
" ==============================================================================
let g:txtmux_version                        = '1.0.0'

if  !exists("g:impl_txtmux_is_in_dev_mode")
   let       g:impl_txtmux_is_in_dev_mode   = 'N'
endif

if  !exists("g:txtmux_reload_is_permitted")
   let       g:txtmux_reload_is_permitted   = 'N'
endif

if          (g:txtmux_reload_is_permitted  == 'N') 
\ && exists("g:impl_txtmux_is_loaded") 
\ &&        (g:impl_txtmux_is_in_dev_mode  == 'N')
  echomsg 
 \ 'txtmux.vim: EXITING from :source command, re-load not permitted.  '.
 \ 'To enable re-load, set g:txtmux_reload_is_permitted to "Y".' 

  finish
endif

if  (g:impl_textwins_is_loaded == 'N') 
  echomsg 'EXITING load of txtmux.vim: Required textwins.vim is not loaded'
  finish
endif

if  (g:tabwins_is_loaded  == 'N') 
  echomsg 
  echomsg 'EXITING load of txtmux.vim: Required tabwins.vim is not loaded'
  finish
endif

let g:meta_txtmux_version                        = '1.0.0'

" ==============================================================================
" CONFIGS - VIM-GLOBAL g: & SCRIPT-LOCAL s:
" ==============================================================================

" --- 'txtmuxD' menu

if !exists("g:load_txtmuxD_menu_is_wanted")
  let       g:load_txtmuxD_menu_is_wanted = 'Y'
endif

if !exists("g:txtmuxD_menu_number")
  let       g:txtmuxD_menu_number = 9996
endif


" //////////////////////////////////////////////////////////////////////////////
" PSEUDO-CONSTANTS
" //////////////////////////////////////////////////////////////////////////////
let s:SUCCESS                       =  1
let s:FAIL                          =  0
let s:NOT_A_BUFFER_NUMBER           = -1

" ==============================================================================
function! Convert_other_windows_to_termwins(rcvd_hash) 
" ==============================================================================
endfunction
" ==============================================================================
function! Convert_other_windows_to_editwins(rcvd_hash) 
" ==============================================================================
endfunction
" ==============================================================================
function! Muxter                (rcvd_hash) 
" ==============================================================================
" 'Muxt'  = Mux a text
" 'Muxter = Text muxer => Mux-texTer
  let                          l:rcvd_hash = extend ({ 
  \ 'string'                    : '',
  \ 'string_type'               : 'UNDEFINED',
  \ 'string_prefix'             : '',
  \ 'string_suffix'             : '',
  \                             
  \ 'termwin_buffer_numbers'    : [],
  \ 'editwin_window_ids'        : [],
  \ 'muxt_to_selfwin_is_wanted' : 'N',
  \                             
  \ 'append_cr_is_wanted'       : 'N',
  \ },
  \                   deepcopy(a:rcvd_hash,1)
\ ) 
  " NOTE-DOC: 'editwin_window_ids' not yet implemented.

  let l:rtrn_hash = { 
  \ 'return_code'               : s:FAIL,
\ }

  let l:returned = Build_textstring({
  \   'string'        : l:rcvd_hash['string'],
  \   'string_type'   : l:rcvd_hash['string_type'],
  \   'string_prefix' : l:rcvd_hash['string_prefix'],
  \   'string_suffix' : l:rcvd_hash['string_suffix'],
\ })
  if        l:returned['return_code'] == s:FAIL
     return l:rtrn_hash
  endif

  let l:window_id_at_function_entry = win_getid(winnr())

  if    len(l:rcvd_hash['termwin_buffer_numbers'])    >   0

    if      l:rcvd_hash['muxt_to_selfwin_is_wanted'] ==? 'N'
    " Delete current buffer from 'termwin_buffer_numbers'
      let  l:this_buffer_number = bufnr("%")
	    call filter(l:rcvd_hash['termwin_buffer_numbers'],
      \               'v:val != l:this_buffer_number')
    endif

    for  l:buffer_number in l:rcvd_hash['termwin_buffer_numbers']

        " NOTE-DOC-txtmux: if receiver terminal is in TERMINAL-Normal
        " mode, a 'clean' texting is guaranteed only for shell types
        " that support <C-U> delete of chars to left 
 
      if                                       term_getstatus (l:buffer_number) =~ 'normal'
      " If receiver termwin is in TERMINAL-Normal mode, 
      " pending term_sendkeys() WILL successfully send the 
      " keys to a bufffer in TERMINAL-Normal mode, HOWEVER
      " the keys will not be visible unless the terminal goes
      " into TERMINAL-Job mode, before or after the send.  
      " So, put the terminal into TERMINAL-Job mode and 
      " return to sendWin.

        call                               win_gotoid(bufwinid(l:buffer_number))
        " here, among the windows that contain this buffer,
        " it does not matter which of those windows that bufwinid() 
        " returns

        let                            l:buffer_name = bufname(l:buffer_number)
        let l:shell_type  = substitute(l:buffer_name, '^!', '', 'g')
        " per https://vi.stackexchange.com/questions/15251/how-to-know-the-shell-started-with-terminal
        " this does NOT account for scenario where user starts a different shell
        " in a subprocess after terminal has loaded.

        if count(['bash', 'zsh'], l:shell_type)
          "    vvvvvvvvvvvvvvvvvvvvvvvv
          call feedkeys("A\<C-U>", 'x')
          "    ^^^^^^^^^^^^^^^^^^^^^^^^
          " 'A' triggers TERMINAL-Job mode, & <C-U>, 
          " at least in bash & zsh, assures that the 'A'
          " (and any other chars to the left) are removed
          " before sending 'textstring'
          "
          " What is <C-U> equivalent  syntax in other shell types ?
          "
          " 'x' opt needed to assure that Vim does not 
          " run below return to prev window before the
          " key-feeding completes.
          wincmd p
        endif
      endif

      if     l:rcvd_hash['append_cr_is_wanted'] ==?   'Y'
         let l:returned['textstring']          .= "\<CR>"
      endif

      "    vvvvvvvvvvvvv
      call term_sendkeys(l:buffer_number, l:returned['textstring'])
      "    ^^^^^^^^^^^^^
    endfor
    " term_sendkeys() does NOT move vim to its target buffer (window),
    " so 'return2sender' is not a consideration -- execution did not
    " leave the invoking window.

   call win_gotoid(l:window_id_at_function_entry)
 endif
endfunction

" ==============================================================================
" MUXT @0 YANK-REGISTER & @v REGISTER: COMMANDS & MAPS
" ==============================================================================

" ------------------------------------------------------------------------------
" --- :Muxt{2Windows}   Muxt Copied Text 

" 2Termwins
command! -count=0 -nargs=* Muxt2Termwins  :call Muxter({
\ 'string'                      : @0,
\ 'termwin_buffer_numbers'      : Termwin_buffer_numbers_this_tab(),
\})

nnoremap <silent> mtt :<C-U>          call Muxter({ 
\ 'string'                      : @0,
\ 'termwin_buffer_numbers'      : Termwin_buffer_numbers_this_tab(),
\})<CR>
vnoremap <silent> mtt "vy:<C-U>          call Muxter({ 
\ 'string'                      : @v,
\ 'termwin_buffer_numbers'      : Termwin_buffer_numbers_this_tab(),
\})<CR>
" MNEMONICS: m:Muxt, f:, tt:Termwin

" ------------------------------------------------------------------------------
" --- :Muxtll{2Windows}    Muxt & `ll` Copied Text
"                  ^^

" 2Termwins
command! -count=0 -nargs=* Muxtll2Termwins  :call Muxter({
\ 'string_prefix'          : 'll ',
\ 'string'                 : @0,
\ 'append_cr_is_wanted'    : 'Y',
\ 'termwin_buffer_numbers' : Termwin_buffer_numbers_this_tab(),
\})

nnoremap <silent> mll :<C-U>          call Muxter({ 
\ 'string_prefix'          : 'll ',
\ 'string'                      : @0,
\ 'append_cr_is_wanted'    : 'Y',
\ 'termwin_buffer_numbers' : Termwin_buffer_numbers_this_tab(),
\})<CR>
vnoremap <silent> mll "vy:<C-U>          call Muxter({ 
\ 'string_prefix'          : 'll ',
\ 'string'                      : @v,
\ 'append_cr_is_wanted'    : 'Y',
\ 'termwin_buffer_numbers' : Termwin_buffer_numbers_this_tab(),
\})<CR>
"MNEMONICS: m:Muxt,  ll:`ll`

" ------------------------------------------------------------------------------
" --- :MuxtSource{2Windows}  `source` Copied Text
"                  ^^^^^^

" 2Termwins
command! -count=0 -nargs=* MuxtSource2RefTermwin  :call Muxter({
\ 'string'              : @0,
\ 'string_prefix'       : 'source ',
\ 'append_cr_is_wanted' : 'Y',
\ 'termwin_buffer_numbers' : Termwin_buffer_numbers_this_tab(),
\})

nnoremap <silent> mso :<C-U>          call Muxter({ 
\ 'string'              : @0,
\ 'string_prefix'       : 'source ',
\ 'append_cr_is_wanted' : 'Y',
\ 'termwin_buffer_numbers' : Termwin_buffer_numbers_this_tab(),
\})<CR>
vnoremap <silent> mso "vy:<C-U>          call Muxter({ 
\ 'string'                      : @v,
\ 'string_prefix'       : 'source ',
\ 'append_cr_is_wanted' : 'Y',
\ 'termwin_buffer_numbers' : Termwin_buffer_numbers_this_tab(),
\})<CR>
"MNEMONICS: m:Muxt, so:SOurce

" ------------------------------------------------------------------------------
" --- :MuxtRun{2Windows}  `run` Copied Text
"                  ^^^

" 2Termwins
command! -count=0 -nargs=* MuxtRun2RefTermwin  :call Muxter({
\ 'string'                      : @0,
\ 'append_cr_is_wanted' : 'Y',
\ 'termwin_buffer_numbers' : Termwin_buffer_numbers_this_tab(),
\})

nnoremap <silent> mru :<C-U>          call Muxter({ 
\ 'string'                      : @0,
\ 'append_cr_is_wanted' : 'Y',
\ 'termwin_buffer_numbers' : Termwin_buffer_numbers_this_tab(),
\})<CR>
vnoremap <silent> mru "vy:<C-U>       call Muxter({ 
\ 'string'                      : @v,
\ 'append_cr_is_wanted' : 'Y',
\ 'termwin_buffer_numbers' : Termwin_buffer_numbers_this_tab(),
\})<CR>
"MNEMONICS: m:Muxt, ru:RUn

" ==============================================================================
" MUXT CURRENT LINE: COMMANDS & MAPS
" ==============================================================================

" ------------------------------------------------------------------------------
" --- :Muxt{2Windows}   Muxt Current Line

" 2Termwins
command! -count=0 -nargs=* Muxtyy2Termwins  :call Muxter({
\ 'string'                      : getline('.'),
\ 'termwin_buffer_numbers'      : Termwin_buffer_numbers_this_tab(),
\})

nnoremap <silent> myyt yy:<C-U>          call Muxter({ 
\ 'string'                      : getline('.'),
\ 'termwin_buffer_numbers'      : Termwin_buffer_numbers_this_tab(),
\})<CR>
vnoremap <silent> myyt  yy:<C-U>          call Muxter({ 
\ 'string'                      : getline('.'),
\ 'termwin_buffer_numbers'      : Termwin_buffer_numbers_this_tab(),
\})<CR>
" MNEMONICS: m:Muxt, yy:`yy` t:Termwin


" ==============================================================================
" MUXT THIS FILEPATH: COMMANDS & MAPS
" ==============================================================================

" ------------------------------------------------------------------------------
" --- :MuxtFilepath{2Windows}   Mux Filepath of current Editwin 
"          ^^^^^^^^

" 2Termwins
command! -count=0 -nargs=* MuxtFilepath2Termwins  :call Muxter({
\ 'string_type'            : 'this_filepath',
\ 'termwin_buffer_numbers' : Termwin_buffer_numbers_this_tab(),
\})

nnoremap <silent> mft :<C-U>          call Muxter({ 
\ 'string_type'            : 'this_filepath',
\ 'termwin_buffer_numbers' : Termwin_buffer_numbers_this_tab(),
\})<CR>
vnoremap <silent> mft :<C-U>          call Muxter({ 
\ 'string_type'            : 'this_filepath',
\ 'termwin_buffer_numbers' : Termwin_buffer_numbers_this_tab(),
\})<CR>
" MNEMONICS: m:Muxt, f:Filepath, rt:Ref Termwin

" ------------------------------------------------------------------------------
" --- :MuxtFilepathll{2Windows}    Muxt & `ll` Filepath of current Editwin 
"                  ^^

" 2Termwins
command! -count=0 -nargs=* MuxtFilepathll2Termwins  :call Muxter({
\ 'string_prefix'          : 'll ',
\ 'string_type'            : 'this_filepath',
\ 'append_cr_is_wanted'    : 'Y',
\ 'termwin_buffer_numbers' : Termwin_buffer_numbers_this_tab(),
\})

nnoremap <silent> mfl :<C-U>          call Muxter({ 
\ 'string_prefix'          : 'll ',
\ 'string_type'            : 'this_filepath',
\ 'append_cr_is_wanted'    : 'Y',
\ 'termwin_buffer_numbers' : Termwin_buffer_numbers_this_tab(),
\})<CR>
vnoremap <silent> mfl :<C-U>          call Muxter({ 
\ 'string_prefix'          : 'll ',
\ 'string_type'            : 'this_filepath',
\ 'append_cr_is_wanted'    : 'Y',
\ 'termwin_buffer_numbers' : Termwin_buffer_numbers_this_tab(),
\})<CR>
"MNEMONICS: m:Muxt, f:Filepath, l:`ll`

" ------------------------------------------------------------------------------
" --- :MuxtFilepathSource{2Windows}  `source` Filepath of current Editwin
"                  ^^^^^^

" 2Termwins
command! -count=0 -nargs=* MuxtFilepathSource2RefTermwin  :call Muxter({
\ 'string_type'         : 'this_filepath',
\ 'string_prefix'       : 'source ',
\ 'append_cr_is_wanted' : 'Y',
\ 'termwin_buffer_numbers' : Termwin_buffer_numbers_this_tab(),
\})

nnoremap <silent> mfs :<C-U>          call Muxter({ 
\ 'string_type'         : 'this_filepath',
\ 'string_prefix'       : 'source ',
\ 'append_cr_is_wanted' : 'Y',
\ 'termwin_buffer_numbers' : Termwin_buffer_numbers_this_tab(),
\})<CR>
vnoremap <silent> mfs :<C-U>          call Muxter({ 
\ 'string_type'         : 'this_filepath',
\ 'string_prefix'       : 'source ',
\ 'append_cr_is_wanted' : 'Y',
\ 'termwin_buffer_numbers' : Termwin_buffer_numbers_this_tab(),
\})<CR>
"MNEMONICS: m:Muxt, f:Filepath, S:Source


" ------------------------------------------------------------------------------
" --- :MuxtFilepathRun{2Windows}  `run` Filepath of current Editwin
"                  ^^^

" 2Termwins
command! -count=0 -nargs=* MuxtFilepathRun2RefTermwin  :call Muxter({
\ 'string_type'         : 'this_filepath',
\ 'append_cr_is_wanted' : 'Y',
\ 'termwin_buffer_numbers' : Termwin_buffer_numbers_this_tab(),
\})

nnoremap <silent> mfr :<C-U>          call Muxter({ 
\ 'string_type'         : 'this_filepath',
\ 'append_cr_is_wanted' : 'Y',
\ 'termwin_buffer_numbers' : Termwin_buffer_numbers_this_tab(),
\})<CR>
vnoremap <silent> mfr :<C-U>          call Muxter({ 
\ 'string_type'         : 'this_filepath',
\ 'append_cr_is_wanted' : 'Y',
\ 'termwin_buffer_numbers' : Termwin_buffer_numbers_this_tab(),
\})<CR>
"MNEMONICS: m:Muxt, f:Filepath, r:Run

" ==============================================================================
" MUXT `make`: COMMANDS & MAPS
" ==============================================================================

" ------------------------------------------------------------------------------
" --- :MuxtMake2Windows}   Mux `make`
"          ^^^^

" 2Termwins
command! -count=0 -nargs=* MuxtMake2Termwins  :call Muxter({
\ 'string'                 : 'make',
\ 'termwin_buffer_numbers' : Termwin_buffer_numbers_this_tab(),
\})

nnoremap <silent> mma :<C-U>          call Muxter({ 
\ 'string'                 : 'make',
\ 'termwin_buffer_numbers' : Termwin_buffer_numbers_this_tab(),
\})<CR>
vnoremap <silent> mma :<C-U>          call Muxter({ 
\ 'string'                 : 'make',
\ 'termwin_buffer_numbers' : Termwin_buffer_numbers_this_tab(),
\})<CR>
" MNEMONICS: m:Muxt, ma:MAke

" ==============================================================================
" MUXT/RUN DYNAMIC STRINGS FROM VIM EX LINE TO TERMWINS
" ==============================================================================

" ------------------------------------------------------------------------------
" --- :MuxtExArgs2Windows}   Muxt :Ex Line Args
"          ^^^^

" 2Termwins
command! -count=0 -nargs=* MuxtExArgs2Termwins  :call Muxter({
\ 'string'                 : '<args>',
\ 'termwin_buffer_numbers' : Termwin_buffer_numbers_this_tab(),
\})

" ------------------------------------------------------------------------------
" --- :MuxtExArgsRun2Windows}   Muxt & Run :Ex Line Args
"          ^^^^^^^^^

" 2Termwins
command! -count=0 -nargs=* MuxtExArgsRun2Termwins  :call Muxter({
\ 'string'                 : '<args>',
\ 'append_cr_is_wanted'    : 'Y',
\ 'termwin_buffer_numbers' : Termwin_buffer_numbers_this_tab(),
\})

" ==============================================================================
" TERMWINS CONTROL 
" ==============================================================================

" ------------------------------------------------------------------------------
" --- :MuxtCR2Termwins Muxt Carriage Return

command! MuxtCR2Termwins   :call Muxter({
\ 'string'                 : "\<CR>",
\ 'termwin_buffer_numbers' : Termwin_buffer_numbers_this_tab(),
\})
nnoremap <silent>  mCR     :MuxtCR2Termwins<CR>  
"MNEMONICS: m:Muxt, cr:Carriage Return

" ------------------------------------------------------------------------------
" --- :MuxtSpace2Termwins Muxt Space Key (3 space keys ?)
"  NOTE-DOC:  in testing, it seems that 3 chars emit

command! -count=0 -nargs=* MuxtSP2Termwins    :call Muxter({
\ 'string'              : " ",
\ 'termwin_buffer_numbers' : Termwin_buffer_numbers_this_tab(),
\})
nnoremap <silent>  mSP     :MuxtSP2Termwins<CR>  

"MNEMONICS: m:Muxt, sp:SPace

" ------------------------------------------------------------------------------
" --- :MuxtCC2Termwins Muxt CONTROL-C

command! -count=0 -nargs=* MuxtCC2Termwins    :call Muxter({
\ 'string'              : "\<C-C>\<C-C>",
\ 'termwin_buffer_numbers' : Termwin_buffer_numbers_this_tab(),
\})

nnoremap <silent>  mCC     :MuxtCC2Termwins<CR>  
"MNEMONICS: m:Muxt, CC:CNTL-C

" ------------------------------------------------------------------------------
" --- :MuxtCU2Termwins Muxt CONTROL-U

command! -count=0 -nargs=* MuxtCU2Termwins    :call Muxter({
\ 'string'              : "\<C-U>",
\ 'termwin_buffer_numbers' : Termwin_buffer_numbers_this_tab(),
\})

nnoremap <silent>  mCU     :MuxtCU2Termwins<CR>  
"MNEMONICS: m:Muxt, cu:CNTL-U Vim & shell cmd

" ------------------------------------------------------------------------------
" --- :MuxtNormal2Termwins  Muxt Keys to Effect Termwin Normal Mode
""\ 'string'                 : "\<C-W>\<C-N>",

command! MuxtNormal2Termwins :call Muxter({
\ 'string'                 : "\<C-W>N\<SPACE>",
\ 'termwin_buffer_numbers' : Termwin_buffer_numbers_this_tab(),
\})
nnoremap <silent>  mno  :MuxtNormal2Termwins<CR>  
" MNEMONICS: m:Muxt, no:NOrmal


" ==============================================================================
" WINTYPE CONVERSION
" ==============================================================================

" ==============================================================================
function! Window_convert_termwin_to_editwin(rcvd_hash)
" ==============================================================================
  let                                     l:rcvd_hash = extend ({
  \ 'exclude_selfwin_is_wanted' : 'N',
  \ 'selfwin_buffer_number'     : s:NOT_A_BUFFER_NUMBER,
  \  },
  \                              deepcopy(a:rcvd_hash,1)
 \)
  if l:rcvd_hash['exclude_selfwin_is_wanted'] == 'Y'
\ && l:rcvd_hash['selfwin_buffer_number']     == bufnr("%")
     return
  endif

  if &buftype == 'terminal'
     set hidden 
     enew
     " NOTE-DOC-VIM-hidden|enew: see Vim docu for each of these.  Result here
     " is that the buffer is removed from this window but is not removed from
     " buffer list.
  endif
endfunction
" ==============================================================================
function! Convert_termwins_to_editwins_this_tab()
" ==============================================================================
  let             l:window_id_at_function_entry = win_getid(winnr())

  windo call        Window_convert_termwin_to_editwin({})

  call win_gotoid(l:window_id_at_function_entry)
endfunction
" ==============================================================================
function! Convert_termwins_to_editwins_this_tab_exclude_selfwin()
" ==============================================================================
  let l:window_id_at_function_entry = win_getid(winnr())
  let l:selfwin_buffer_number       = bufnr("%")
      
  windo call        Window_convert_termwin_to_editwin({
  \    'exclude_selfwin_is_wanted'  : 'Y',
  \    'selfwin_buffer_number'      : l:selfwin_buffer_number,
\ })

  call win_gotoid(l:window_id_at_function_entry)
endfunction
" ==============================================================================
function! Window_convert_editwin_to_termwin(rcvd_hash)
" ==============================================================================
  let                                     l:rcvd_hash = extend ({
  \ 'exclude_selfwin_is_wanted'     : 'N',
  \ 'selfwin_buffer_number'         : s:NOT_A_BUFFER_NUMBER,
  \  },
  \                              deepcopy(a:rcvd_hash,1)
 \)
  if l:rcvd_hash['exclude_selfwin_is_wanted'] == 'Y'
\ && l:rcvd_hash['selfwin_buffer_number']     == bufnr("%")
     return
  endif

  if empty(&buftype)
    :TermwinCreateSelfwin 
  endif
endfunction
" ==============================================================================
function! Convert_editwins_to_termwins_this_tab()
" ==============================================================================
  let             l:window_id_at_function_entry = win_getid(winnr())

  windo call        Window_convert_editwin_to_termwin({})

  call win_gotoid(l:window_id_at_function_entry)
endfunction
" ==============================================================================
function! Convert_editwins_to_termwins_this_tab_exclude_selfwin()
" ==============================================================================
  let             l:window_id_at_function_entry = win_getid(winnr())
  let             l:selfwin_buffer_number       = bufnr("%")

  windo call        Window_convert_editwin_to_termwin({
  \ 'exclude_selfwin_is_wanted' : 'Y',
  \ 'selfwin_buffer_number'     : l:selfwin_buffer_number,
\ })

  call win_gotoid(l:window_id_at_function_entry)
endfunction
" ------------------------------------------------------------------------------
" --- Convert this tab's termwins to editwins
" ------------------------------------------------------------------------------
command!              ConvertTabTermwins2Editwins :call Convert_termwins_to_editwins_this_tab()
noremap <silent> T2e :ConvertTabTermwins2Editwins<CR>
" MNEMONICS: T:entire Tab, 2:to, e:Editwins
" MNEMONICS txtmux v1.0.0: t:Termwins, 2:to, e:Editwins

" --- Exclude selfWin
command!              ConvertTabOtherTermwins2Editwins :call Convert_termwins_to_editwins_this_tab_exclude_selfwin()
noremap <silent> t2e :ConvertTabOtherTermwins2Editwins<CR>
" MNEMONICS: t:other termwins this Tab, 2:to, e:Editwins
" MNEMONICS txtmux v1.0.0: o:Other termwins this tab, 2:to, e:Editwins

" ------------------------------------------------------------------------------
" --- Convert this tab's editwins to termwins
" ------------------------------------------------------------------------------
command!              ConvertTabEditwins2Termwins :call Convert_editwins_to_termwins_this_tab()
" --- Exclude selfWin
"
command!              ConvertTabOtherEditwins2Termwins :call Convert_editwins_to_termwins_this_tab_exclude_selfwin()
" ==============================================================================
"
" QUIT WINTYPES
" ==============================================================================

" ------------------------------------------------------------------------------
" --- quit all termwins
command!              QuitAllTermwins :call Termwins_quit_all_forcefully()
noremap <silent> qat :QuitAllTermwins<CR>
" MNEMONICS: q:Quit, a:All, t:Termwins

" ------------------------------------------------------------------------------
" --- quit all this tab's termwins
command!              QuitTabTermwins :call Termwins_this_tab_quit_forcefully()
noremap <silent> qTt :QuitTabTermwins <CR>
" MNEMONICS: q:Quit, t:Tab, t:Termwins

" ------------------------------------------------------------------------------
" --- Quit editwins
" ------------------------------------------------------------------------------

" --- quit all editwins
command!              QuitAllEditwins :call Editwins_quit_all_forcefully()
noremap <silent> qae :QuitAllEditwins<CR>
" MNEMONICS: q:Quit, a:All, e:Editwins

" ------------------------------------------------------------------------------
" --- quit all this tab's editwins
command!              QuitTabEditwins :call Editwins_this_tab_quit_forcefully()
noremap <silent> qTe :QuitTabEditwins <CR>
" MNEMONICS: q:Quit, T:Tab, e:Editwins

" ==============================================================================
function! Window_quit_and_forcefully_if_termwin()
" ==============================================================================
  if &buftype == 'terminal'
     <C-W>:quit!
     return
  endif
  quit
endfunction
" ==============================================================================
function! Window_close_and_forcefully_if_termwin()
" ==============================================================================
  if &buftype == 'terminal'
     close!
     return
  endif

  close
endfunction
" ==============================================================================
function! Editing_window_quit()
" ==============================================================================
" for now, an 'Editing Window' is any non-termwin window
  if &buftype != 'terminal'
     quit
     "NOT 'quit!' !   (not quite!)
  endif
endfunction
" ==============================================================================
function! Termwin_quit_forcefully()
" ==============================================================================
  if &buftype == 'terminal'
     quit!
  endif
endfunction
" ==============================================================================
function! Editwin_quit_forcefully()
" ==============================================================================
  if empty(&buftype)
     quit!
  endif
endfunction
" ==============================================================================
function! Termwins_this_tab_quit_forcefully()
" ==============================================================================
  let             l:window_id_at_function_entry = win_getid(winnr())

  windo call        Termwin_quit_forcefully()

  call win_gotoid(l:window_id_at_function_entry)
endfunction
" ==============================================================================
function! Termwins_quit_all_forcefully()
" ==============================================================================
  let             l:window_id_at_function_entry = win_getid(winnr())

  tabdo windo call  Termwin_quit_forcefully()

  call win_gotoid(l:window_id_at_function_entry)
endfunction
" ==============================================================================
function! Editwins_this_tab_quit_forcefully()
" ==============================================================================
  let             l:window_id_at_function_entry = win_getid(winnr())

  windo call        Editwin_quit_forcefully()

  call win_gotoid(l:window_id_at_function_entry)
endfunction
" ==============================================================================
function! Editwins_quit_all_forcefully()
" ==============================================================================
  let             l:window_id_at_function_entry = win_getid(winnr())

  tabdo windo call  Editwin_quit_forcefully()

  call win_gotoid(l:window_id_at_function_entry)
endfunction
" =============================================================== 
function! Windows_quit_all_and_with_force_if_termwin_vDEPRECATED()
" =============================================================== 
  tabdo windo call Window_quit_and_forcefully_if_termwin()
   " DEPRECATED b/c terminals stil managed to hold up Even
   " quit!  !
" ---------------------------------------------------------
" :qa for Session with Termwins
"
" NOTE-DOC-VIM:  of course, to :quit! ALL  windows, 
" there's std Vim :qa! -- So why this func ?
" b/c: cannot quit a termwin w/o using '!' forceful qualifier
" BUT if quitting all windows via :qa, you don't want to quit 
" editing windows with force, i.e. want to save those windows
" if they are changed/unsaved.  This cmd enables that.
"
" NOTE-DOC-VIM:  & of course, to :quit! ALL  windows, 
endfunction
" =============================================================== 
function! Windows_quit_all_and_with_force_if_termwin()
" =============================================================== 
  " :qa for Session with Termwins
   tabdo windo call Editing_window_quit()

   " now that non-termwins are gone, only termwins
   " remain, and don't care about preserving anything
   " in them (if that's wanted, should be logging them
   " already). So, just get out !

   :qall!

  " See comments in 
  "   Windows_quit_all_and_with_force_if_termwin_vDEPRECATED()
endfunction
" ==============================================================================
function! Tabclose_quit_with_force_if_termwin()
" ==============================================================================
  let             l:window_id_at_function_entry = win_getid(winnr())

  windo call Window_close_and_forcefully_if_termwin()

  call win_gotoid(l:window_id_at_function_entry)

" :tabclose for a tab with Termwins
"
" NOTE-DOC-VIM:  of course, to :close! ALL  windows in a tab, 
" there's std Vim :tabclose! -- Why this func ?
" b/c: Here, comments in Windows_quit_all_and_with_force_if_termwin() 
" apply to tab-scope.
endfunction
" ------------------------------------------------------------------------------
command!               QuitTabAndWithForceIfTermwin :call Tabclose_quit_with_force_if_termwin()
nnoremap <silent> qTT :QuitTabAndWithForceIfTermwin<CR>
" ------------------------------------------------------------------------------
command!               QuitAllAndWithForceIfTermwin :call Windows_quit_all_and_with_force_if_termwin()
nnoremap <silent> qaa :QuitAllAndWithForceIfTermwin <CR>


" //////////////////////////////////////////////////////////////////////////////
" txtmux menu
" //////////////////////////////////////////////////////////////////////////////

let g:FILLSPEC_NULLSTRING = ''

" ==============================================================================
function! Open_V12_tab()
" ==============================================================================
  :TabwinsVertical 12;
  \          'Explore /',
  \ 
  \          ':TermwinCreateSelfwin',
  \          ':TermwinCreateSelfwin',
  \;
  \ 'ending_window_number' : 1
endfunction
command! OV12 :call Open_V12_tab()
" ==============================================================================
function! Open_V12B_tab()
" ==============================================================================
  call Open_V12_tab()
  :TermwinCreateBottom
endfunction
command! OV12B :silent! call Open_V12B_tab()
" ==============================================================================
function! Open_V22_tab()
" ==============================================================================
  :TabwinsVertical 22;
  \          'Explore /',
  \           g:FILLSPEC_NULLSTRING,
  \ 
  \          ':TermwinCreateSelfwin',
  \          ':TermwinCreateSelfwin',
  \;
  \ 'ending_window_number' : 2
endfunction
command! OV22 :call Open_V22_tab()
" ==============================================================================
function! Open_V22B_tab()
" ==============================================================================
  call Open_V22_tab()
  :TermwinCreateBottom
endfunction
command! OV22B :silent! call Open_V22B_tab()
" ==============================================================================
function! Open_V23_tab()
" ==============================================================================
  :TabwinsVertical 23;
  \          'Explore /',
  \           g:FILLSPEC_NULLSTRING,
  \ 
  \          ':TermwinCreateSelfwin',
  \          ':TermwinCreateSelfwin',
  \          ':TermwinCreateSelfwin',
  \;
  \ 'ending_window_number' : 2
endfunction
command! OV23 :call Open_V23_tab()
" ==============================================================================
function! Open_V23B_tab()
" ==============================================================================
  call Open_V23_tab()
  :TermwinCreateBottom
endfunction
command! OV23B :silent! call Open_V23B_tab()
" ==============================================================================
function! Open_V33_tab()
" ==============================================================================
  :TabwinsVertical 33;
  \          'Explore /',
  \           g:FILLSPEC_NULLSTRING,
  \           g:FILLSPEC_NULLSTRING,
  \ 
  \          ':TermwinCreateSelfwin',
  \          ':TermwinCreateSelfwin',
  \          ':TermwinCreateSelfwin',
  \;
  \ 'ending_window_number' : 3
endfunction
command! OV33 :call Open_V33_tab()
" ==============================================================================
function! Open_V33B_tab()
" ==============================================================================
  call Open_V33_tab()
  :TermwinCreateBottom
endfunction
command! OV33B :silent! call Open_V33B_tab()
" ==============================================================================
function! Open_V323_tab()
" ==============================================================================
  :TabwinsVertical 323;
  \          ':TermwinCreateSelfwin',
  \          ':TermwinCreateSelfwin',
  \          ':TermwinCreateSelfwin',
  \ 
  \          'Explore /',
  \           g:FILLSPEC_NULLSTRING,
  \ 
  \          ':TermwinCreateSelfwin',
  \          ':TermwinCreateSelfwin',
  \          ':TermwinCreateSelfwin',
  \;
  \ 'ending_window_number' : 3
endfunction
command! OV323 :call Open_V323_tab()
" ==============================================================================
function! Open_V222_tab()
" ==============================================================================
  :TabwinsVertical 222;
  \          'Explore /',
  \           g:FILLSPEC_NULLSTRING,
  \ 
  \          ':TermwinCreateSelfwin',
  \          ':TermwinCreateSelfwin',
  \
  \          ':TermwinCreateSelfwin',
  \          ':TermwinCreateSelfwin',
  \;
  \ 'ending_window_number' : 2
endfunction
command! OV222 :call Open_V222_tab()
" ==============================================================================
function! Open_H323_tab()
" ==============================================================================
  :TabwinsHorizontal 323;
  \          ':TermwinCreateSelfwin',
  \          ':TermwinCreateSelfwin',
  \          ':TermwinCreateSelfwin',
  \ 
  \          'Explore /',
  \           g:FILLSPEC_NULLSTRING,
  \ 
  \          ':TermwinCreateSelfwin',
  \          ':TermwinCreateSelfwin',
  \          ':TermwinCreateSelfwin',
  \;
  \ 'ending_window_number' : 4
endfunction
command! OH323 :call Open_H323_tab()
" ==============================================================================
function! Open_H323L_tab()
" ==============================================================================
  call Open_H323_tab()
  :TermwinCreateFarLeft
endfunction
command! OH323L :silent! call Open_H323L_tab()
" ==============================================================================
function! Open_H333_tab()
" ==============================================================================
  :TabwinsHorizontal 333;
  \          ':TermwinCreateSelfwin',
  \          ':TermwinCreateSelfwin',
  \          ':TermwinCreateSelfwin',
  \ 
  \          'Explore /',
  \           g:FILLSPEC_NULLSTRING,
  \          'Explore /usr',
  \ 
  \          ':TermwinCreateSelfwin',
  \          ':TermwinCreateSelfwin',
  \          ':TermwinCreateSelfwin',
  \;
  \ 'ending_window_number' : 4
endfunction
command! OH333 :call Open_H333_tab()
" ==============================================================================
function! Open_H332_tab()
" ==============================================================================
  :TabwinsHorizontal 332;
  \          ':TermwinCreateSelfwin',
  \          ':TermwinCreateSelfwin',
  \          ':TermwinCreateSelfwin',
  \
  \          ':TermwinCreateSelfwin',
  \          ':TermwinCreateSelfwin',
  \          ':TermwinCreateSelfwin',
  \
  \           g:FILLSPEC_NULLSTRING,
  \           g:FILLSPEC_NULLSTRING,
  \;
  \ 'ending_window_number' : 8
endfunction
command! OH332 :call Open_H332_tab()
" ==============================================================================
function! Open_H333_TermwinOnly_tab()
" ==============================================================================
  :TabwinsHorizontal 333;
  \          ':TermwinCreateSelfwin',
  \          ':TermwinCreateSelfwin',
  \          ':TermwinCreateSelfwin',
  \
  \          ':TermwinCreateSelfwin',
  \          ':TermwinCreateSelfwin',
  \          ':TermwinCreateSelfwin',
  \
  \          ':TermwinCreateSelfwin',
  \          ':TermwinCreateSelfwin',
  \          ':TermwinCreateSelfwin',
  \;
  \ 'ending_window_number' : 7
endfunction
command! OH333TermwinOnly :call Open_H333_TermwinOnly_tab()
" ==============================================================================
function! Open_1LH333_TermwinOnly_tab()
" ==============================================================================
  call Open_H333_TermwinOnly_tab()
  :TermwinCreateFarLeft
endfunction
command! O1LH333TerminOnly :silent! call Open_1LH333_TermwinOnly_tab()
" ==============================================================================
function! Open_V2333_tab()
" ==============================================================================
  :TabwinsVertical 2333;
  \          'Explore /',
  \           g:FILLSPEC_NULLSTRING,
  \ 
  \          ':TermwinCreateSelfwin',
  \          ':TermwinCreateSelfwin',
  \          ':TermwinCreateSelfwin',
  \
  \          ':TermwinCreateSelfwin',
  \          ':TermwinCreateSelfwin',
  \          ':TermwinCreateSelfwin',
  \
  \          ':TermwinCreateSelfwin',
  \          ':TermwinCreateSelfwin',
  \          ':TermwinCreateSelfwin',
  \;
  \ 'ending_window_number' : 7
endfunction
command! OV2333 :call Open_V2333_tab()
" ==============================================================================
function! s:menu_build()
" ==============================================================================
  execute g:txtmuxD_menu_number . 'amenu txtmuxD.DEMO <Nop>'
  amenu txtmuxD.-Sep100-                     <Nop>

  "--- TxT Tabs
  amenu txtmuxD.TxT\ .V12    :silent! OV12<CR>
  amenu txtmuxD.TxT\ .V12B  :silent! OV12B<CR>

  amenu txtmuxD.TxT\ .V22    :silent! OV22<CR>
  amenu txtmuxD.TxT\ .V22B  :silent! OV22B<CR>

  amenu txtmuxD.TxT\ .V23    :silent! OV23<CR>
  amenu txtmuxD.TxT\ .V23B  :silent! OV23B<CR>

  amenu txtmuxD.TxT\ .V33    :silent! OV33<CR>
  amenu txtmuxD.TxT\ .V33B  :silent! OV33B<CR>

  amenu txtmuxD.TxT\ .V323    :silent! OV323<CR>

  amenu txtmuxD.TxT\ .V222    :silent! OV222<CR>

  amenu txtmuxD.TxT\ .H333     :silent! OH333<CR>

  amenu txtmuxD.TxT\ .H332    :silent! OH332<CR>

  amenu txtmuxD.TxT\ .H333TermwinOnly    :silent! OH333TermwinOnly<CR>
  amenu txtmuxD.TxT\ .1LH333TerminOnly   :silent! O1LH333TerminOnly   <CR>

  amenu txtmuxD.TxT\ .V2333    :silent! OV2333<CR>

  "--- Muxt
" amenu txtmuxD.-Sep107-                     <Nop>
  amenu txtmuxD.Muxt.:Muxt2Termwins    :silent! Muxt2Termwins<CR>
  amenu txtmuxD.Muxt.:MuxtFilepathll2Termwins  :silent! MuxtFilepathll2Termwins<CR>
  amenu txtmuxD.Muxt.:Muxtyy2Termwins  :silent! Muxtyy2Termwins<CR>
  amenu txtmuxD.Muxt.:MuxtCR2Termwins    :silent! MuxtCR2Termwins<CR>
  amenu txtmuxD.Muxt.:MuxtCU2Termwins    :silent! MuxtCU2Termwins<CR>
  amenu txtmuxD.Muxt.:MuxtExArgsRun2Termwins :silent! MuxtExArgsRun2Termwins

  "--- Convert
" amenu txtmuxD.-Sep109-                     <Nop>
  amenu txtmuxD.Convert.o2e    :silent! ConvertTabOtherTermwins2Editwins<CR>
  amenu txtmuxD.Convert.o2t    :silent! ConvertTabOtherEditwins2Termwins<CR>

  "--- Exit
" amenu txtmuxD.-Sep109-                     <Nop>
  amenu txtmuxD.Exit.:QuitAllTermwins    :silent! QuitAllTermwins<CR>
endfunction
" ==============================================================================
if g:load_txtmuxD_menu_is_wanted ==? 'Y'
  call <SID>menu_build()
endif
" ==============================================================================

" //////////////////////////////////////////////////////////////////////////////
let g:impl_txtmux_is_loaded = 'Y'
" //////////////////////////////////////////////////////////////////////////////
