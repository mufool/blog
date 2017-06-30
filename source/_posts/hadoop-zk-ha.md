---
title: Hadoop使用zk配置HA
date: 2017-06-09 14:41:12
tags: [HADOOP]
---

## 简介

&emsp;&emsp;在hadoop1时代，只有一个NameNode。如果该NameNode数据丢失或者不能工作，那么整个集群就不能恢复了。hadoop2.2.0中HDFS的高可靠指的是可以同时启动2个NameNode。其中一个处于工作状态(active)，另一个处于随时待命状态(standby)。这样，当一个NameNode所在的服务器宕机时，可以在数据不丢失的情况下，手工或者自动切换到另一个NameNode提供服务。

&emsp;&emsp;hadoop2.0的HA机制官方介绍了有2种方式，一种是NFS（Network File System）方式，另外一种是QJM（Quorum Journal Manager）方式。active namenode和standby namenode之间通过NFS或者JN（journalnode，QJM方式）来同步数据。

&emsp;&emsp;active namenode会把最近的操作记录写到本地的一个edits文件中（edits file），并传输到NFS或者JN中。standby namenode定期的检查，从NFS或者JN把最近的edit文件读过来，然后把edits文件和fsimage/tech文件合并成一个新的fsimage/tech，合并完成之后会通知active namenode获取这个新fsimage/tech。active namenode获得这个新的fsimage/tech文件之后，替换原来旧的fsimage/tech文件。所以启动了hadoop2.0的HA机制之后，hadoop1.0中的secondarynamenode，checkpointnode，buckcupnode这些都不需要了。

## NFS方式

&emsp;&emsp;NFS作为active namenode和standby namenode之间数据共享的存储。active namenode会把最近的edits文件写到NFS，而standby namenode从NFS中把数据读过来。这个方式的缺点是，如果active namenode或者standby namenode有一个和NFS之间网络有问题，则会造成他们之前数据的同步出问题。

## QJM（Quorum Journal Manager ）方式

&emsp;&emsp;QJM的方式可以解决上述NFS容错机制不足的问题。active namenode和standby namenode之间是通过一组journalnode（数量是奇数，可以是3,5,7...,2n+1）来共享数据。active namenode把最近的edits文件写到2n+1个journalnode上，只要有n+1个写入成功就认为这次写入操作成功了，然后standby namenode就可以从journalnode上读取了。可以看到，QJM方式有容错的机制，可以容忍n个journalnode的失败。本文主要基于这种方式搭建高可用的hadoop集群。

## 架构

hadoop2.x高可用架构图

![image](/images/tech/hadoop-zk-ha-1.jpg)

&emsp;&emsp;在一个典型的HA集群中，每个NameNode是一台独立的服务器。在任一时刻，只有一个NameNode处于active状态，另一个处于standby状态。其中，active状态的NameNode负责所有的客户端操作，standby状态的NameNode处于从属地位，维护着数据状态，随时准备切换。

&emsp;&emsp;两个NameNode为了数据同步，会通过一组称作JournalNodes的独立进程进行相互通信。当active状态的NameNode的命名空间有任何修改时，会告知大部分的JournalNodes进程。standby状态的NameNode有能力读取JNs中的变更信息，并且一直监控edit log的变化，把变化应用于自己的命名空间。standby可以确保在集群出错时，命名空间状态已经完全同步了。

&emsp;&emsp;为了确保快速切换，standby状态的NameNode有必要知道集群中所有数据块的位置。为了做到这点，所有的datanodes必须配置两个NameNode的地址，发送数据块位置信息和心跳给他们两个。

&emsp;&emsp;对于HA集群而言，确保同一时刻只有一个NameNode处于active状态是至关重要的。否则，两个NameNode的数据状态就会产生分歧，可能丢失数据，或者产生错误的结果。为了保证这点，JNs必须确保同一时刻只有一个NameNode可以向自己写数据。

## 硬件资源

|IP	|主机名	|namenode|datanode|zk| journalnode |
|-------|----------|--------|--------- |
|192.168.206.238	|master |是   |否 | 是 |是 |
|192.168.206.237	|slave1 |否   |是 | 是 |是 |
|192.168.206.238	|slave2 |是   |是 | 是 |是 |

为了部署HA集群，应该准备以下事情：

* NameNode服务器：运行NameNode的服务器应该有相同的硬件配置。
* JournalNode服务器：运行的JournalNode进程非常轻量，可以部署在其他的服务器上。

注意：必须允许至少3个节点。当然可以运行更多，但是必须是奇数个，如3、5、7、9个等等。当运行N个节点时，系统可以容忍至少(N-1)/2个节点失败而不影响正常运行。

在HA集群中，standby状态的NameNode可以完成checkpoint操作，因此没必要配置Secondary NameNode、CheckpointNode、BackupNode。如果真的配置了，还会报错。

## 集群配置

现在master上配置，拷贝到另外两台

### hdfs-site.xml

