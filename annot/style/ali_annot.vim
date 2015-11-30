set wrap
highlight Occur ctermbg=lightgray ctermfg=black guibg=lightgray guifg=black
highlight CS ctermfg=DarkCyan guifg=DarkCyan
highlight EN ctermfg=DarkRed guifg=DarkRed
highlight RU ctermfg=DarkYellow guifg=DarkYellow
call matchadd('CS', '^CS.*$')
call matchadd('EN', '^EN.*$')
call matchadd('RU', '^RU.*$')
call matchadd('Occur', '<[^>]\+>')
