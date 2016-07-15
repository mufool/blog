---
title: /var/log/clientmqueue爆满问题
date: 2016-07-11 17:08:37
tags: [LINUX]
---

### 原因

系统中有用户开启了cron，而cron中执行的程序有输出内容，输出内容会以邮件形式发给cron的用户，出现/var/spool/clientmqueue/非常大的情况通常因为没有合适的MTA发送邮件，就都积累在这里了。

<!-- more -->

### 解决方法

在crontab里面的命令后面加上

```
	> /dev/null 2>&1 
```

将错误和输出同时抛弃掉。

### 清除/var/spool/clientmqueue/

当/var/spool/clientmqueue/目录下文件比较多时，直接rm -f 会报错argument too long

```
	cd /var/spool/clientmqueue
	ls | xargs rm -f
```
或者find命令去删除