&emsp;&emsp;HA集群需要使用nameservice ID区分一个HDFS集群。另外，HA中还要使用一个词，叫做NameNode ID。同一个集群中的不同NameNode，使用不同的NameNode ID区分。为了支持所有NameNode使用相同的配置文件，因此在配置参数中，需要把nameservice ID作为NameNode ID的前缀。

`dfs.nameservices` 命名空间的逻辑名称

```xml
<property>
	<name>dfs.nameservices</name>
	<value>mycluster</value>
</property>
```

`dfs.ha.namenodes.[nameservice ID]`命名空间中所有NameNode的唯一标示名称。可以配置多个，使用逗号分隔。该名称是可以让DataNode知道每个集群的所有NameNode。当前，每个集群最多只能配置两个NameNode。

```xml
<property>
	<name>dfs.ha.namenodes.mycluster</name>
	<value>nn1,nn2</value>
</property>
```

`dfs.namenode.rpc-address.[nameservice ID].[name node ID]` 每个namenode监听的RPC地址，
`dfs.namenode.http-address.[nameservice ID].[name node ID]` 每个namenode监听的http地址

```xml
<property>
	<name>dfs.namenode.rpc-address.mycluster.nn1</name>
	<value>192.168.205.173:9000</value>
</property>
<property>
	<name>dfs.namenode.http-address.mycluster.nn1</name>
	<value>192.168.205.173:50070</value>
</property>
<property>
	<name>dfs.namenode.rpc-address.mycluster.nn2</name>
	<value>192.168.204.238:9000</value>
</property>
<property>
	<name>dfs.namenode.http-address.mycluster.nn2</name>
	<value>192.168.204.238:50070</value>
</property>
```

`dfs.namenode.shared.edits.dir`,这是NameNode读写JNs组的uri。通过这个uri，NameNodes可以读写edit log内容。URI的格式`qjournal://host1:port1;host2:port2;host3:port3/journalId`。这里的host1、host2、host3指的是Journal Node的地址，这里必须是奇数个，至少3个；其中journalId是集群的唯一标识符，对于多个命名空间，也使用同一个journalId。配置如下

```xml
<property>
	<name>dfs.namenode.shared.edits.dir</name>
	<value>qjournal://192.168.204.237:8485;192.168.204.238:8485/mycluster</value>
</property>
```

`dfs.client.failover.proxy.provider.[nameservice ID]`, 这里配置HDFS客户端连接到Active NameNode的一个java类，`dfs.ha.fencing.methods`配置active namenode出错时的处理类。当active namenode出错时，一般需要关闭该进程。处理方式可以是ssh也可以是shell。

```xml
<property>
	<name>dfs.client.failover.proxy.provider.mycluster</name>
	<value>org.apache.hadoop.hdfs.server.namenode.ha.ConfiguredFailoverProxyProvider</value>
</property>
<property>
	<name>dfs.ha.fencing.methods</name>
	<value>sshfence</value>
</property>
<property>
	<name>dfs.ha.fencing.ssh.private-key-files</name>
	<value>/root/.ssh/id_rsa</value>
</property>
```

`dfs.journalnode.edits.dir`, 这是JournalNode进程保持逻辑状态的路径。这是在linux服务器文件的绝对路径。

```xml
<property>
	<name>dfs.journalnode.edits.dir</name>
	<value>/opt/hdp/hadoop-2.6.5/data/journal</value>
</property>
```

完整配置如下：

```xml
<configuration>
	<property>
		<name>dfs.replication</name>
		<value>2</value>
	</property>

	<property>
		<name>dfs.nameservices</name>
		<value>mycluster</value>
	</property>
	<property>
		<name>dfs.ha.namenodes.mycluster</name>
		<value>nn1,nn2</value>
	</property>
	<property>
		<name>dfs.namenode.rpc-address.mycluster.nn1</name>
		<value>192.168.205.173:9000</value>
	</property>
	<property>
		<name>dfs.namenode.http-address.mycluster.nn1</name>
		<value>192.168.205.173:50070</value>
	</property>
	<property>
		<name>dfs.namenode.rpc-address.mycluster.nn2</name>
		<value>192.168.204.238:9000</value>
	</property>
	<property>
		<name>dfs.namenode.http-address.mycluster.nn2</name>
		<value>192.168.204.238:50070</value>
	</property>

	<property>
		<name>dfs.namenode.shared.edits.dir</name>
		<value>qjournal://192.168.204.237:8485;192.168.204.238:8485/mycluster</value>
	</property>
	<property>
		<name>dfs.journalnode.edits.dir</name>
		<value>/opt/hdp/hadoop-2.6.5/data/journal</value>
	</property>
	<property>
		<name>dfs.ha.automatic-failover.enabled</name>
		<value>true</value>
	</property>
	<property>
		<name>dfs.client.failover.proxy.provider.mycluster</name>
		<value>org.apache.hadoop.hdfs.server.namenode.ha.ConfiguredFailoverProxyProvider</value>
	</property>
	<property>
		<name>dfs.ha.fencing.methods</name>
		<value>sshfence</value>
	</property>
	<property>
		<name>dfs.ha.fencing.ssh.private-key-files</name>
		<value>/root/.ssh/id_rsa</value>
	</property>
	<property>
		<name>dfs.ha.fencing.ssh.connect-timeout</name>
		<value>30000</value>
	</property>
	<property>
		<name>dfs.namenode.name.dir</name>
		<value>file:///opt/hdp/hadoop-2.6.5/dfs/name</value>
	</property>
	<property>
		<name>dfs.datanode.data.dir</name>
		<value>file:///opt/hdp/hadoop-2.6.5/dfs/data</value>
	</property>
</configuration>
```

