---
title: zsh安装使用
date: 2017-09-22 16:12:55
tags: [LINUX]
---
## zsh介绍

Zsh 也许是目前最好用的 shell，是 bash 替代品中较为优秀的一个，号称终极shell。

<!-- more -->

## zsh安装

```
yum install zsh -y
```

## zsh配置

### oh-my-zsh配置

oh-my-zsh是为了简化zsh的配置而提供的一个配置模板，可以更好的管理zsh的各项配置

通过curl安装
```
curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
```
通过wget安装
```
wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O - | sh
```

手动安装

克隆仓库里面的代码
```
git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
```

创建一个新的zsh配置文件
```
cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
```

改变默认的shell
```
chsh -s /bin/zsh
```

如不生效，则在~/.bashrc最后添加
```
bash -c zsh
```

### 主题配色

～/.oh-my-zsh/themes目录下面的任意文件都可以作为主题，如果都不喜欢可以选择自己定义，参照[linux环境变量设置 (PS1，PS2)](http://blog.csdn.net/lushujun2011/article/details/7351926)。

## 插件介绍

安装好 zsh 和 oh-my-zsh 后，打开文件~/.zshrc，其中有如下行`plugins=(git)`，需要添加插件，直接空格分割当道后面即可。

### extract
功能强大的解压插件，所有类型的文件解压一个命令x全搞定。

### z
强大的目录自动跳转命令，会记忆你曾经进入过的目录，用模糊匹配快速进入你想要的目录。类似的有autojump，fasd等
```
bogon :: ~ » cd /opt/video1 
bogon :: /opt/video1 » cd ~
bogon :: ~ » z video1
bogon :: /opt/video1 » 
```
大量的插件会拖慢打开的速度，开启需谨慎。

## 使用技巧
- zsh完全兼容bash
- 连按两次Tab会列出所有的补全列表并直接开始选择，补全项可以使用 ctrl+n/p/f/b上下左右切换
- 命令选项补全。在zsh中只需要键入 tar -<tab> 就会列出所有的选项和帮助说明
- 命令参数补全。键入 kill <tab> 就会列出所有的进程名和对应的进程号
- 命令历史记录，可以用 !!来执行上一条命令，使用 ctrl-r 来搜索命令历史记录
- 命令不全，命令和文件补全(按tab键)
- 命令别名，在 .zshrc 中添加 alias shortcut='command' 一行就相当于添加了别名
- 更智能的历史命令。在用或者方向上键查找历史命令时，zsh支持限制查找。比如，输入ls,然后再按方向上键，则只会查找用过的ls命令。而此时使用则会仍然按之前的方式查找，忽略 ls
- 多个终端会话共享历史记录
- 智能跳转，安装了 autojump 之后，zsh 会自动记录你访问过的目录，通过 j 目录名 可以直接进行目录跳转，而且目录名支持模糊匹配和自动补全，例如你访问过 hadoop-1.0.0 目录，输入j hado 即可正确跳转。j --stat 可以看你的历史路径库。
- 目录浏览和跳转：输入 d，即可列出你在这个会话里访问的目录列表，输入列表前的序号，即可直接跳转。
- 在当前目录下输入 .. 或 ... ，或直接输入当前目录名都可以跳转，你甚至不再需要输入 cd 命令了。在你知道路径的情况下，比如 /usr/local/bin 你可以输入 cd /u/l/b 然后按进行补全快速输入
- 通配符搜索：ls -l **/*.sh，可以递归显示当前目录下的 shell 文件，文件少时可以代替 find。使用 **/ 来递归搜索
扩展环境变量，输入环境变量然后按 就可以转换成表达的值
- 在 .zshrc 中添加 setopt HIST_IGNORE_DUPS 可以消除重复记录，也可以利用 sort -t ";" -k 2 -u ~/.zsh_history | sort -o ~/.zsh_history 手动清除

参考：
[zsh主题](https://github.com/robbyrussell/oh-my-zsh/wiki/themes)
[zsh 全程指南](http://wdxtub.com/2016/02/18/oh-my-zsh/)
