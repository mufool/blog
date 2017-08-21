---
title: Centos下安装Grunt
date: 2017-08-21 12:46:56
tags: [JS]
---


Grunt是一个自动化的项目构建工具. 如果你需要重复的执行像压缩, 编译, 单元测试, 代码检查以及打包发布的任务。

<!-- more -->

## CentOS 下安装 Node.js

1、下载源码，你需要在`https://nodejs.org/en/download/`下载最新的Nodejs版本，本文以v0.10.24为例:

```
cd /usr/local/src/
wget http://nodejs.org/dist/v0.10.24/node-v0.10.24.tar.gz
```

2、解压源码

```
tar zxvf node-v0.10.24.tar.gz
```

3、 编译安装

```
cd node-v0.10.24
./configure --prefix=/usr/local/node/0.10.24
make
make install
```

4、 配置NODE_HOME，进入profile编辑环境变量`vim /etc/profile`

设置nodejs环境变量，添加如下内容:

```
#set for nodejs
export NODE_HOME=/usr/local/node/0.10.24
export PATH=$NODE_HOME/bin:$PATH
```

`:wq`保存并退出，编译/etc/profile 使配置生效

```
source /etc/profile
```
验证是否安装配置成功`node -v`，输出 v0.10.24 表示配置成功。

## 安装NPM

装好NodeJS后，可以在你的终端执行下面的命令安装NPM：

```
curl http://npmjs.org/install.sh | sh
```

检查是否安装成功`npm -v`

## Grunt安装

Grunt和Grunt插件都是通过npm, Node.js包管理器安装和管理的。

```
npm install -g grunt-cli
```

这条命令将会把grunt命令植入到你的系统路径中，这样就允许你从任意目录中运行Grunt(定位到任意目录运行grunt命令)。

查看是否安装成功`grunt --version`

```
grunt-cli v1.2.0
```

注意：安装grunt-cli并不等于安装了Grunt任务运行器! Grunt CLI的工作很简单：在Gruntfile所在目录调用运行已安装好的相应版本的Grunt。这就意味着可以在同一台机器上同时安装多个版本的Grunt。
