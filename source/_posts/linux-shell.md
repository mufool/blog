---
title: login shell与non-login shell的区别
date: 2017-06-09 14:39:53
tags: [LINUX]
---
## shell分类

### login shell和non-login shell

<!-- more -->

- login shell代表用户登入, 比如使用 “su -“ 命令, 或者用 ssh 连接到某一个服务器上, 都会使用该用户默认 shell 启动 login shell 模式。该模式下的 shell 会去自动执行 /etc/profile 和 ~/.profile 文件, 但不会执行任何的 bashrc 文件, 所以一般再 /etc/profile 或者 ~/.profile 里我们会手动去 source bashrc 文件。

- no-login shell 的情况是我们在终端下直接输入 bash 或者 bash -c “CMD” 来启动的 shell。该模式下是不会自动去运行任何的 profile 文件。

### interactive shell 和 non-interactive shell

- interactive shell 是交互式shell, 顾名思义就是用来和用户交互的, 提供了命令提示符可以输入命令。该模式下会存在一个叫 PS1 的环境变量, 如果还不是 login shell 的则会去 source /etc/bashrc 和 ~/.bashrc 文件。

- non-interactive shell 则一般是通过 bash -c “CMD” 来执行的bash。该模式下不会执行任何的 rc 文件。

### 组合shell

在可能存在的模式组合中 RC 文件的执行
1、 SSH login, sudo su - [USER]
ssh 登入和 su - 是典型的 interactive login shell, 所以会有 PS1 变量, 并且会执行
```
/etc/profile
~/.bash_profile
```

2、在命令提示符状态下输入 bash 或者 ubuntu 默认设置下打开终端
这样开启的是 interactive no-login shell, 所以会有 PS1 变量, 只会执行
```
/etc/bashrc
~/.bashrc
```

3、通过 bash -c “CMD” 或者 bash BASHFILE 命令执行的 shell
这些命令什么都不会执行, 也就是设置 PS1 变量, 不执行任何 RC 文件

4、通过 “ssh server CMD” 执行的命令 或 通过程序执行远程的命令
这是最特殊的一种模式, 理论上应该既是 非交互 也是 非登入的, 但是实际上他不会设置 PS1, 但是还会执行
```
/etc/bashrc
~/.bashrc
```

## bashrc 和 profile 的区别
看了之前那么多种状态组合, 最关键的问题是, 究竟 bashrc 和 profile 有什么区别

- profile
/etc/profile中是全局配置，修改对所有用户生效；~/.bash_profile是个人的配置，修改只对用户自己生效；login shell先读取/etc/profile，再读取~/.bash_profile。一般~/.bash_profile中会同时读取~/.bashrc文件。

- bashrc
bashrc 也是看名字就知道, 是专门用来给 bash 做初始化的比如用来初始化 bash 的设置, bash 的代码补全, bash 的别名, bash 的颜色。non-login shell会读取bashrc文件，bashrc同时会包含/etc/bashrc，其中主要会设置用户的UMASK，设置PS1。
