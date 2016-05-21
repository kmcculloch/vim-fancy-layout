" Replace command-line abbreviations only at the start of the command line
" see http://vim.wikia.com/wiki/Replace_a_builtin_command_using_cabbrev
function! cabbrevplus#Cabbrev(abbreviation, command)
  let a:length = strlen(a:abbreviation) + 1
  let a:newcommand = "cabbrev <expr> " .
        \ a:abbreviation .
        \ " ((getcmdtype() == ':' && getcmdpos() <= " .
        \ a:length .
        \ ")? '" .
        \ a:command .
        \ "' : '" .
        \ a:abbreviation .
        \ "')"
  execute a:newcommand
endfunction
