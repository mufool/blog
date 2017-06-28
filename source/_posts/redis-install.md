---
layout: post
title: Redis安装配置
date: 2017-06-16 19:48:38
tags: [REDIS]
---

## 编译

```bash
tar -zxvf redis-2.8.12.tar.gz
cd redis-2.8.19 
make
make PREFIX=/opt/modules/redis
```

<!-- more -->

## 配置

```bash
mkdir /opt/modules/redis/etc/
cp redis.conf /opt/modules/redis/etc/ 
cd /opt/modules/redis/bin/
cp redis-benchmark redis-cli redis-server /usr/bin/
```

内存调整

```bash
#此参数可用的值为0,1,2 
#0表示当用户空间请求更多的内存时，内核尝试估算出可用的内存 
#1表示内核允许超量使用内存直到内存用完为止 
#2表示整个内存地址空间不能超过swap+(vm.overcommit_ratio)%的RAM值 
echo "vm.overcommit_memory=1">>/etc/sysctl.conf
sysctl -p
```

修改redis配置

```bash
vim /opt/modules/redis/etc/redis.conf

#配置监听地址
bind 127.0.0.1 192.168.193.228 119.18.193.228

#配置监听端口
port 6379

# 配置log文件位置
logfile "/opt/redis/log.txt"

# 写文件条件
save 900 1
save 300 10
save 60 10000

# 写文件名
dbfilename dump.rdb

#密码设置
requirepass bfsportsdt

##修改命名及禁止
rename-command CONFIG b840fc02d524045429941cc15f59e41cb7be6c28
rename-command FLUSHALL ""
rename-command FLUSHDB ""
```

## 启动脚本

```bash
#!/bin/bash
#chkconfig: 2345 80 90
# Simple Redis init.d script conceived to work on Linux systems
# as it does use of the /proc filesystem.

PATH=/usr/local/bin:/sbin:/usr/bin:/bin
REDISPORT=6379
EXEC=/opt/modules/redis/bin/redis-server
REDIS_CLI=/opt/modules/redis/bin/redis-cli
   
PIDFILE=/var/run/redis.pid
CONF="/opt/modules/redis/etc/redis.conf"
   
case "$1" in
    start)
        if [ -f $PIDFILE ]
        then
                echo "$PIDFILE exists, process is already running or crashed"
        else
                echo "Starting Redis server..."
                $EXEC $CONF
        fi
        if [ "$?"="0" ] 
        then
              echo "Redis is running..."
        fi
        ;;
    stop)
        if [ ! -f $PIDFILE ]
        then
                echo "$PIDFILE does not exist, process is not running"
        else
                PID=$(cat $PIDFILE)
                echo "Stopping ..."
                $REDIS_CLI -p $REDISPORT SHUTDOWN
                while [ -x ${PIDFILE} ]
               do
                    echo "Waiting for Redis to shutdown ..."
                    sleep 1
                done
                echo "Redis stopped"
        fi
        ;;
   restart|force-reload)
        ${0} stop
        ${0} start
        ;;
  *)
    echo "Usage: /etc/init.d/redis {start|stop|restart|force-reload}" >&2
        exit 1
esac
```

## redis开机自启动

```bash
# 复制脚本文件到init.d目录下
cp redis /etc/init.d/

# 给脚本增加运行权限
chmod +x /etc/init.d/redis

# 查看服务列表
chkconfig --list

# 添加服务
chkconfig --add redis

# 配置启动级别
chkconfig --level 2345 redis on

#启动停止
service redis start   #或者 /etc/init.d/redis start  
service redis stop   #或者 /etc/init.d/redis stop
```

参考：
[NoSQL之【Redis】学习（三）：Redis持久化 Snapshot和AOF说明](http://www.cnblogs.com/zhoujinyi/archive/2013/05/26/3098508.html)
