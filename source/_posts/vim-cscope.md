---
layout: post
title: vim插件cscope
date: 2016-07-07 12:51:40
tags: [VIM]
---

### cscope生成数据库参数

```
	cscope –Rbq
```

这个命令会生成三个文件：cscope.out, cscope.in.out, cscope.po.out,其中cscope.out是基本的符号索引，后两个文件是使用"-q"选项生成的，可以加快cscope的索引速度。

在缺省情况下，cscope在生成数据库后就会进入它自己的查询界面，我们一般不用这个界面，所以使用了“-b”选项。如果你已经进入了这个界面，按CTRL-D退出。

Cscope在生成数据库中，在你的项目目录中未找到的头文件，会自动到/usr/include目录中查找。如果你想阻止它这样做，使用“-k”选项。

<!-- more -->

Cscope缺省只解析C文件(.c和.h)、lex文件(.l)和yacc文件(.y)，虽然它也可以支持C++以及Java，但它在扫描目录时会跳过C++及Java后缀的文件。如果你希望cscope解析C++或Java文件，需要把这些文件的名字和路径保存在一个名为cscope.files的文件。当cscope发现在当前目录中存在cscope.files时，就会为cscope.files中列出的所有文件生成索引数据库。

使用“-R”参数，因为在cscope.files中已经包含了子目录中的文件。

Cscope只在第一次解析时扫描全部文件，以后再调用cscope，它只扫描那些改动过的文件，这大大提高了cscope生成索引的速度。

```
	-R: 在生成索引文件时，搜索子目录树中的代码
	-b: 只生成索引文件，不进入cscope的查询界面
	-q: 生成cscope.in.out和cscope.po.out文件，加快cscope的索引速度
	-k: 在生成索引文件时，不搜索/usr/include目录
	-i: 如果保存文件列表的文件名不是cscope.files时，需要加此选项告诉cscope到哪儿去找源文件列表。可以使用“-”，表示由标准输入获得文件列表。
	-I dir: 在-I选项指出的目录中查找头文件
	-u: 扫描所有文件，重新生成交叉索引文件
	-C: 在搜索时忽略大小写
	-P path: 在以相对路径表示的文件前加上的path，这样，你不用切换到你数据库文件所在的目录也可以使用它了。
```

### 使用参数

```
	s: 查找C语言符号，即查找函数名、宏、枚举值等出现的地方
	g: 查找函数、宏、枚举等定义的位置，类似ctags所提供的功能
	d: 查找本函数调用的函数
	c: 查找调用本函数的函数
	t: 查找指定的字符串
	e: 查找egrep模式，相当于egrep功能，但查找速度快多了
	f: 查找并打开文件，类似vim的find功能
	i: 查找包含本文件的文件
```

### vim添加快捷键
```
	nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
	nmap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
	nmap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
	nmap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>
	nmap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>
	nmap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
	nmap <C-\>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
	nmap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>
```
