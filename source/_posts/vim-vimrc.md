
---
layout: post
title: vim配置文件
date: 2016-07-06 20:08:17
tags: [VIM]
---

## vimrc完整配置

<!-- more -->
```
"Use Vim settings, rather than Vi settings (much better!).
"This must be first, because it changes other options as a side effect.
"Without no where use Vi settings, but when load vim settting it will be wrong.
" Or set nocp.
set nocompatible

set helplang=cn 					" set help doc language
set incsearch 						" search when input not complete
set history=1000					" history文件中需要记录的行数

if has("vms")
  set nobackup						" do not keep a backup file, use versions instead
else
  set backup						" keep a backup file
endif

" ===================================================================
"set paste							" must not add, or auto complete will not use
" ===================================================================

syntax enable
syntax on							" 让语法高亮显示
filetype on							" 侦测文件类型
filetype plugin on					" 允许插件
filetype indent on					" 为特定文件类型载入相关缩进文件
filetype plugin indent on			" 启动自动补全
set iskeyword+=_,$,@,%,#,-			" 带有如下符号的单词不要被换行分割

" ===================================================================
" set shortmess=atI					" 启动的时候不显示那个援助索马里儿童的提示
set autoread						" Set to auto read when a file is changed from the outside
nnoremap <F2> :set nonumber!<CR>:set foldcolumn=0<CR>
									" 为方便复制，用<F2>开启/关闭行号显示
nnoremap <F3> :set nolist!<CR>		
									" 为方便复制，用<F3>开启/关闭set list
nnoremap <F4> :set nohls!<CR>		
									" 为方便复制，用<F4>取消高亮
map <leader>e :e! ~/.vimrc<cr>		
									" Fast editing of the .vimrc
set ffs=unix,dos,mac				
									" Use Unix as the standard file type
autocmd! bufwritepost .vimrc source ~/.vimrc
									" When vimrc is edited, reload it
set scrolloff=7						" 光标到上下各7行的时候不在移动

" normal===============================================================
" set nowrap						" 不要换行$
" set cursorline					" 突出显示当前行
set number							" 显示行号
set autoindent						" 自动对齐
set cindent							" 使用C风格的缩进方案
" set smartindent					" 比autoindent稍智能的自动缩进
set softtabstop=4					" 按退格键时可以一次删掉 4 个空格
set tabstop=4						" tab为4个空格
set shiftwidth=4					" 当前行之间交错时使用4个空格
set showmatch						" 插入括号时，短暂地跳转到匹配的对应括号
set matchtime=2						" 短暂跳转到匹配括号的时间
set background=dark					" 让深色的字体高亮显示（例如：注释等）
set listchars=tab:>-,trail:-,extends:>,precedes:< ",eol:$
									" 将制表符显示为'>---',将行尾空格显示为'-'
set nobackup

set noerrorbells					" 关闭错误信息响铃
set novisualbell					" 关闭使用可视响铃代替呼叫
set vb t_vb=						" 当vim进行编辑时，如果命令错误，会发出警报，该设置去掉警报
set showcmd							" 在状态栏显示正在输入的命令
set ruler							" 在编辑过程中，在右下角显示光标位置的状态行
set magic							" 设置魔术,正则匹配
set ignorecase smartcase			" 搜索时忽略大小写，但在有一个或以上大写字母时仍保持对大小写敏感
"set nowrapscan						" 禁止在搜索到文件两端时重新搜索
set incsearch						" 输入搜索内容时就显示搜索结果
set hlsearch						" 搜索时高亮显示被找到的文本
set cmdheight=4						" 设置命令行的高度
set list
"colo evening						" setting colors from vim
set cmdheight=1						" 设定命令行的行数为 1
set laststatus=2					" 显示状态栏 (默认值为 1, 无法显示状态栏)
set formatoptions=rq				" 注释格式化选项

" setting fron fold===================================================
set foldenable						" 开始折叠
set foldmethod=syntax				" 设置语法折叠
set foldlevel=100					" 设置折叠层数为,设置此选项为零关闭所有的折叠。更高的数字关闭更少的折叠。
nnoremap <space> @=((foldclosed(line('.')) < 0) ? 'zc' : 'zo')<CR>
									" 用空格键来开关折叠
set foldcolumn=0					" 在左侧显示折叠的层次
"set foldclose=all					" 设置为自动关闭折叠
"colorscheme colorzone				" 设定配色方案
"colorscheme molokai				" 设定配色方案
set foldexpr=2						" 设置代码块折叠后显示的行数

" ======================================================================
" Only do this part when compiled with support for autocommands.
if has("autocmd")
  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on
  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!
  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78
  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif
  augroup END
else

    set autoindent        " always set autoindenting on

endif " has("autocmd")

" setting for building c/c++ program===============================
" C的编译和运行
map <F5> :call CompileRunGcc()<CR>
func! CompileRunGcc()
	exec "w"
	exec "!gcc % -o %<"
	exec "! ./%<"
endfunc

" C++的编译和运行
map <F6> :call CompileRunGpp()<CR>
func! CompileRunGpp()
	exec "w"
	exec "!g++ % -o %<"
	exec "! ./%<"
endfunc

" setting for backspace==============================================
set backspace=indent,eol,start				" allow backspacing over everything in insert mode
set whichwrap+=<,>,h,l

"setting for taglist=================================================
let Tlist_Ctags_Cmd='ctags'
let Tlist_Show_One_File=1					" 不同时显示多个文件的tag，只显示当前文件的
let Tlist_Exit_OnlyWindow=1					" 如果taglist窗口是最后一个窗口，则退出vim
let Tlist_Use_Right_Window=1				" 在右侧窗口中显示taglist窗口
let Tlist_Auto_Update=1						" update tags automatically
let Tlist_Auto_Highlight_Tag=1
let Tlist_Highlight_Tag_On_BufEnter=1		" highlight on current tag
let Tlist_Show_Menu=0						" show tags menu
let Tlist_Auto_Highlight_Tag=1
map <C-]> g<C-]>
"map <C-]> :tag<cr>
"let Tlist_Auto_Open = 1					" open tablist automatically
"let Tlist_Close_On_Select=1				" close tablist on select
"let Tlist_WinHeight=50
let Tlist_WinWidth=30
map <silent><leader>tl :TlistToggle<cr>

"setting for filebuffer switch=========================================
nmap <C-N> :bnext<CR>
nmap <C-P> :bprevious<CR>

"setting for windows===================================================
nmap <C-h> <C-w>h
nmap <C-j> <C-w>j
nmap <C-k> <C-w>k
nmap <C-l> <C-w>l

"set mark==============================================================
nmap <silent> <leader>hl <Plug>MarkSet
vmap <silent> <leader>hl <Plug>MarkSet
nmap <silent> <leader>hh <Plug>MarkClear
vmap <silent> <leader>hh <Plug>MarkClear
nmap <silent> <leader>hr <Plug>MarkRegex
vmap <silent> <leader>hr <Plug>MarkRegex

"setting for minibufexpl===============================================
let g:miniBufExplorerMoreThanOne=1			 " 即使只有一个文件，也显示minibuf窗口
let g:miniBufExplMapWindowNavVim=1
let g:miniBufExplMapWindowNavArrows=1
let g:miniBufExplMapCTabSwitchBufs=1
let g:miniBufExplModSelTarget=1

"setting for NERD tree=================================================
nmap <silent> <leader>tt :NERDTreeToggle<cr>
let NERDTreeWinSize=30
"autocmd VimEnter * NERDTree				" 在 vim 启动的时候默认开启 NERDTree（autocmd 可以缩写为 au）
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
											" if the last window is NERDTree, then close Vim
"let NERDTreeWinPos="right"					" 将 NERDTree 的窗口设置在 vim 窗口的右侧（默认为左侧）
let NERDChristmasTree=1						" 让树更好看,真心没发现啊
let NERDTreeDirArrows=0

"setting for winmanager==============================================
let g:winManagerWindowLayout = "FileExplorer,BufExplorer|TagList"
let g:winManagerWidth=30
let g:defaultExplorer=0
nmap <silent> <leader>wm :WMToggle<cr>

"setting for omnicppcomplete========================================
let OmniCpp_GlobalScopeSearch = 1  " 0 or 1
let OmniCpp_NamespaceSearch = 1   " 0 ,  1 or 2
let OmniCpp_DisplayMode = 1
let OmniCpp_ShowScopeInAbbr = 0
let OmniCpp_ShowPrototypeInAbbr = 1
let OmniCpp_ShowAccess = 1
let OmniCpp_MayCompleteDot = 1
let OmniCpp_MayCompleteArrow = 1
let OmniCpp_MayCompleteScope = 1
"let g:SuperTabRetainCompletionType=2
"let g:SuperTabDefaultCompletionType="<C-X><C-O>"
set completeopt=longest,menu

"setting for cscope+ctags===========================================
if filereadable("cscope.out")
    cs add cscope.out
endif
cs add ~/p2p_server/branches/taishan/server/framecommon/src/cscope.out ~/p2p_server/branches/taishan/server/framecommon/src/
cs add ~/p2p_server/branches/taishan/server/srvframe/src/cscope.out ~/p2p_server/branches/taishan/server/srvframe/src/
set tags+=~/.vim/cpp_src/tags
set tags+=/usr/include/tags
set tags+=~/p2p_server/branches/taishan/server/framecommon/src/tags
set tags+=~/p2p_server/branches/taishan/server/srvframe/src/tags

nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
nmap <C-\>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
nmap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>

"setting for multi-encoding ========================================
if has("multi_byte")
  "set bomb
  set fileencodings=ucs-bom,utf-8,cp936,big5,euc-jp,euc-kr,latin1
  " CJK environment detection and corresponding setting
  if v:lang =~ "^zh_CN"
    " Use cp936 to support GBK, euc-cn == gb2312
    set encoding=cp936
    set termencoding=cp936
    set fileencoding=cp936
  elseif v:lang =~ "^zh_TW"
    " cp950, big5 or euc-tw
    " Are they equal to each other?
    set encoding=big5
    set termencoding=big5
    set fileencoding=big5
  elseif v:lang =~ "^ko"
    " Copied from someone's dotfile, untested
    set encoding=euc-kr
    set termencoding=euc-kr
    set fileencoding=euc-kr
  elseif v:lang =~ "^ja_JP"
    " Copied from someone's dotfile, untested
    set encoding=euc-jp
    set termencoding=euc-jp
    set fileencoding=euc-jp
  endif
  " Detect UTF-8 locale, and replace CJK setting if needed
  if v:lang =~ "utf8$" || v:lang =~ "UTF-8$"
    set encoding=utf-8
    set termencoding=utf-8
    set fileencoding=utf-8
  endif
else
  echoerr "Sorry, this version of (g)vim was not compiled with multi_byte"
endif
```
