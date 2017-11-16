---
title: Centos安装配置powerline
date: 2017-09-29 16:23:47
tags: [POWERLINE]
---
## 介绍

Powerline是vim编辑器的插件，它是Python开发的，为多个应用（bash，zsh，tmux等）提供statusline。

<!-- more -->

## 安装

安装pip：
```
yum install python-pip -y
```

安装powerline

```
pip install git+git://github.com/powerline/powerline
```

安装Powerline字体：

```
wget https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf
wget https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf
mv PowerlineSymbols.otf /usr/share/fonts/
fc-cache -vf /usr/share/fonts/            //更新系统的字体缓存
mv 10-powerline-symbols.conf /etc/fonts/conf.d/
```

## 在Bash中启用Powerline

查看powerline安装位置
![image](http://mufool.qiniudn.com/powerline/powerline1.jpg)

可以看到安装位置在`/usr/lib/python2.6/site-packages`下

在~/.bashrc中添加

```
powerline-daemon -q
POWERLINE_BASH_CONTINUATION=1
POWERLINE_BASH_SELECT=1
. /usr/lib/python2.6/site-packages/powerline/bindings/bash/powerline.sh
```

`source ~/.bashrc`生效

重启终端即可看到效果。

![image](http://mufool.qiniudn.com/powerline/powerlinel4.jpg)

## 在vim中启用powerline

在.vimrc文件中添加即可

```
set rtp+=/usr/lib/python2.6/dist-packages/powerline/bindings/vim/
set laststatus=2
set t_Co=256
```
![image](http://mufool.qiniudn.com/powerline/powerline2.jpg)

## 在zsh中启用powerline

与bash中类似，在.zshrc中添加

```
export TERM=xterm-256color
source /usr/lib/python2.6/site-packages/powerline/bindings/zsh/powerline.zsh
```
`source ~/.zshrc`生效。

参考：
[安装使用Powerline：Vim和Bash终端的状态栏](http://blog.topspeedsnail.com/archives/2652)
