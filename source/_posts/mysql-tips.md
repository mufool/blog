---
layout: post
title: MYSQL部分问题及解决方法
date: 2016-07-11 17:08:37
tags: [MYSQL]
---

## MYSQL出现"the table is full"的问题

出现此问题的原因一般是内存表的大小超过了规定的范围，也可能是因为磁盘满导致。

针对内存表超过规定范围的解决方法一种是修改tmp_table_size参数，另外一种是修改max_heap_table_size参数。

<!-- more -->

修改Mysql的配置文件/etc/my.cnf，在[mysqld]下添加/修改：

```
	max_heap_table_size = 4096M
	key_buffer_size = 1000M
```

或者

```
	tmp_table_size = 256M
```
系统默认是16M，修改完后重启mysql


## MYSQL链接慢或链接不上

当客户端连接数据库服务器时，服务器会进行主机名解析，并且当DNS很慢时，建立连接会很慢。因此建议在启动服务器时关闭skip_name_resolve选项。

skip-name-resolve：禁止MySQL对外部连接进行DNS解析，禁止MySQL对外部连接进行DNS解析。跳过域名解析步骤，增加远程登录的速度，原理如下：

所谓反向解析是这样的：

mysql接收到连接请求后，获得的是客户端的ip，为了更好的匹配mysql.user里的权限记录（某些是用hostname定义的）。

如果mysql服务器设置了dns服务器，并且客户端ip在dns上并没有相应的hostname，那么这个过程很慢，导致连接等待。

关闭选项后唯一的局限是之后GRANT语句中只能使用IP地址了，因此在添加这项设置到一个已有系统中必须格外小心。

## Too many connections

如果你经常看到'Too many connections'错误，是因为max_connections的值太低了。这非常常见因为应用程序没有正确的关闭数据库连接，你需要比默认的151连接数更大的值。
max_connection值被设高了(例如1000或更高)之后一个主要缺陷是当服务器运行1000个或更高的活动事务时会变的没有响应。在应用程序里使用连接池或者在MySQL里使用进程池有助于解决这一问题。


