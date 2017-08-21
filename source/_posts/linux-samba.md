---
title: Samba简单使用
date: 2017-06-09 14:40:20
tags: [SAMBA]
---

&emsp;&emsp;Samba是在Linux和UNIX系统上实现SMB协议的一个免费软件，由服务器及客户端程序构成，主要用来实现主机之间的资源共享。

<!-- more -->

## samba安装

centos下yum即可安装samba

```powershell
yum -y install samba
```

## 配置

安装完后samba配置文件在`/etc/samba`目录下：

`vim /etc/samba/smb.conf`添加

```
...
[test]
comment = file of test
path = /opt/test/
public = yes
writable = yes
create mask = 0664
directory mask = 0775
valid users = testuser
browseable = yes
sync always = yes
```

## 添加用户授权

```powershell
smbpasswd -a testuser
```

## 重启生效

```powershell
/sbin/service smb restart
```

## 使用

挂载到另一台机器，将服务test对应的目录挂载到`/opt/data`目录下

```powershell
mount -t cifs -o username=testuser,password=123456 //192.168.204.237/test /opt/data
```
挂载失败则在global中添加访问授权：

```powershell
...
hosts allow = 192.168.204. 192.168.206. 192.168.202.
...
```


