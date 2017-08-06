set wrap
highlight Occur ctermfg=DarkRed guifg=DarkRed
highlight LEX ctermfg=DarkGreen guifg=DarkGreen
highlight AUX ctermfg=DarkYellow guifg=DarkYellow
call matchadd('Occur', '\(^A:.*\)\@<=\[[^\]]\+\]')
call matchadd('AUX', '\(^T:.*\)\@<=\[[^\]]\+\]')
call matchadd('LEX', '\(^T:.*\)\@<=\[\[[^\]]\+\]\]')
