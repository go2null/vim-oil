" oil.vim: combine with vinegar, or plain netrw, for a delicious salad dressing
" Last Change: 2016-09-25
" Maintainer:  go2null <1t1is2@gmail.com>
" License:     GPL3+

if exists("g:loaded_oil") || &compatible
  finish
endif
"let g:loaded_oil = 1

"# Mappings
nnoremap <silent> <Plug>OilWhisk :call <SID>Whisk()<CR>
nnoremap <silent> <Plug>OilShake :call <SID>Shake()<CR>

function! s:SetDefaultMapping()
  if exists('g:oil_shake')
    nmap <Leader>e <Plug>OilShake
  else
    nmap <Leader>e <Plug>OilWhisk
  endif
endfunction
call s:SetDefaultMapping()

"# Load time options
let s:file_type = 'netrw'

"# Run time options
function! s:SetRuntimeOptions()
  call s:SetDefaultMapping()

  if exists('g:oil_right')
    let s:default_position = 'botright vsplit'
    let s:lexplore         = 'Lexplore!'
  else
    let s:default_position = 'topleft vsplit'
    let s:lexplore         = 'Lexplore'
  endif
endfunction

"# Public functions
function! ListBuffers()
  let current_dir = b:netrw_curdir
  let max         = bufnr('$')
  let counter     = 1
  while counter <= max
    if bufexists(counter)
      let file_type = getbufvar(counter, '&filetype')
      let pwd       = getbufvar(counter, 'netrw_curdir')
      let is_type   = file_type ==# s:file_type ? '==' : '!='
      let is_pwd    = pwd       ==# current_dir ? '==' : '!='
      echom join(['| buffer #' . counter,
            \'filetype{' . file_type, is_type, s:file_type . '}',
            \'pwd{'      . pwd,       is_pwd,  current_dir . '}'])
    endif
    let counter += 1
  endwhile
endfunction

"# Private functions

"## Rotates through Netrw windows and buffers.
" | Buffers | Windows | Current Window | Action                   |
" | ------- | ------- | -------------- | -------------------------|
" | 0       | n/a     | n/a            | new window & new buffer  |
" | 1       | 0       | n/a            | new window & next buffer |
" | 1       | 1       | not Netrw      | goto next window         |
" | 1       | 1       | is Netrw       | close window             |
" | 1       | 2+      | not Netrw      | goto next window         |
" | 1       | 2+      | is Netrw       | close window             |
" | 2+      | 0       | n/a            | new window & next buffer |
" | 2+      | 1       | not Netrw      | goto next window         |
" | 2+      | 1       | is Netrw       | rotate next buffer       |
" | 2+      | 2+      | not Netrw      | goto next window         |
" | 2+      | 2+      | is Netrw       | goto next window         |
"
" | Buffers | Windows | Current Buffer | Action                   |
" | ------- | ------- | -------------- | -------------------------|
" | 0       | 0 (n/a) | not Netrw (n/a)| new window & new buffer  |
" | 1       | 0       | not Netrw (n/a)| new window & next buffer |
" | 2+      | 0       | not Netrw (n/a)| new window & next buffer |
" | 1       | 1       | not Netrw      | goto next window         |
" | 1       | 2+      | not Netrw      | goto next window         |
" | 2+      | 1       | not Netrw      | goto next window         |
" | 2+      | 2+      | not Netrw      | goto next window         |
" | 1       | 1       | is Netrw       | close window & next window |
" | 1       | 2+      | is Netrw       | close window & next window |
" | 2+      | 1       | is Netrw       | rotate next buffer       |
" | 2+      | 2+      | is Netrw       | goto next window         |
function! s:Whisk()
  let next_buffer = s:GetNextBufNr()
  if next_buffer < 1              " new window & new buffer
    call s:NewWindow()
    return
  endif

  let next_window = s:GetNextWinNr()
  if next_window < 1              " new window & next buffer
    call s:NewWindow(next_buffer)
    return
  endif

  if &filetype !=# s:file_type    " goto next window
    execute next_window . 'wincmd w'
    return
  endif

  if next_buffer == bufnr('%')    " close window & goto next window
    if winnr('$') == 1            " if last window, goto alternate buffer
      execute 'buffer #'
    else
      execute 'wincmd c'
      "execute (next_window - 1) . 'wincmd w'
    endif
    return
  endif

  if next_window == winnr()        " rotate next buffer
    execute 'buffer ' . next_buffer
    return
  endif

  " goto next window
  execute next_window . 'wincmd w'

  " Netrw loves to create new buffers
  call s:WipeHiddenDuplicateNetrwBuffers()
