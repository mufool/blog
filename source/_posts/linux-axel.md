---
title: Linux多线程下载工具axel安装使用
date: 2017-05-15 15:01:31
tags: [LINUX]
---

## 安装

```
	wget http://www.ha97.com/code/axel-2.4.tar.gz
	tar zxvf axel-2.4.tar.gz
	cd axel-2.4
	./configure
	make
	make install
```

<!-- more -->

## 语法

```
	axel [options] url1 [url2] [url...]
```

## 选项 

```
	--max-speed=x , -s x 最高速度x 
	--num-connections=x , -n x 连接数x 
	--output=f , -o f 下载为本地文件f 
	--search[=x] , -S [x] 搜索镜像 
	--header=x , -H x 添加头文件字符串x（指定 HTTP header） 
	--user-agent=x , -U x 设置用户代理（指定 HTTP user agent） 
	--no-proxy ， -N 不使用代理服务器 
	--quiet ， -q 静默模式 
	--verbose ，-v 更多状态信息 
	--alternate ， -a Alternate progress indicator 
	--help ，-h 帮助 
	--version ，-V 版本信息 
```

## 实例 

如下载lnmp安装包指定10个线程，存到/tmp/： 

```
	axel -n 10 -o /tmp/ http://www.linuxde.net/lnmp.tar.gz 
```

如果下载过程中下载中断可以再执行下载命令即可恢复上次的下载进度。
