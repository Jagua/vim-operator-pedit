let s:save_cpo = &cpo
set cpo&vim


function! operator#pedit#edit(motion_wise) abort "{{{
  call s:edit(a:motion_wise, &filetype)
endfunction "}}}


function! operator#pedit#edit_contextually(motion_wise) abort "{{{
  call s:edit(a:motion_wise, context_filetype#get_filetype())
endfunction "}}}


function! s:edit(motion_wise, filetype) abort "{{{
  let target_filetype = a:filetype
  if a:motion_wise ==# 'block'
    echoerr 'operator-pedit: not allow blockwise.'
  endif

  let original_start_pos = getpos('''[')
  let original_end_pos = getpos(''']')

  let reg = operator#user#register()
  let visual_command = operator#user#visual_command_from_wise_name(a:motion_wise)
  let original_selection = &g:selection
  let &g:selection = 'inclusive'
  execute 'normal!' '`[' . visual_command . '`]"' . reg . 'y'
  let &g:selection = original_selection

  let pedit_bufname = expand('%:t')
        \ . '#'
        \ . join(original_start_pos[1 : 2], ',')
        \ . '-'
        \ . join(original_end_pos[1 : 2], ',')
  pedit `=pedit_bufname`
  wincmd P
  execute 'normal!' '"' . reg . 'P'
  setlocal buftype=acwrite nomodified noswapfile
  if len(target_filetype) > 0
    setfiletype `=target_filetype`
  endif

  augroup operator-pedit
    autocmd! * <buffer>
    autocmd BufWriteCmd <buffer> nested call s:write()
  augroup END

endfunction "}}}


function! s:write() abort "{{{
  setlocal nomodified

  let original_selection = &g:selection
  let &g:selection = 'inclusive'
  execute 'normal!' 'gg0vG$"' . operator#user#register() . 'y'
  wincmd p
  execute 'normal!' '`[v`]"' . operator#user#register() . 'p'
  let &g:selection = original_selection
  wincmd P
endfunction "}}}


let &cpo = s:save_cpo
unlet s:save_cpo