### core-site.xml

`fs.defaultFS`, 客户端连接HDFS时，默认的路径前缀。如果前面配置了nameservice ID的值是mycluster，那么这里可以配置为授权信息的一部分。ha.zookeeper.quorum为zookeeper集群的地址。

```xml
<configuration>
	<property>
		<name>fs.defaultFS</name>
		<value>hdfs://mycluster/</value>
	</property>
	<property>
		<name>hadoop.tmp.dir</name>
		<value>file:/opt/hdp/hadoop-2.6.5/tmp</value>
	</property>

	<!-- 指定zookeeper地址 -->
	<property>
		<name>ha.zookeeper.quorum</name>
		<value>192.168.205.173:2181,192.168.204.237:2181,192.168.204.238:2181</value>
	</property>
</configuration>
```

### mapred-site.xml

```xml
<configuration>
	<!-- 指定mr框架为yarn方式 -->
	<property>
		<name>mapreduce.framework.name</name>
		<value>yarn</value>
	</property>
</configuration>
```

### yarn-site.xml

配置rm高可用

```xml

```

## 服务启动

启动zk，分别在三台zk上启动三台zookeeper服务器，同时查看状态，其中一台leader，两台follower：

```bash
zkServer.sh start
zkServer.sh status
```

启动journalnode，在master上执行：

```basj
[root@localhost hadoop-2.6.5]# sbin/hadoop-daemons.sh start journalnode 
192.168.204.238: starting journalnode, logging to /opt/hdp/hadoop-2.6.5/logs/hadoop-root-journalnode-localhost.localdomain.out
192.168.204.237: starting journalnode, logging to /opt/hdp/hadoop-2.6.5/logs/hadoop-root-journalnode-BFG-OSER-1308.out
```

格式化ZKFC，在master上执行：

```bash
[root@localhost hadoop-2.6.5]# bin/hdfs zkfc -formatZK
```

 格式成功后，查看zookeeper中可以看到

```bash
[zk: localhost:2181(CONNECTED) 1] ls /hadoop-ha
[mycluster]
```

格式化hdfs，master上执行：

```bash
bin/hadoop namenode -format
```

启动namenode，在master上执行：

```bash
sbin/hadoop-daemon.sh start namenode
```

在slave2上同步namenode的数据，同时启动standby的namenod,命令如下

```bash
bin/hdfs namenode –bootstrapStandby
sbin/hadoop-daemon.sh start namenode
```

启动启动datanode，在master上执行：

```bash
sbin/hadoop-daemons.sh start datanode
```

启动ZKFC，在master上执行如下命令，完成ZKFC的启动

```bash
sbin/hadoop-daemons.sh start zkfc
```

也可以单独没台上分别执行：

```bash
sbin/hadoop-daemon.sh start zkfc
```

全部启动后，分别jps查看进程：

```bash
[root@master hadoop-2.6.5]# jps
5984 DFSZKFailoverController
6562 Jps
6137 NameNode
5513 ResourceManager
5071 QuorumPeerMain

[root@slave1 hadoop-2.6.5]# jps
27605 NodeManager
27126 QuorumPeerMain
28025 Jps
27390 JournalNode

[root@slave2 hadoop-2.6.5]# jps
9924 JournalNode
10677 DFSZKFailoverController
10246 NodeManager
9718 QuorumPeerMain
10794 NameNode
11053 Jps
```

## 测试高可用

启动后master为active，slave2为standby

![image](/images/tech/hadoop-zk-ha-2.jpg)
![image](/images/tech/hadoop-zk-ha-3.jpg)

此时在master上执行如下命令，或者直接杀掉namenode进程关闭master上的namenode

```bash
sbin/hadoop-daemon.sh stop namenode
```

发现slave2自动切换为active。

![image](/images/tech/hadoop-zk-ha-4.jpg)

再次启动master上的namenode，则为standby，如此这可保证namenode的高可用。

![image](/images/tech/hadoop-zk-ha-5.jpg)

参考：
[HadoopHA简述](http://www.lishiyu.cn/post/68.html)
[Hadoop2.5.2 HA高可靠性集群搭建(Hadoop+Zookeeper)](http://eksliang.iteye.com/blog/2226986)
