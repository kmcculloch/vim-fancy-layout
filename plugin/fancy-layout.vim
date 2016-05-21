" vim: foldmethod=marker

" Is fancy layout loaded?
let g:fancy_loaded = 0

" FANCY LAYOUT INITIALIZATION {{{
function! FancyLayoutInit()
  " Map some new keys for the nerd tree
  let s = '<SNR>' . s:SID() . '_'
  call NERDTreeAddKeyMap({ 'key': 'a', 'scope': "FileNode", 'callback': s."FancyLayoutOpenA" })
  call NERDTreeAddKeyMap({ 'key': 'a', 'scope': "Bookmark", 'callback': s."FancyLayoutOpenBookmarkA" })
  call NERDTreeAddKeyMap({ 'key': 'ga', 'scope': "FileNode", 'callback': s."FancyLayoutPreviewA" })
  call NERDTreeAddKeyMap({ 'key': 'ga', 'scope': "Bookmark", 'callback': s."FancyLayoutPreviewA" })
  call NERDTreeAddKeyMap({ 'key': 'b', 'scope': "FileNode", 'callback': s."FancyLayoutOpenB" })
  call NERDTreeAddKeyMap({ 'key': 'b', 'scope': "Bookmark", 'callback': s."FancyLayoutOpenBookmarkB" })
  call NERDTreeAddKeyMap({ 'key': 'gb', 'scope': "FileNode", 'callback': s."FancyLayoutPreviewB" })
  call NERDTreeAddKeyMap({ 'key': 'gb', 'scope': "Bookmark", 'callback': s."FancyLayoutPreviewB" })

  " Use our custom quit routines for all window/buffer delete commands
  call cabbrevplus#Cabbrev('bd', 'FancyLayoutQ')
  call cabbrevplus#Cabbrev('bw', 'FancyLayoutQ')
  call cabbrevplus#Cabbrev('bu', 'FancyLayoutQ')
  call cabbrevplus#Cabbrev('bun', 'FancyLayoutQ')
  call cabbrevplus#Cabbrev('q', 'FancyLayoutQ')
  call cabbrevplus#Cabbrev('wq', 'FancyLayoutWQ')

  " Open the nerd tree and build the windows
  call FancyLayoutBuildWindows()

  let g:fancy_loaded = 1
endfunction

if !exists(':FancyLayoutInit')
  command! FancyLayoutInit call FancyLayoutInit()
endif

"}}}
" BUILD WINDOWS {{{
function! FancyLayoutBuildWindows()
  " Open the NERDTree and close everything else
  :NERDTree
  :only

  " Split vertically; we now have two windows
  :vsplit

  " Split vertically; we now have three windows
  :vsplit

  " Size and populate the NERDTree
  1wincmd w
  vertical resize 60
  set winfixwidth
  call NERDTreeRender()

  " Size and populate window three
  3wincmd w
  :b1
  vertical resize 87
  set winfixwidth

  " Size and populate window two
  2wincmd w
  :b1
  vertical resize 87
  set winfixwidth

  " Go back to the NERDTree
  1wincmd w
  " If we want to jump to the top of the buffer, uncomment here. Otherwise
  " we'll land at the top of the files list.
  "execute 'normal gg'

endfunction

"}}}
" NERD TREE CALLBACKS {{{

function! s:FancyLayoutOpenA(node)
  call FancyLayoutGoto('main')
  call FancyLayoutGoto('tree')
  call a:node.activate({'reuse': 1, 'where': 'p'})
endfunction

function! s:FancyLayoutOpenB(node)
  call FancyLayoutGoto('pre')
  call FancyLayoutGoto('tree')
  call a:node.activate({'reuse': 1, 'where': 'p'})
endfunction

function! s:FancyLayoutPreviewA(node)
  call FancyLayoutGoto('main')
  call FancyLayoutGoto('tree')
  call a:node.open({'stay': 1, 'where': 'p', 'keepopen': 1})
  
  " Refresh the Airline tabline
  silent doautocmd BufDelete *
  silent doautocmd User AirlineToggledOn
