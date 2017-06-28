---
layout: post
title: VIM插件安装使用
date: 2016-07-08 12:51:40
tags: [VIM]
---

VIM是什么。代码开发的人都应该知道，特别是在linux下搞开发的人。这是一个强大的文本编辑工具，可以与任何windows下的IDE相媲美，甚至功能更加强大。而且所有的功能都能自己订制，只要你需要。
<!-- more -->

## 为什么要使用VIM
首先，VIM是一个强大的编辑工具，他能明显的提高你的代码编写效率，初期上手可能比较困难，但是工欲善其事、必先利其器，花一些时间来安装、配置和学习VIＭ是完全值得的。

其次，用VIM进行代码开发，能够保证代码开发的质量。无论是代码格式上还是对代码整体功能上讲，用VIM开发绝对是有百利而无一害。

再次，作为一个搞Linux服务器开发的人，有了VIM才更显的专业。VIM是程序猿第一装逼利器。

另外，还有很多优点，比如在安装配置的整个过程中，你也能学习一下国外的优秀软件是这么设计的，同时也能证明自己的动手能力和解决问题的能力。

## 基本概念：
1. Vim存在多个配置文件vimrc，比如/etc/vimrc，此文件影响整个系统的Vim。还有~/.vimrc，此文件只影响本用户的Vim。而且~/.vimrc文件中的配置会覆盖/etc/vimrc中的配置。这里我们只修改~/.vimrc文件，此文件需要再用户目录下手动创建。
2. Vim的插件（plugin）安装在Vim的runtimepath目录下，你可以在Vim命令行下运行"set rtp“命令查看。这里我们选择安装在~/.vim目录，没有就创建一个。
3. Vim的插件安装方式分为两种一种是编译安装，一种直接解压即可。Ctags和Cscope（如果没有）需要编译安装，其余直接解压即可。
4. 插件下载地址均为Vim官网，如无法打开请翻墙。
5. 解压安装的插件在解压完成后需要进入~/.vim/doc目录，在Vim下运行"helptags ."命令。此步骤是将doc下的帮助文档加入到Vim的帮助主题中，这样我们就可以通过在Vim中查看帮助。

