if has('statusline')
  set showmode                  " Display mode
  set laststatus=2              " Always display statusline
  set statusline=%#Comment#
  set statusline+=%.40f         " Filename
  set statusline+=\ %m          " Modified flag
  set statusline+=%#NonText#
  set statusline+=%=            " Separator
  set statusline+=%y            " Filetype
  set statusline+=\ %P          " Scroll location
  set statusline+=\ %-6(%l:%c%) " Line:Col
endif
