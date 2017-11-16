---
title: Zookeeper安装使用
date: 2017-06-09 14:42:28
tags: [HADOOP]
---
## 下载安装

```bash
https://mirrors.tuna.tsinghua.edu.cn/apache/zookeeper/stable/zookeeper-3.4.9.tar.gz
tar -xzvf zookeeper-3.4.9.tar.gz
```

<!-- more -->

复制配置文件

```
cd zookeeper-3.4.9
cp conf/zoo_sample.cfg conf/zoo.cfg
```

## 修改配置

```bash
vi conf/zoo.cfg
dataDir=/opt/hadoop/zookeeper-3.4.9/data
dataLogDir=/opt/hadoop/zookeeper-3.4.9/logs
clientPort=2181
tickTime=2000
initLimit=5
syncLimit=2
server.1=HDP245:2888:3888
server.2=HDP246:2888:3888
server.3=HDP247:2888:3888
```

在dataDir目录下创建myid文件，HDP245机器的内容为1，HDP246机器的内容为2，HDP247机器的内容为3，若有更多依此类推。

在HDP245的修改为： 

```
mkdir -p /opt/hadoop/zookeeper-3.4.9/data/ 
echo 1 > /opt/hadoop/zookeeper-3.4.9/data/myid
```

在HDP246、HDP247上把“echo 1”的“1”改成对应的值。
- dataDir：数据目录
- dataLogDir：日志目录
- clientPort：客户端连接端口
- tickTime：Zookeeper 服务器之间或客户端与服务器之间维持心跳的时间间隔，也就是每个 tickTime 时间就会发送一个心跳。
- initLimit：Zookeeper的Leader 接受客户端（Follower）初始化连接时最长能忍受多少个心跳时间间隔数。当已经超过 5个心跳的时间（也就是tickTime）长度后 Zookeeper 服务器还没有收到客户端的返回信息，那么表明这个客户端连接失败。总的时间长度就是 5*2000=10 秒
- syncLimit：表示 Leader 与 Follower 之间发送消息时请求和应答时间长度，最长不能超过多少个tickTime 的时间长度，总的时间长度就是 2*2000=4 秒。
- server.A=B：C：D：其中A 是一个数字，表示这个是第几号服务器；B 是这个服务器的 ip 地址；C 表示的是这个服务器与集群中的 Leader 服务器交换信息的端口；D 表示的是万一集群中的 Leader 服务器挂了，需要一个端口来重新进行选举，选出一个新的 Leader，而这个端口就是用来执行选举时服务器相互通信的端口。如果是伪集群的配置方式，由于 B 都是一样，所以不同的 Zookeeper 实例通信端口号不能一样，所以要给它们分配不同的端口号。

## 启动集群

接下来将上面的安装文件拷贝到集群中的其他机器上对应的目录下，拷贝完成后修改对应的机器上的myid,在每台上分别启动zookeeper

```bash
bin/zkServer.sh start
```

查看是否启动成功

```bash
[root@localhost zookeeper-3.4.9]# jps
20880 Jps
22929 SecondaryNameNode
20852 QuorumPeerMain
28328 RunJar
22747 NameNode
23086 ResourceManager
22079 Master
```
其中，QuorumPeerMain是zookeeper进程，启动正常。


## 查看启动结果

每台上执行bin/zkServer.sh status，可以查看选出了leader和follower

第一台

```bash
# bin/zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /opt/hdp/zookeeper-3.4.9/bin/../conf/zoo.cfg
Mode: follower
```

第二台

```bash
#bin/zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /opt/hdp/zookeeper-3.4.9/bin/../conf/zoo.cfg
Mode: leader
```

可能出现的错误`Error contacting service. It is probably not running`，关闭防火墙，查看是否监听了内网地址，myid文件是否添加正确。

## 连接zookeeper集群