endfunction

function! s:FancyLayoutPreviewB(node)
  call FancyLayoutGoto('pre')
  call FancyLayoutGoto('tree')
  call a:node.open({'stay': 1, 'where': 'p', 'keepopen': 1})

  " Refresh the Airline tabline
  silent doautocmd BufDelete *
  silent doautocmd User AirlineToggledOn
endfunction

function! s:FancyLayoutOpenBookmarkA(bm)
  call FancyLayoutGoto('main')
  call FancyLayoutGoto('tree')
  call a:bm.activate(!a:bm.path.isDirectory ? {'where': 'p'} : {})
endfunction

function! s:FancyLayoutOpenBookmarkB(bm)
  call FancyLayoutGoto('pre')
  call FancyLayoutGoto('tree')
  call a:bm.activate(!a:bm.path.isDirectory ? {'where': 'p'} : {})
endfunction

"}}}
" BUFFER DELETION ROUTINES {{{
function! FancyLayoutQ()
  let l:winnr = winnr()
  if l:winnr ==# 1
    " This is the nerd tree; do nothing
  elseif l:winnr ==# 2
    :MBEbw
  elseif l:winnr ==# 3
    :MBEbw
  elseif l:winnr ==# 4
    :MBEbw
  endif
endfunction

function! FancyLayoutWQ()
  :w
  call FancyLayoutQ()
endfunction

if !exists(':FancyLayoutQ')
  command! FancyLayoutQ call FancyLayoutQ()
endif

if !exists(':FancyLayoutWQ')
  command! FancyLayoutWQ call FancyLayoutWQ()
endif

"}}}
function! FancyLayoutEnter() "{{{
  if g:fancy_loaded
    " auto-resize windows as we move
    " commented out; generally more of a distraction than a help
    "if &ft ==# "nerdtree"
      "vertical resize 50 
    "else
      "vertical resize 87
    "endif

    " prevent direct jumping to NerdTree
    if winnr() == 2
      nnoremap <Leader>h :FancyLayoutNerdTree<CR>
    else
      nnoremap <Leader>h <C-W><C-H>
    endif
  endif
endfunction

autocmd WinEnter * :call FancyLayoutEnter()
"}}}
function! FancyLayoutLeave() "{{{
  if g:fancy_loaded
    " Condense NerdTree
    "if &ft ==# "nerdtree"
      "vertical resize 28
    "endif
  endif
endfunction

autocmd WinLeave * :call FancyLayoutLeave()
"}}}
function! FancyLayoutGoto(window) "{{{
  if g:fancy_loaded
    if a:window ==# 'tree'
      1wincmd w
    elseif a:window ==# 'main'
      2wincmd w
    elseif a:window ==# 'pre'
      3wincmd w
    elseif a:window ==# 'notes'
      4wincmd w
    endif
  endif
endfunction

if !exists(':FancyLayoutGoto')
  command! -nargs=1 FancyLayoutGoto call FancyLayoutGoto(<f-args>)
endif
"}}}
function! FancyLayoutNerdTree() "{{{
  if g:fancy_loaded
    " Go to our destination window so NerdTree files open there
    call FancyLayoutGoto('main')
    " Go to NerdTree
    call FancyLayoutGoto('tree')
  endif
endfunction

if !exists(':FancyLayoutNerdTree')
  command! FancyLayoutNerdTree call FancyLayoutNerdTree()
endif
"}}}
function! FancyLayoutHelp(topic) "{{{
  if g:fancy_loaded
    "call FancyLayoutGoto('notes')
    3wincmd w
    if &ft ==# 'help'
      execute 'help ' . a:topic
    else
      execute 'help ' . a:topic
      5wincmd w
      quit
    endif
  else
    execute 'help ' . a:topic
  endif
endfunction

if !exists(':FancyLayoutHelp')
  command! -nargs=1 FancyLayoutHelp call FancyLayoutHelp(<f-args>)
endif

"}}}
function s:SID() "{{{
    if !exists("s:sid")
        let s:sid = matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
    endif
    return s:sid
endfunction

"}}}
