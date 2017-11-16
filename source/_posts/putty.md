---
title: Putty免密登陆
date: 2017-09-29 15:15:48
tags: [PUTTY]
---
## 介绍

PuTTY是一个Telnet、SSH、rlogin、纯TCP以及串行接口连接软件，其主要优点有： 完全免费 、全面支持SSH1和SSH2 、绿色软件，无需安装，下载后在桌面建个快捷方式即可使用、体积很小、操作简单。

<!-- more -->

## 安装

[下载地址](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html)

下载msi包安装，或者直接下载exe文件即可。

## 免密登陆配置

PuTTY不提供“记住密码”一类的选项，PuTTY自动登录Linux系统，需要使用公钥/私钥方式。 这种方式需要生成一组对应的公钥（简短的字符串）和密钥（一个文件），然后把公钥放到服务器上，私钥提供给PuTTY。PuTTY仍然不知道你的密码，而是通过与服务器核对密钥而核实身份。

### 生成公私钥

使用PuTTY安装目录里的puttygen.exe工具。先点“生成(Generate)”，然后随意移动鼠标直到进度条填满，即可生成密钥。

![image](http://mufool.qiniudn.com/putty/putty1.jpg)

点击`Save private key`保存私钥到文件。

### Putty关联私钥

在Connection -> SSH -> Auth, Private keyfile for authentication中添加上一步生成的私钥文件，同时保存会话。
![image](http://mufool.qiniudn.com/putty/putty2.jpg)

### 服务器添加公钥

在服务器对应的用户文件`~/.ssh/authorized_keys`，中添加生成第一步生成的公钥即可。

### 验证
退出重新登陆putty即可，如配置后仍然报错`server refused our key`，修改如下：
```
chmod 700 .ssh #目录权限700
chmod 600 authorized_keys #文件权限600
```

参考：
[linux ssh私钥登陆失败:server refused our key原因](http://blog.csdn.net/xocoder/article/details/45821967)
