---
layout: post
title: NERDTree快捷键
date: 2016-07-08 12:51:40
tags: [VIM]
---

## 文件操作

```
	" ============================
	" File node mappings~
	double-click, <CR>, o: open in prev window	在已有窗口中打开文件、目录或书签，并跳到该窗口
	go: preview	在已有窗口 中打开文件、目录或书签，但不跳到该窗口
	t: open in new tab	在新Tab中打开选中文件/书签，并跳到新Tab
	T: open in new tab silently	在新Tab中打开选中文件/书签，但不跳到新Tab
	middle-click, i: open split	split一个新窗口打开选中文件，并跳到该窗口
	gi: preview split	split一个新窗口打开选中文件，但不跳到该窗口
	s: open vsplit	vsp一个新窗口打开选中文件，并跳到该窗口
	gs: preview vsplit	vsp一个新 窗口打开选中文件，但不跳到该窗口
```
<!-- more -->

## 目录操作
```
	" ----------------------------
	" Directory node mappings~
	double-click, o: open & close node	开关闭节点
	O: recursively open node	递归打开选中 结点下的所有目录
	x: close parent of node	合拢选中结点的父目录
	X: close all child nodes of current node recursively	递归合拢选中结点下的所有目录
	middle-click, e: explore selected dir	浏览当前目录下
```

## 书签操作
```
	" ----------------------------
	" Bookmark table mappings~
	double-click,o: open bookmark
	t: open in new tab
	T: open in new tab silently
	D: delete bookmark
```

## 节点跳转
```
	" ----------------------------
	" Tree navigation mappings~
	P: go to root	跳到根结点
	p: go to parent	跳到父结点
	K: go to first child	跳到当前目录下同级的第一个结点
	J: go to last child	跳到当前目录下同级的最后一个结点
	<C-j>: go to next sibling	跳到当前目录下同级的前一个结点
	<C-k>: go to prev sibling	跳到当前目录下同级的后一个结点
```

## 文件系统操作
```
	" ----------------------------
	" Filesystem mappings~
	C: change tree root to the selected dir	将选中目录或选中文件的父目录设为根结点
	u: move tree root up a dir	将当前根结点的父目录设为根目录，并变成合拢原根结点
	U: move tree root up a dir but leave old root open	将当前根结点的父目录设为根目录，但保持展开原根结点
	r: refresh cursor dir	递归刷新选中目录
	R: refresh current root	递归刷新根结点
	m: Show menu	显示文件系统菜单
	cd:change the CWD to the selected dir	将CWD设为选中目录
```

## 切换显示
```
	" ----------------------------
	" Tree filtering mappings~
	I: hidden files (off)
	f: file filters (on)
	F: files (on)
	B: bookmarks (off)
```

## 其他操作
```
	" ----------------------------
	" Other mappings~
	q: Close the NERDTree window	关闭NerdTree窗口
	A: Zoom (maximize-minimize) the NERDTree window
	?: toggle help
```

## 书签命令
```
    " ----------------------------
    " Bookmark commands
    :Bookmark <name>	将选中结点添加到书签列表中，并命名为name（书签名不可包含空格）；如与现有书签重名，则覆盖现有书签
    :BookmarkToRoot <name>	以指定目录书签或文件书签的父目录作为根结点显示NerdTree
    :RevealBookmark <name>	如果指定书签已经存在于当前目录树下，打开它的上层结点并选中该书签 
    :OpenBookmark <name>	打开指定的文件。（参数必须是文件书签）如果该文件在当前的目录树下，则打开它的上层结点并选中该书签
    :ClearBookmarks [<names>]	清除指定书签；如未指定参数，则清除所有书签
    :ClearAllBookmarks	清除所有书签
```

## 切换标签页
```
    :tabnew [++opt选项] ［＋cmd］ 文件	建立对指定文件新的tab
    :tabc   关闭当前的 tab
    :tabo   关闭所有其他的 tab
    :tabs   查看所有打开的 tab
    :tabp   前一个 tab
    :tabn   后一个 tab
```

标准模式下： gt , gT 可以直接在tab之间切换。

## vim相关设置
```
    "setting for NERD tree=================================================
    nmap <silent> <leader>tt :NERDTreeToggle<cr>
    let NERDTreeWinSize=30
    autocmd VimEnter * NERDTree	在vim 启动的时候默认开启 NERDTree（autocmd 可以缩写为 au）
    autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif	if the last window is NERDTree, then close Vim
    let NERDTreeWinPos="right"	将 NERDTree 的窗口设置在 vim 窗口的右侧（默认为左侧）
    let NERDChristmasTree=1	让树更好看,真心没发现啊
    let NERDTreeDirArrows=0
```
