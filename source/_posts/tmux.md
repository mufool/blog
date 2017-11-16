---
title: Tmux安装使用
date: 2017-09-29 15:24:41
tags: [TMUX]
---

## 介绍
Tmux是一个优秀的终端复用软件，支持多标签，也支持窗口内部面板的分割，更重要的是，Tmux提供了窗体随时保存和恢复的功能。想象一下假如你在公司的服务器上开了许多窗口调试程序，回到家时通过SSH连接公司电脑又要打开一堆繁琐的窗口，而且还忘记了当时调试到哪一步了，那Tmux可以帮你解决这个难题，当SSH连接断开重新连接后能够恢复到原来的工作环境。

<!-- more -->

## 安装

### 安装依赖包
```
yum -y install ncurses-devel #依赖包

# 版本需大于2.0.10-stable
wget --no-check-certificate https://github.com/downloads/libevent/libevent/libevent-2.0.21-stable.tar.gz
tar xzf libevent-2.0.21-stable.tar.gz
cd libevent-2.0.21-stable
./configure
make && make install
cd ../
```

### 安装tmux

从git上下载最新代码编译安装，参见[github](https://github.com/tmux/tmux)
```
$ git clone https://github.com/tmux/tmux.git
$ cd tmux
$ sh autogen.sh
$ CFLAGS="-I/usr/local/include" LDFLAGS="-L//usr/local/lib" ./configure #直接./configure会报错
# make && make install
```

### 运行

运行可能出现如下错误
```
tmux: error while loading shared libraries: libevent-2.0.so.5: cannot open shared object file: No such file or directory
```

建立一下符号链接即可

```shell
if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
    ln -s /usr/local/lib/libevent-2.0.so.5 /usr/lib64/libevent-2.0.so.5
else
    ln -s /usr/local/lib/libevent-2.0.so.5 /usr/lib/libevent-2.0.so.5
fi
```

启动如出现
```
lost server
```
重新安装解决

完成进入tmux进入软件，界面类似一个下方带有状态栏的终端。
![image](http://mufool.qiniudn.com/tmux/tmux1.jpg)

## 基本概念

Tmux基于典型的c/s模型，主要分为会话、窗口和面板三个元素：
* 服务器：输入tmux命令时就开启了一个服务器。
* Session：输入tmux后就创建了一个会话，一个会话是一组窗体的集合。
* Window：会话中一个可见的窗口。
* Pane:一个窗口可以分成多个面板。

![image](http://mufool.qiniudn.com/tmux/tmux2.jpg)
注：图片来自网络
图中左下角的3显示为当前会话，随后1 vim,2 bash,3 ssh 分别是3个窗口，蓝色bash表示当前窗口，图中用蓝色数字标记的1,2,3分别是bash窗口的三个面板。你还可以在tmux配置文件中给状态栏添加时间、天气等信息。

## 启动

第一次会产生一个新的 session 和 window ，在下方会显示其状态，如果意外断开 (detach) 连接，session 仍会在后台运行，每个窗口可以分为多个 pane 。

启动时的参数选项有：
- -2: 强制 tmux 假设终端支持 256 色。
- -8: 类似于 -2 ，不过是强制 tmux 假设终端支持 88 色。
- -c shell-command: 使用默认的 shell 执行命令，主要用于当 tmux 作为 login shell 时使用。
- -f file: 指定配置文件，默认检查 /etc/tmux.conf、~/.tmux.conf，如果有命令错误，则会直接退出。
- -V: 查看版本号。
默认 tmux 会创建的匿名的 session ，可以通过如下命令创建一个命名的 session ， Ctrl-b 是命令前缀(Command prefix)，通过前缀告知 tmux 下面的命令是发给 tmux 的，而非终端。常见的操作如下。
```
$ tmux new-session -s basic    # 创建一个名为 basic 的 session
$ tmux new -s basic -d        # 同上，但是不会连接到终端，在后台运行
$ tmux new -s basic -n win    # 同上，并将第一个窗口命令为 win

$ tmux ls                      # 列出现在的 sessions ，等同 tmux list-sessioin
$ tmux attach                  # 如果只有一个 session
$ tmux attach -t basic        # 指定名称，-t 表示 target

$ tmux kill-session -t basic  # 关闭一个 session
```

## 操作

基本操作

| 命令 | 操作 |
|--|--|
|?  |  列出所有快捷键；按q返回 |
|d  |  脱离当前会话,可暂时返回Shell界面，输入tmux attach能够重新进入之前会话 |
|s  |  选择并切换会话；在同时开启了多个会话时使用 |
|D  |  选择要脱离的会话；在同时开启了多个会话时使用 |
|:   | 进入命令行模式；此时可输入支持的命令，例如kill-server所有tmux会话 |
|[  |  复制模式，光标移动到复制内容位置，空格键开始，方向键选择复制，回车确认，q/Esc退出 |
|]  |  进入粘贴模式，粘贴之前复制的内容，按q/Esc退出 |
|~  |  列出提示信息缓存；其中包含了之前tmux返回的各种提示信息 |
|t   | 显示当前的时间 |
|Ctrl+z  |   挂起当前会话 |

窗口操作

| 命令 | 操作 |
|--|--|
|c | 创建新窗口 |
|& | 关闭当前窗口 |
|数字键 | 切换到指定窗口 |
|p | 切换至上一窗口 |
|n | 切换至下一窗口 |
|l | 前后窗口间互相切换 |
|w | 通过窗口列表切换窗口 |
|,  | 重命名当前窗口，便于识别 |
|.  | 修改当前窗口编号，相当于重新排序 |
|f  | 在所有窗口中查找关键词，便于窗口多了切换 |


面板操作

| 命令 | 操作 |
|--|--|
|“  |  将当前面板上下分屏 |
|%  |  将当前面板左右分屏 |
|x  |  关闭当前分屏 |
|!  |  将当前面板置于新窗口,即新建一个窗口,其中仅包含当前面板 |
|Ctrl+方向键  |  以1个单元格为单位移动边缘以调整当前面板大小 |
|Alt+方向键 |   以5个单元格为单位移动边缘以调整当前面板大小 |
|空格键  |  可以在默认面板布局中切换，试试就知道了 |
|q  |  显示面板编号 |
|o  |  选择当前窗口中下一个面板 |
|方向键  |  移动光标选择对应面板 |
|{  |  向前置换当前面板 |
|}  |  向后置换当前面板 |
|Alt+o  |  逆时针旋转当前窗口的面板 |
|Ctrl+o  |  顺时针旋转当前窗口的面板 |
|z  |  tmux 1.8新特性，最大化当前所在面板 |


## 配置

用户私人配置文件在~/.tmux.conf, 全局配置文件在 /etc/tmux.conf。修改这两处均可。

### 前缀修改
Tmux的所有操作必须使用一个前缀进入命令模式，默认前缀为ctrl+b，很多人会改为ctrl+a,你可以修改tmux.conf配置文件来修改默认前缀：

```
#前缀设置为<Ctrl-a>
set -g prefix C-a
#解除<Ctrl-b>
ubind C-b
```

### 配置更新

配置完以后，重启tmux起效，或者先按C+b，然后输入：，进入命令行模式， 在命令行模式下输入：
```
source-file ~/.tmux.conf
```
你也可以跟我一样，在配置文件中加入下面这句话，以后改了只需要按前缀+r了。
```
#将r 设置为加载配置文件，并显示"reloaded!"信息
bind r source-file ~/.tmux.conf \; display "Reloaded!"
```

### 复制模式copy-mode

- 前缀 [ 进入复制模式
- 按 space 开始复制，移动光标选择复制区域
- 按 Enter 复制并退出copy-mode。
- 将光标移动到指定位置，按 PREIFX ] 粘贴
如果把tmux比作vim的话，那么我们大部分时间都是处于编辑模式，我们复制的时候可不可以像 vim一样移动呢？只需要在配置文件(~/.tmux.conf)中加入如下行即可。
```
#copy-mode 将快捷键设置为vi 模式
setw -g mode-keys vi
```

### 开启批量执行

如果已经修改prefix键位Ctrl+a，则Ctrl+a[默认Ctrl+b]后输入:set synchronize-panes ，输入:set sync [TAB]键可自动补齐

### 脚本化启动

把以下脚本内容加入到~/.bashrc，即可每次登录进入到tmux
```
tmux_init()
{
tmux new-session -s "kumu" -d -n "local" # 开启一个会话
tmux new-window -n "other" # 开启一个窗口
tmux split-window -h # 开启一个竖屏
tmux split-window -v "top" # 开启一个横屏,并执行top命令
tmux -2 attach-session -d # tmux -2强制启用256color，连接已开启的tmux
}
```

### 自动关联session

判断是否已有开启的tmux会话，没有则开启，有则关联当前一打开的会话
```
if which tmux 2>&1 >/dev/null; then
test -z "$TMUX" && (tmux attach || tmux_init)
fi
```

### 滚动
使用下列快捷键可以进入滚动模式:
```
Ctrl-b [
```
这会使你进入滚动模式,然后你可以使用上下键或翻页键进行滚动,翻页.
```
Ctrl-b PageUp
```
这个快捷键会使你立即进入滚动模式,并向上翻页.


### 自定义状态栏
[TMUX 自定义配置](http://note4code.com/2016/07/03/tmux-%E8%87%AA%E5%AE%9A%E4%B9%89%E9%85%8D%E7%BD%AE/)

```
set-option -g status on
#set -g status-bg blue # 状态栏背景颜色
set -g status-bg '#333333'
#set -g status-fg '#bbbbbb' # 状态栏前景颜色
set -g status-fg '#ffffff'
set-option -g status-interval 2 # 设置自动刷新的时间间隔
set-option -g status-justify "centre" # 状态栏对齐
set -g status-left-fg green
set -g status-left-bg blue
set -g status-right-fg green
set -g status-right-bg blue
set-option -g status-left-length 60 # 状态栏左侧宽度
set-option -g status-right-length 90 # 状态栏右侧宽度
#set-option -g status-left "#(~/tmux-powerline/powerline.sh left)" 通过插件管理
#set-option -g status-right "#(~/tmux-powerline/powerline.sh right)"

set -g status-left '[#(whoami),#H]'
#set -g status-left '#[bg=#00bb00] [#S] #[default] ' # 状态栏左侧显示 session 的名字
set -g status-right '[#(date +"%Y-%m-%d %H:%M:%S ")]' # 状态栏右侧显示时间
#set -g status-right '#[fg=white,bg=#55bb00] [#h] #[fg=white,bg=#009c00] %Y-%m-%d #[fg=white,bg=#007700] %H:%M:%S '
#set -g status-right '#[fg=white,bg=#444444] [#h] #[fg=white,bg=#666666] %Y-%m-%d #[fg=white,bg=#888888] %H:%M:%S '

#set -g window-status-format '#I #W' # 未激活每个窗口占位的格式
setw -g window-status-format '#[bg=#0000ff, fg=#ffffff] [#I] #W '

#set -g window-status-current-format ' #I #W ' # 当前激活窗口在状态栏的展位格式
setw -g window-status-current-format '#[bg=#ff0000, fg=#ffffff, bold]*[#I] #W*'

setw -g window-status-current-bg blue
setw -g window-status-current-fg green

# 自动重新编号 window
set -g renumber-windows on

# pane border colors
set -g pane-active-border-fg '#55ff55'
set -g pane-border-fg '#555555'
```

256颜色表
![image](http://mufool.qiniudn.com/tmux/tmux3.jpg)
注：图片来自网络

### 插件配置状态栏

使用[tmux-powerline](https://github.com/erikw/tmux-powerline)插件配置状态栏。

```
$ cd ~
$ git clone https://github.com/erikw/tmux-powerline.git
```
开启

```
set-option -g status-left "#(~/tmux-powerline/powerline.sh left)"
set-option -g status-right "#(~/tmux-powerline/powerline.sh right)"
```

显示`No weather location specified`时，需要修改segments/weather.sh文件，[参考](https://github.com/erikw/tmux-powerline/issues/219)

securtcrt或者putty中powerline中文显示问题，参考[让putty，secureCRT等工具支持Powerline，oh-my-zsh，解决乱码问题](http://blog.csdn.net/daoshuti/article/details/69788156)

## 插件管理

安装插件管理器

```
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

配置

```
# List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'

# Other examples:
# set -g @plugin 'github_username/plugin_name'
# set -g @plugin 'git@github.com/user/plugin'
# set -g @plugin 'git@bitbucket.com/user/plugin'

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'
```

启用
```
tmux source ~/.tmux.conf
```

安装、升级和反安装插件
```
prefix shift-i      # install
prefix shift-u      # update
prefix alt-u        # uninstall plugins not on the plugin list
```

## 常用插件

### [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect)

保存和恢复 Tmux 会话，面板布局，甚至支持恢复vim会话，重启机器仍可恢复。参考[保存和恢复 Tmux 会话](https://liam0205.me/2016/09/10/tmux-plugin-resurrect/)。

在tmux.conf中添加
```
set -g @plugin 'tmux-plugins/tmux-resurrect'
```
添加插件后`prefix + I`即下载并开启

参考：
[tmux – Linux终端管理软件](http://blog.csdn.net/u012335044/article/details/61923402)
[Tmux (简体中文)](https://wiki.archlinux.org/index.php/Tmux_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))
[CentOS 下安装 tmux](https://www.zybuluo.com/mwumli/note/149542)
[Tmux 插件管理工具](https://qiaoanran.com/article/0d268826+Tmux_%E6%8F%92%E4%BB%B6%E7%AE%A1%E7%90%86%E5%B7%A5%E5%85%B7)
[tmux-themepack](https://github.com/jimeh/tmux-themepack)
[在 Linux/Mac 安装 Tmux 及其配置](https://my.oschina.net/am313/blog/865915)
[TMUX 简介](https://jin-yang.github.io/post/tmux-introduce.html)



