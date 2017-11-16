---
title: Centos安装redis集群
date: 2017-10-17 20:02:47
tags: [REDIS]
---

Redis Cluster是3.0版本之后提供的新功能，采用了P2P的去中心化架构，而没有采用像Codis之类的Proxy解决方案中的中心协调节点设计。

<!-- more -->

## Redis集群原理

Redis集群使用数据分片而非一致性哈希来实现，一个Redis集群包含16384个哈希槽（slot），数据库中的每个键都属于这16384个哈希槽中的其中一个，集群中的每个节点可以处理0个或最多16384个槽，当数据库中的16384个槽都有节点在处理时，集群处于上线状态；而如果数据库中有任何一个槽没有得到处理，那么集群处于下线状态。
集群中的每个节点负责处理一部分哈希槽，比如，现在有三个独立的节点127.0.0.1:7000,127.0.0.1:7001,127.0.0.1:7002，其中各节点处理的哈希槽关系：节点7000负责处理0到5000号哈希槽，节点7001负责处理5001到10000号哈希槽，节点7002负责处理10001到16384号哈希槽。
从而，当向集群中添加或删除节点时，集群只需在对应节点的哈希槽做移动即可。不会造成节点阻塞、集群下线。
当然，为了使得集群在一部分节点下线的情况下仍然可以正常运作，Redis集群对节点提供了主从复制功能，集群中的每个节点都有1到N个复制节点，形成主-从模型。

## Redis集群架构

(图片来自网络)
![image](http://i.imgur.com/O4QfdDF.jpg)

Redis集群架构的主要特点有:
- 所有节点批次互联（PING-PONG机制），没有中心控制协调节点，内部使用二进制协议优化传输速度和带宽；
- 节点的失效通过集群中超过半数的节点“投票”监测；
- 客户端与Redis节点直连，不需要中间proxy层，客户端连接集群中任何一个可用节点即可；

## 安装

依赖库安装
```
yum -y install gcc openssl-devel libyaml-devel libffi-devel readline-devel zlib-devel gdbm-devel ncurses-devel gcc-c++ automake autoconf
```

redis编译
```
wget http://download.redis.io/releases/redis-3.0.6.tar.gz
tar xvf redis-3.0.6.tar.gz
cd redis-3.0.6/
make MALLOC=libc
```

编译之后再src目录下会生成需要的可执行文件，用到的文件有：

- redis-trib.rb，集群创建脚本
- redis-server，redis服务
- redis-cli，redis客户端

## 配置启动

这里部署在同一台上测试，同时配置主从，共6个节点7000-7005。

1、创建目录

在redis-cluster目录下，创建目录7000-7005
```
mkdir redis-cluster
mkdir 7000 7001 7002 7003 7004 7005
```

2、修改配置文件

```
daemonize yes
pidfile /var/run/redis0.pid
port 7000
#bind 127.0.0.1 192.168.193.229 119.18.193.229
loglevel notice
logfile "./log.txt"

cluster-enabled yes
cluster-config-file nodes-7000.conf
cluster-node-timeout 5000

appendonly yes
appendfsync everysec

rename-command CONFIG b840fc02d524045429941cc15f59e41cb7be6c28
rename-command FLUSHALL "" 
rename-command FLUSHDB "" 
```
分别拷贝到其他目录，并修改对应的配置项。

3、分别启动6个redis

```
cd redis-cluster/7000
./redis-server redis.conf
...
cd redis-cluster/7005
./redis-server redis.conf
```

4、查看进程

![image](http://mufool.qiniudn.com/redis/redis-cluster0.jpg)


## 建立redis集群

以上步骤分别创建了6个节点，并已经启动，这里要把这6个节点加入到一个集群里面。redis 已经为我们提供了集群操作的脚本 redis-trib.rb。

### 安装ruby

由于集群操作需要用到 ruby 脚本 redis-trib.rb , 所以要安装 ruby 和 rubygems
```
yum -y install ruby rubygems
gem install redis --version 3.0.6
```
![image](http://mufool.qiniudn.com/redis/redis-cluster1.jpg)

### 创建集群

```
redis-trib.rb create --replicas 1 127.0.0.1:7000 127.0.0.1:7001 127.0.0.1:7002 127.0.0.1:7003 127.0.0.1:7004 127.0.0.1:7005
```
其中，命令create表示创建一个新的集群，选项–replicas 1表示未集群中的每个主节点创建一个从节点。即，上述命令运行后，redis-trib将创建一个包含三个主节点和三个从节点的集群。
![image](http://mufool.qiniudn.com/redis/redis-cluster2.jpg) 
上面信息中 M 表示 Master 节点， S 表示 Slave 节点，同时可以看到主备关系。随后输入yes即可创建完成。

## 集群测试

```
./src/redis-trib.rb check 127.0.0.1:7000
```
![image](http://mufool.qiniudn.com/redis/redis-cluster3.jpg) 
 其中可以看到每台master上的slot的分配个数，所有16384个slot都被covered，集群处于上线状态。


```
src/redis-cli -p 7000 cluster nodes
```

![image](http://mufool.qiniudn.com/redis/redis-cluster4.jpg) 

查看集群中各节点的信息。包括唯一的节点ID，主从关系，每个主节点分配的slots范围。

![image](http://mufool.qiniudn.com/redis/redis-cluster5.jpg) 

在任意节点上增删数据都可以在集群的其他节点看到。若节点上没有查询的数据，-c参数指定查询时接收到MOVED指令自动跳转。

参考：
[搭建Redis集群](http://blog.dujiong.net/2017/01/15/Redis-Cluster/)
[redis cluster管理工具redis-trib.rb详解](http://weizijun.cn/2016/01/08/redis%20cluster%E7%AE%A1%E7%90%86%E5%B7%A5%E5%85%B7redis-trib-rb%E8%AF%A6%E8%A7%A3/)
