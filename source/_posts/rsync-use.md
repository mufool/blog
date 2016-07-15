---
title: rsync简单介绍和使用
date: 2016-07-11 17:19:31
tags: [RSYNC]
---

## 介绍

Rsync（remote synchronize）是一个远程数据同步工具。

Rsync使用“Rsync算法”来使本地和远程两个主机之间的文件达到同步，这个算法只传送两个文件的不同部分，而不是每次都整份传送，因此速度相当快。

Rsync可以通过rsh或ssh使用，也能以daemon模式去运行，在以daemon方式运行时Rsync server会打开一个873端口，等待客户端去连接。

<!-- more -->

主要特点：

* 可以镜像保存整个目录树和文件系统。
* 可以很容易做到保持原来文件的权限、时间、软硬链接等等。
* 无须特殊权限即可安装。
* 优化的流程，文件传输效率高。
* 可以使用rcp、ssh等方式来传输文件，当然也可以通过直接的socket连接。
* 支持匿名传输。

## 核心算法

[rsync 的核心算法](http://coolshell.cn/articles/7425.html)

## 配置文件

```
	# Minimal configuration file for rsync daemon
	# See rsync(1) and rsyncd.conf(5) man pages for help

	# This line is required by the /etc/init.d/rsyncd script
	pid file = /var/run/rsyncd.pid	进程写到 /var/run/rsyncd.pid 文件中
	port = 873
	address = 192.168.202.152
	uid = nobody
	gid = nobody	指定哪个用户和用户组来执行，默认是nobody，可能遇到权限问题，可以在定义要同步的目录时指定用户来解决权限的问题

	use chroot = no	
	read only = yes	只读选择，不让客户端上传文件到服务器上，还有一个write only选项

	#limit access to private LANs
	hosts allow=182.18.58.73 192.168.1.0/255.255.255.0 10.0.1.0/255.255.255.0
	hosts deny=*

	max connections = 5	客户端最多连接数
	motd file = /etc/rsyncd/rsyncd.motd	定义服务器信息的，要自己写 rsyncd.motd 文件内容，当用户登录时会看到这个信息

	#This will give you a separate log file
	log file = /var/log/rsync.log	rsync 服务器的日志

	#This will log every file transferred - up to 85,000+ per user, per sync
	transfer logging = yes	传输文件的日志

	log format = %t %a %m %f %b
	syslog facility = local3
	timeout = 300

	[dbback]
	path = /opt/mysql
	#auth users = root
	list=yes
	ignore errors
	secrets file = /etc/rsyncd/rsyncd.secrets
	comment = root data
	exclude =   beinan/  samba/
```

## 模块定义

主要是定义服务器哪个目录要被同步，我们可以根据自己的需要，来指定多个模块。每个模块要指定认证用户，密码文件。

```
	[dbback]
	path = /opt/mysql	指定文件目录所在位置，这是必须指定的 
	auth users = root	认证用户是root  ，是必须在服务器上存在的用户
	list=yes	list 意思是把rsync 服务器上提供同步数据的目录在服务器上模块是否显示列出来。默认是yes 。如果你不想列出来，就no ；如果是no是比较安全的
	ignore errors	忽略IO错误
	secrets file = /etc/rsyncd/rsyncd.secrets	密码存在哪个文件,
	comment = root data	注释可以自己定义
	exclude = beinan/  samba/	需要排除的子目录
```

rsyncd.secrets的内容格式为：用户名:密码，文件属性设为root拥有，且权限要设为600，出于安全目的，文件的属性必需是只有属主可读。

## 启动rsync服务器

```
	/usr/bin/rsync --daemon  --config=/etc/rsyncd/rsyncd.conf
```

启动前，先service iptables stop将防火墙关掉

## rsync参数及实例

rsync中的参数：

```
	-v, --verbose 详细模式输出
	-q, --quiet 精简输出模式
	-c, --checksum 打开校验开关，强制对文件传输进行校验
	-a, --archive 归档模式，表示以递归方式传输文件，并保持所有文件属性，等于-rlptgoD
	-r, --recursive 对子目录以递归模式处理
	-R, --relative 使用相对路径信息
	-b, --backup 创建备份，也就是对于目的已经存在有同样的文件名时，将老的文件重新命名为~filename。可以使用--suffix选项来指定不同的备份文件前缀。
	--backup-dir 将备份文件(如~filename)存放在在目录下。
	-suffix=SUFFIX 定义备份文件前缀
	-u, --update 仅仅进行更新，也就是跳过所有已经存在于DST，并且文件时间晚于要备份的文件。(不覆盖更新的文件)
	-l, --links 保留软链结
	-L, --copy-links 想对待常规文件一样处理软链结
	--copy-unsafe-links 仅仅拷贝指向SRC路径目录树以外的链结
	--safe-links 忽略指向SRC路径目录树以外的链结
	-k, --copy-dirlinks 复制目录中符号链接
	-K, --keep-dirlinks 保持目录下符号链接
	-H, --hard-links 保留硬链结
	-p, --perms 保持文件权限
	-o, --owner 保持文件属主信息
	-g, --group 保持文件属组信息
	-D, --devices 保持设备文件信息
	-t, --times 保持文件时间信息
	-S, --sparse 对稀疏文件进行特殊处理以节省DST的空间
	-n, --dry-run现实哪些文件将被传输
	-W, --whole-file 拷贝文件，不进行增量检测
	-x, --one-file-system 不要跨越文件系统边界
	-B, --block-size=SIZE 检验算法使用的块尺寸，默认是700字节
	-e, --rsh=COMMAND 指定使用rsh、ssh方式进行数据同步
	--rsync-path=PATH 指定远程服务器上的rsync命令所在路径信息
	-C, --cvs-exclude 使用和CVS一样的方法自动忽略文件，用来排除那些不希望传输的文件
	--existing 仅仅更新那些已经存在于DST的文件，而不备份那些新创建的文件
	--delete 删除那些DST中SRC没有的文件，delete是指如果服务器端删除了这一文件，那么客户端也相应把文件删除，保持真正的一致
	--delete-excluded 同样删除接收端那些被该选项指定排除的文件
	--delete-after 传输结束以后再删除
	--ignore-errors 及时出现IO错误也进行删除
	--max-delete=NUM 最多删除NUM个文件
	--partial 保留那些因故没有完全传输的文件，以是加快随后的再次传输
	--force 强制删除目录，即使不为空
	--numeric-ids 不将数字的用户和组ID匹配为用户名和组名
	--timeout=TIME IP超时时间，单位为秒
	-I, --ignore-times 不跳过那些有同样的时间和长度的文件
	--size-only 当决定是否要备份文件时，仅仅察看文件大小而不考虑文件时间
	--modify-window=NUM 决定文件是否时间相同时使用的时间戳窗口，默认为0
	-T --temp-dir=DIR 在DIR中创建临时文件
	--compare-dest=DIR 同样比较DIR中的文件来决定是否需要备份
	-P 等同于 --partial
	--progress 显示备份过程
	-z, --compress 对备份的文件在传输时进行压缩处理
	--exclude=PATTERN 指定排除不需要传输的文件模式
	--include=PATTERN 指定不排除而需要传输的文件模式
	--exclude-from=FILE 排除FILE中指定模式的文件
	--include-from=FILE 不排除FILE指定模式匹配的文件
	--version 打印版本信息
	--address 绑定到特定的地址
	--config=FILE 指定其他的配置文件，不使用默认的rsyncd.conf文件
	--port=PORT 指定其他的rsync服务端口
	--blocking-io 对远程shell使用阻塞IO
	-stats 给出某些文件的传输状态
	--progress 在传输时现实传输过程
	--log-format=formAT 指定日志文件格式
	--password-file=FILE 从FILE中得到密码；--password-file=/password/path/file来指定密码文件，这样就可以在脚本中使用而无需交互式地输入验证密码了，这里需要注意的是这份密码文件权限属性要设得只有属主可读。
	--bwlimit=KBPS 限制I/O带宽，KBytes per second
	-h, --help 显示帮助信息
```

查看服务端可用的模块列表以及注释信息

```
	rsync root@192.168.202.152::
```

查看服务端dbback模块中的目录及文件列表

```
	rsync root@192.168.202.152::dbback
```

推送符号链接目录

```
	rsync -avk --bwlimit=2000 /root/meizipic rsync@192.168.202.153:/data/tmp_images
```

拉取含符号链接目录

```
	rsync -rptgoDKLvP root@192.168.202.153:/opt/data/download ./
```

以服务的方法同步

```
	rsync -rptgoDKLvP root@192.168.202.153::dbback /opt/backcenter/
```


