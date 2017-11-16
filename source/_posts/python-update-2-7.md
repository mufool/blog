---
title: Centos升级python2.7
date: 2017-11-16 16:43:26
tags: [PYTHON]
---
CentOS 6.X 自带的Python版本是 2.6 , 目前python主流的编译环境是2.7，故整理一下python2.6到2.7的升级过程。

<!-- more -->

## 环境准备

依赖工具包

```
sudo yum install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel
```

源码安装2.7

```
wget http://www.python.org/ftp/python/2.7.8/Python-2.7.8.tar.xz
xz -d Python-2.7.8.tar.xz
tar -xvf Python-2.7.8.tar
```

## 安装

```
cd Python-2.7.8
./configure --prefix=/usr/local
make
make altinstall
[root@VM_centos ~]# python2.7 -V
Python 2.7.8
```

## 更新python

```
mv /usr/bin/python /usr/bin/python.bak
ln -s /usr/local/bin/python2.7  /usr/bin/python
```

此时

```
[clouddev@TY-0064 ~]$ python -V
Python 2.7.8
[clouddev@TY-0064 ~]$ which python
/usr/bin/python
[clouddev@TY-0064 ~]$ 
```

## 安装pip

```
curl  https://bootstrap.pypa.io/get-pip.py | python2.7 -
```
启动pip报错
```
pkg_resources.DistributionNotFound: The 'pip==7.1.0' distribution was not found and is required by the application
```
修改pip
```
mv /usr/bin/pip /usr/bin/pip0
cp /usr/local/bin/pip2.7 /usr/bin/pip
```

## 修复yum
yum依赖的python2.6，此时yum无法使用
```
[clouddev@TY-0064 ~]$ which yum
/usr/bin/yum
```
将第一行`#!/usr/bin/python`改为`#!/usr/bin/python2.6`
