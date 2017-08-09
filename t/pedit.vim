scriptencoding utf-8


runtime! plugin/operator/pedit.vim
runtime! plugin/textobj/*.vim


describe '<Plug>(operator-pedit-edit-*)'
  it 'uses preview-window, so needs +quickfix feature'
    Expect has('quickfix') == 1
  end

  it 'is available in proper modes'
    Expect maparg('<Plug>(operator-pedit-edit)', 'c') ==# ''
    Expect maparg('<Plug>(operator-pedit-edit)', 'i') ==# ''
    Expect maparg('<Plug>(operator-pedit-edit)', 'n') =~# 'operator#pedit#'
    Expect maparg('<Plug>(operator-pedit-edit)', 'o') =~# 'g@'
    Expect maparg('<Plug>(operator-pedit-edit)', 'v') =~# 'operator#pedit#'
  end
end


describe '<Plug>(operator-pedit-edit) with line {motion}'
  before
    let g:lines = [
          \ '```',
          \ 'Vim!',
          \ 'Vim is a text editor!',
          \ '```',
          \]
    new
    put = g:lines
    1 delete _

    map ;E <Plug>(operator-pedit-edit)
  end

  after
    bdelete!
  end

  it 'sets the filetype of preview window to none when the filetype of original buffer is none'
    normal jVj;E
    execute "normal iWhat's Vim?\<CR>"
    update
    Expect &filetype ==# ''
  end

  it 'sets the filetype of original buffer as the filetype of preview window'
    setlocal filetype=markdown
    normal jVj;E
    update
    Expect &filetype ==# 'markdown'
    setlocal filetype=
    pclose!
  end

  it 'reflects back to a original buffer when a buffer in preview window is edited and saved'
    normal jVj;E
    execute "normal jiWhat's Vim?\<CR>"
    update
    pclose!
    Expect getline(1, '$') ==# insert(copy(g:lines), 'What''s Vim?', 2)
  end
end


describe 'Integration testing: <Plug>(operator-pedit-edit-contextually) with <Plug>(textobj-context-i)'
  before
    let g:lines_nested = [
          \ '```vim',
          \ 'echo "Vim!"',
          \ 'ruby <<EOM',
          \ '  puts "Ruby!"',
          \ 'EOM',
          \ '```'
          \]
    new
    put = g:lines_nested
    1 delete _

    map ;e <Plug>(operator-pedit-edit-contextually)
  end

  it 'works fine even if the markup of code block in markdown is nested'
    setlocal filetype=markdown
    normal j;eicx
    Expect &filetype ==# 'vim'
    Expect getline(1, '$') ==# [
          \ 'echo "Vim!"',
          \ 'ruby <<EOM',
          \ '  puts "Ruby!"',
          \ 'EOM',
          \]

    normal 2j;eicx
    Expect &filetype ==# 'ruby'
    Expect getline(1, '$') ==# [
          \ '  puts "Ruby!"',
          \]

    pclose!
    setlocal filetype=
  end

  it 'works fine even if the markup of code block in markdown is nested and the fileencoding and fileformat are changed by autocmd'
    augroup t-pedit
      autocmd!
      autocmd FileType markdown,ruby setlocal fileencoding=latin1 fileformat=unix
      autocmd FileType vim setlocal fileencoding=cp932 fileformat=dos
    augroup END

    setlocal filetype=markdown
    call append(4, '  puts "ルビーは宝石の名前です。"')

    normal j;eicx
    Expect &filetype ==# 'vim'
    Expect &fileencoding ==# 'cp932'
    Expect &fileformat ==# 'dos'
    Expect getline(1, '$') ==# [
          \ 'echo "Vim!"',
          \ 'ruby <<EOM',
          \ '  puts "Ruby!"',
          \ '  puts "ルビーは宝石の名前です。"',
          \ 'EOM',
          \]

    normal 2j;eicx
    Expect &filetype ==# 'ruby'
    Expect &fileencoding ==# 'latin1'
    Expect &fileformat ==# 'unix'
    Expect getline(1, '$') ==# [
          \ '  puts "Ruby!"',
          \ '  puts "ルビーは宝石の名前です。"',
          \]

    pclose!
    augroup t-pedit
      autocmd!
    augroup END
  end
end