## 相关插件及功能简介
* [Taglist](http://www.vim.org/scripts/script.php?script_id=273) : 用来提供单个源代码文件的函数列表之类的功能;
* [NERDTree](http://www.vim.org/scripts/script.php?script_id=1658) : 提供展示文件/目录列表的功能;
* [Cscope](http://cscope.sourceforge.net/cscope_maps.vim) : 比ctags更加强大的功能，举个例子，ctags只能分析出这个函数在哪里被定义，而cscope除了这一点之外，还能分析出这个函数再哪里被调用。
* [Ctags](http://ctags.sourceforge.net/) : 实现了c、c++、java、c#等语言的智能分析，并生成tags文件，后面所有的包括函数列表显示，变量定义跳转，自动补全等，都要依赖于他。有了tags文件后，只需要在变量上按下 CTRL + ]键，就可以自动跳到变量定义的位置
* [NERD_commenter](http://www.vim.org/scripts/script.php?script_id=1218) : 提供快速注释/反注释代码块的功能
* [Omnicppcomplete](http://www.vim.org/scripts/script.php?script_id=1520) : 提供C++代码的自动补全功能
* [SuperTab](http://www.vim.org/scripts/script.php?script_id=1643) : 使Tab快捷键具有更快捷的上下文提示功能
* [Winmanager](http://www.vim.org/scripts/script.php?script_id=95) : 提供多文件同时编辑功能
* [MiniBufExplorer](http://www.vim.org/scripts/script.php?script_id=159) :  将这NERDTree界面和Taglist界面整合起来，使Vim更像VS
* [VIM7.3](file:///C:/Users/Jason/Documents/My%20Knowledge/temp/wget%20ftp://ftp.vim.org/pub/vim/unix/vim-7.3.tar.bz2) : 7.0及以下版本autocomplpop无法使用
* [AutoComplPop](http://www.vim.org/scripts/script.php?script_id=1879) : 让自动完成的选项在你输入时就自动出现，并且随着你输入的内容不断过滤选项。
* [a.vim](http://www.vim.org/scripts/script.php?script_id=31) : .cpp和.h文件快速切换,直接可以:A，打开.cpp和.h对应的文件，:AV，打开.cpp和.h对应的文件，并且分屏.
* [SnipMate](http://www.vim.org/scripts/script.php?script_id=2540) : 代码块的自动补全.
* [c.vim](http://www.vim.org/scripts/script.php?script_id=213) : 文件添加注释和说明。
* [bufexplorer](http://www.vim.org/scripts/script.php?script_id=42) ： 打开历史文件列表以达到快速切换文件的目的。命令模式下输入\be或:BufExplorer进入Buffer列表。
* [mark.vim]() : 提供高亮功能，安装方法vim mark.vba.gz :so %

## vim安装与卸载
vim安装有两个方法：yum安装和编译安装

方法一：yum安装vim

```
$ yum install vim* -y
```

主要包括vim-common.i386、vim-enhanced.i386、vim-minimal.i386这三个包。此方法为默认安装的版本，centos5.9为7.0的VIM，建议采用第二种方法手动下载安装。

方法二：下载、解包
```
$ wget ftp://ftp.vim.org/pub/vim/unix/vim-7.3.tar.bz2
$ tar jxvf vim-7.3.tar.bz2
```
编译安装
```
$ cd vim73/src
$ ./configure --enable-multibyte \--with-features=huge \--disable-selinux
$ make
$ sudo make install
```
测试
```
$ vim --version
```

卸载
```
$ yum remove vim vim-enhanced vim-common vim-minimal
```
安装VIM中文帮助文档：
```
$ wget http://sourceforge.net/projects/vimcdoc/files/vimcdoc/1.8.0/vimcdoc-1.8.0.tar.gz
$ tar zxvf vimcdoc-1.8.0.tar.gz
$ cd vimcdoc-1.8.0/
$ ./vimcdoc.sh -I
```

## 插件安装

### 安装使用Ctag

Ctags工具是用来遍历源代码文件生成tags文件，这些tags文件能被编辑器或其它工具用来快速查找定位源代码中的符号（tag/symbol），如变量名，函数名等。比如，tags文件就是Taglist和OmniCppComplete工作的基础。

解压缩生成源代码目录，
然后进入源代码根目录执行./configure，
然后执行make,
编译成功后执行make install。

到此，Ctags已安装成功。
使用Ctags的也很简单。 进入我们的项目代码根目录，执行以下命令：
```
$ ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .
```
有两组快捷键是最常用的。
```
$ Ctrl-]    跳转到光标所在符号的定义。
$ Ctrl-t    回到上次跳转前的位置。
```

### 安装使用Cscope

Cscope提供交互式查询语言符号功能，如查询哪些地方使用某个变量或调用某个函数。Cscope已经是Vim的标准特性，默认都有支持，官方网址为http://cscope.sourceforge.net/。
* 在Vim下运行version查看Vim支持哪些特性，前面有前缀符号+的为支持。如果支持Cscope，则直接进入2），否则下载Cscope源代码包编译安装。步骤同Ctags安装。
* 确定Vim已支持Cscope后，将文件cscope_maps.vim下载到~/.vim/plugin目录。

到这里，我们就可以开始使用Cscope了。
使用Cscope需要生成cscope数据库文件。进入项目代码根目录运行命令：
```
$ cscope -Rbq -f xxx.out
```

命令运行后会生成xxx.out文件，即cscope数据库文件。更多用法参考man cscope文档。
进入项目代码根目录，在Vim下运行命令，或者添加到文件.vimrc：
```
$ cs add xxx.out
```

此命令将cscope数据库载入Vim。
如出现重复装载索引问题，请[按此](http://blog.csdn.net/carlalovedog/article/details/6634042)操作即可。

### 安装使用OmniCppComplete

OmniCppComplete主要提供输入时实时提供类或结构体的属性或方法的提示和补全。跟Talist一样，OmniCppComplete也是一个Vim插件，同样依赖与Ctags工具生成的tags文件。安装步骤跟Taglist类似。与VS的VA功能类似，但是只会不全类或者结构体等。不具有普通变量的补全提示功能。

### 安装使用SuperTab

SuperTab使Tab快捷键具有更快捷的上下文提示功能。跟OmniCppComplete一样，SuperTab也是一个Vim插件。 这个安装包跟先前的几个Vim插件不同，它是一个vba文件，即Vimball格式的安装包，这种格式安装包提供傻瓜式的安装插件的方法。

* 用Vim打开.vba安装包文件。
* 在Vim命令行下运行命令“UseVimball ~/.vim”。此命令将安装包解压缩到~/.vim目录。Vimball安装方式的便利之处在于你可以在任何目录打开.vba包安装，而不用切换到安装目的地目录。而且不用运行helptags命令安装帮助文档。
 
### 其余插件解压安装即可。
 
