if exists('g:loaded_operator_pedit')
  finish
endif


call operator#user#define('pedit-edit', 'operator#pedit#edit')
call operator#user#define('pedit-edit-contextually', 'operator#pedit#edit_contextually')


let g:loaded_operator_pedit = 1
