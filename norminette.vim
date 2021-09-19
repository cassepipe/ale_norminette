" Author: cassepipe <cassepipe@ymail.com>
" Heavily based on Joe's <r29jk10@gmail.com> work. May he be here thanked
" Description: norminette linter for C files.
"
" Get the norminette with :
"
" python3 -m pip install --upgrade pip setuptools
" python3 -m pip install norminette
"
" or at : https://github.com/42School/norminette

call ale#Set('c_norminette_executable', 'norminette')
call ale#Set('c_norminette_options', '')

function! ale_linters#c#norminette#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'c_norminette_executable')
endfunction

function! ale_linters#c#norminette#GetCommand(buffer) abort
    return ale#Escape(ale_linters#c#norminette#GetExecutable(a:buffer))
    \   . ale#Var(a:buffer, 'c_norminette_options')
    \   . ' %t'
endfunction

function! ale_linters#c#norminette#Opscript(buffer, lines) abort
    " Look for lines like the following.
	" :set incsearch to test your patterns in real-time !
    "
	"ft_lstsize.c: Error!
	"Error: SPACE_REPLACE_TAB    (line:  17, col:  11):	Found space when expecting tab
	"ft_calloc.c: OK!
	"ft_memcpy.c: Error!
	"Error: SPACE_AFTER_KW       (line:  22, col:  19):	Missing space after keyword
	"test.c: Error!
	"Error: SPACE_BEFORE_FUNC    (line:   6, col:   4):	space before function name
	"Error: WRONG_SCOPE_COMMENT  (line:  12, col:   9):	Comment is invalid in this scope
	"ft_isalnum.c: OK!

	let l:pattern = '\(^\(\h\+\.[ch]\): \(\w\+\)!$\|^Error: \h\+\s\+(line:\s\+\(\d\+\),\s\+col:\s\+\(\d\+\)):\s\+\(.*\)\)'
    let l:output = []
	let l:curr_file = ''
	
	"A good tip to check what is at each index of l:match is to run inside Vim :
	":let pattern='\(^\(\h\+\.[ch]\): \(\w\+\)!$\|^Error: \h\+\s\+(line:\s\+\(\d\+\),\s\+col:\s\+\(\d\+\)):\s\+\(.*\)\)'
	":echo ale#util#GetMatches(['ft_lstsize.c: Error!'], pattern)
	"				           ^^^^^^^^^^^^^^^^^^^^^^
	"				           Replace with each line you want to  match
	"				

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
		if l:match[3] == 'OK'
			continue
		elseif l:match[3] == "Error"
			let l:curr_file = l:match[2]
		else
			call add(l:output, {
            \   'filename': l:curr_file,
            \   'lnum': str2nr(l:match[4]),
            \  'col': str2nr(l:match[5]),
            \   'type': 'W',
            \   'text': "Norminette : " . l:match[6],
            \})
        endif
    endfor

    return l:output
endfunction

call ale#linter#Define('c', {
\   'name': 'norminette',
\   'output_stream': 'both',
\   'executable': function('ale_linters#c#norminette#GetExecutable'),
\   'command': function('ale_linters#c#norminette#GetCommand'),
\   'callback': 'ale_linters#c#norminette#Opscript',
\})
