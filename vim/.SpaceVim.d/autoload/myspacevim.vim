func! myspacevim#before() abort
    " 开启自动缩进
    set autoindent

    " 焦点消失的时候自动保存
    au FocusLost * :wa
    au FocusGained,BufEnter * :checktime
    " 当文件被其他编辑器修改时，自动加载
    set autowrite
    set autoread

    " 让file tree 显示文件图标，需要 terminal 安装 nerd font
    let g:spacevim_enable_vimfiler_filetypeicon = 1

    " Airline 替代 statusline, 部分配置在boootstrap_after
    call SpaceVim#layers#disable('core#statusline')
    call SpaceVim#layers#disable('core#tabline')

    " OceanicNext statusline
    if (has("termguicolors"))
      set termguicolors
    endif
    syntax enable
    let g:oceanic_next_terminal_bold = 1
    let g:oceanic_next_terminal_italic = 1
    let g:airline_theme='OceanicNext'

endf