```bash
-rw-r--r--  1 root root    7922 Mar 14 18:28 zookeeper.out
[root@BFG-OSER-1308 zookeeper-3.4.9]# bin/zkCli.sh -server 192.168.204.237:2181
Connecting to 192.168.204.237:2181
2017-03-14 18:33:07,018 [myid:] - INFO  [main:Environment@100] - Client environment:zookeeper.version=3.4.9-1757313, built on 08/23/2016 06:50 GMT
2017-03-14 18:33:07,022 [myid:] - INFO  [main:Environment@100] - Client environment:host.name=localhost
2017-03-14 18:33:07,022 [myid:] - INFO  [main:Environment@100] - Client environment:java.version=1.8.0_121
2017-03-14 18:33:07,025 [myid:] - INFO  [main:Environment@100] - Client environment:java.vendor=Oracle Corporation
2017-03-14 18:33:07,025 [myid:] - INFO  [main:Environment@100] - Client environment:java.home=/opt/hdp/jdk1.8.0_121/jre
2017-03-14 18:33:07,025 [myid:] - INFO  [main:Environment@100] - Client environment:java.class.path=/opt/hdp/zookeeper-3.4.9/bin/../build/classes:/opt/hdp/zookeeper-3.4.9/bin/../build/lib/*.jar:/opt/hdp/zookeeper-3.4.9/bin/../lib/slf4j-log4j12-1.6.1.jar:/opt/hdp/zookeeper-3.4.9/bin/../lib/slf4j-api-1.6.1.jar:/opt/hdp/zookeeper-3.4.9/bin/../lib/netty-3.10.5.Final.jar:/opt/hdp/zookeeper-3.4.9/bin/../lib/log4j-1.2.16.jar:/opt/hdp/zookeeper-3.4.9/bin/../lib/jline-0.9.94.jar:/opt/hdp/zookeeper-3.4.9/bin/../zookeeper-3.4.9.jar:/opt/hdp/zookeeper-3.4.9/bin/../src/java/lib/*.jar:/opt/hdp/zookeeper-3.4.9/bin/../conf::.:/opt/hdp/jdk1.8.0_121/lib:/opt/hdp/jdk1.8.0_121/jre/lib:.:/opt/hdp/jdk1.8.0_121/lib:/opt/hdp/jdk1.8.0_121/jre/lib
2017-03-14 18:33:07,025 [myid:] - INFO  [main:Environment@100] - Client environment:java.library.path=/opt/hdp/hadoop-2.6.5/lib/native/:/opt/hdp/hadoop-2.6.5/lib/native/::/usr/java/packages/lib/amd64:/usr/lib64:/lib64:/lib:/usr/lib
2017-03-14 18:33:07,026 [myid:] - INFO  [main:Environment@100] - Client environment:java.io.tmpdir=/tmp
2017-03-14 18:33:07,026 [myid:] - INFO  [main:Environment@100] - Client environment:java.compiler=<NA>
2017-03-14 18:33:07,026 [myid:] - INFO  [main:Environment@100] - Client environment:os.name=Linux
2017-03-14 18:33:07,026 [myid:] - INFO  [main:Environment@100] - Client environment:os.arch=amd64
2017-03-14 18:33:07,026 [myid:] - INFO  [main:Environment@100] - Client environment:os.version=2.6.32-642.11.1.el6.x86_64
2017-03-14 18:33:07,026 [myid:] - INFO  [main:Environment@100] - Client environment:user.name=root
2017-03-14 18:33:07,026 [myid:] - INFO  [main:Environment@100] - Client environment:user.home=/root
2017-03-14 18:33:07,026 [myid:] - INFO  [main:Environment@100] - Client environment:user.dir=/opt/hdp/zookeeper-3.4.9
2017-03-14 18:33:07,028 [myid:] - INFO  [main:ZooKeeper@438] - Initiating client connection, connectString=192.168.204.237:2181 sessionTimeout=30000 watcher=org.apache.zookeeper.ZooKeeperMain$MyWatcher@446cdf90
Welcome to ZooKeeper!
```

## 停止zookeeper

```bash
/bin/zkServer.sh stop
```

## 命令行操作

```bash
[zk: 192.168.204.237:2181(CONNECTED) 0help
GNU bash, version 4.1.2(2)-release (x86_64-redhat-linux-gnu)
These shell commands are defined internally.  Type `help' to see this list.
Type `help name' to find out more about the function `name'.
Use `info bash' to find out more about the shell in general.
Use `man -k' or `info' to find out more about commands not in this list.

A star (*) next to a name means that the command is disabled.
```
使用

```
#查看集群/目录内容
[zk: 192.168.204.237:2181(CONNECTED) 1] ls /
[zookeeper]

#创建node节点
[zk: 192.168.204.237:2181(CONNECTED) 2] create /node test
Created /node

#再查看/目录内容
[zk: 192.168.204.237:2181(CONNECTED) 5] ls /
[node, zookeeper]

#查看node中数据信息
[zk: 192.168.204.237:2181(CONNECTED) 7] get /node
test
cZxid = 0x100000004
ctime = Tue Mar 14 18:38:49 CST 2017
mZxid = 0x100000004
mtime = Tue Mar 14 18:38:49 CST 2017
pZxid = 0x100000004
cversion = 0
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 4
numChildren = 0

#更改node中数据信息
[zk: 192.168.204.237:2181(CONNECTED) 8] set /node baofengcloud
cZxid = 0x100000004
ctime = Tue Mar 14 18:38:49 CST 2017
mZxid = 0x100000005
mtime = Tue Mar 14 18:46:56 CST 2017
pZxid = 0x100000004
cversion = 0
dataVersion = 1
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 12
numChildren = 0

#再次查看node中数据已更改
[zk: 192.168.204.237:2181(CONNECTED) 9] get /node
baofengcloud
cZxid = 0x100000004
ctime = Tue Mar 14 18:38:49 CST 2017
mZxid = 0x100000005
mtime = Tue Mar 14 18:46:56 CST 2017
pZxid = 0x100000004
cversion = 0
dataVersion = 1
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 12
numChildren = 0

#删除node
[zk: 192.168.204.237:2181(CONNECTED) 10] delete /node
[zk: 192.168.204.237:2181(CONNECTED) 11] ls /
[zookeeper]

#退出
[zk: 192.168.204.237:2181(CONNECTED) 12] quit
Quitting...
2017-03-14 18:47:19,797 [myid:] - INFO  [main:ZooKeeper@684] - Session: 0x25acc5905670001 closed
2017-03-14 18:47:19,799 [myid:] - INFO  [main-EventThread:ClientCnxn$EventThread@519] - EventThread shut down for session: 0x25acc5905670001
```

参考：
[ZooKeeper伪分布式集群安装及使用](http://blog.fens.me/hadoop-zookeeper-intro/)