endfunction

function! s:Shake()
  if &filetype i==# s:file_type   " close current Netrw window
    if winnr('$') == 1            " if last window, goto alternate buffer
      execute 'buffer #'
    else
      execute 'wincmd c'
    endif
    return
  endif

  let next_buffer = s:GetNextBufNr()
  if next_buffer < 1              " new window & new buffer
    call s:NewWindow()
    return
  endif

  let next_window = s:GetNextWinNr()
  if next_window < 1              " new window & next buffer
    call s:NewWindow(next_buffer)
    return
  endif

  " goto next window
  execute next_window . 'wincmd w'

  " Netrw loves to create new buffers
  call s:WipeHiddenDuplicateNetrwBuffers()
endfunction

" Usage: function(type)
" Returns: type = 'buffer': bufnr, or -1 if none found
"          type = 'window': winnr, or -1 if none found
function! s:GetNextBufWinNumber(type)
  if a:type ==? 'b' || a:type ==? 'buffer'
    let type  ='b'
    let start = bufnr('%') + 1
    let max   = bufnr('$')
  else
    let type  = 'w'
    let start = winnr() + 1
    let max   = winnr('$')
  endif
  if start < 1 || start > max | let start = 1 | endif

  let first_run = 1
  let counter   = start
  while counter != start || first_run == 1
    if type == 'b' && s:IsBufType(counter, s:file_type)
      return counter
    elseif type == 'w' && s:IsWinType(counter, s:file_type)
      return counter
    else
      let counter += 1
      if counter > max | let counter = 1 | endif
    endif
    if first_run == 1 | let first_run = 0 | endif
  endwhile

  return -1
endfunction

" Returns: 1 if buf_nr exists and is of file_type
"          0 otherwise
function! s:IsBufType(buf_nr, file_type)
  if bufexists(a:buf_nr) 
      \ && getbufvar(a:buf_nr, '&filetype') ==? a:file_type
    return 1
  endif
  return 0
endfunction

" Returns: 1 if win_nr is of file_type
"          0 otherwise
function! s:IsWinType(win_nr, file_type)
  if a:win_nr <= winnr('$') 
      \ && getwinvar(a:win_nr, '&filetype') ==? a:file_type
    return 1
  endif
  return 0
endfunction

" Returns: bufnr, or -1 if none found
function! s:GetNextBufNr()
  let start = bufnr('%') + 1
  let max   = bufnr('$')
  if start < 1 || start > max | let start = 1 | endif

  let first_run = 1
  let counter   = start
  while counter != start || first_run == 1
    if bufexists(counter) && getbufvar(counter, '&filetype') ==? s:file_type
      return counter
    else
      let counter += 1
      if counter > max | let counter = 1 | endif
    endif
    if first_run == 1 | let first_run = 0 | endif
  endwhile

  return -1
endfunction

" Returns: winnr, or -1 if none found
function! s:GetNextWinNr()
  let start = winnr() + 1
  let max   = winnr('$')
  if start < 1 || start > max | let start = 1 | endif

  let first_run = 1
  let counter   = start
  while counter != start || first_run == 1
    if getwinvar(counter, '&filetype') ==? s:file_type
      return counter
    else
      let counter += 1
      if counter > max | let counter = 1 | endif
    endif
    if first_run == 1 | let first_run = 0 | endif
  endwhile

  return -1
endfunction

function! s:NewWindow(...)
  let buffer_number = a:0 > 1 && a:2 > 0 ? a:2 + 0 : 0
  let buffer_name   = get(g:, 'NetrwTopLvlMenu', 'Explorer')

  if buffer_number > 0
    execute s:default_position . ' ' . buffer_name
    execute 'buffer ' . buffer_number
  else
    silent execute s:lexplore ' . expand('%:p:h')
  endif
endfunction

function! s:WipeHiddenDuplicateNetrwBuffers()
  let max            = bufnr('$')
  let current_buffer = bufnr('%')
  let current_dir    = b:netrw_curdir
  let counter        = 1
  while counter <= max && counter != current_buffer
    if bufexists(counter)
          \ && bufwinnr(counter)                  == -1
          \ && getbufvar(counter, '&filetype')    == s:file_type
          \ && getbufvar(counter, 'netrw_curdir') == current_dir
      execute 'bwipeout ' . counter
    endif
    let counter += 1
  endwhile
endfunction
