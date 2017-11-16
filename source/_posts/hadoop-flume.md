---
layout: post
title: Flume安装使用
date: 2017-06-09 14:42:43
tags: [HADOOP]
---

Flume NG是Cloudera提供的一个分布式、可靠、可用的系统，它能够将不同数据源的海量日志数据进行高效收集、聚合、移动，最后存储到一个中心化数据存储系统中。

<!-- more -->

## 安装

```bash
http://mirrors.hust.edu.cn/apache/flume/1.7.0/apache-flume-1.7.0-bin.tar.gz 
tar -xzvf apache-flume-1.7.0-bin.tar.gz 
```

添加环境变量

```bash
#java
export JAVA_HOME=/opt/flume/jdk1.7.0_79
export PATH=$JAVA_HOME/bin:$JAVA_HOME/jre/bin:$PATH

#flume
export FLUME_HOME=/opt/flume/flume-1.7.0
export PATH=$PATH:$FLUME_HOME/bin
```

flume需要的是java7

## 配置

conf下添加一个配置文件，flume-tail.conf，添加如下内容，这里主要测试的是tail文件

```bash
agent.sources = src1 
agent.channels = ch1
agent.sinks = sink1

# For each one of the sources, the type is defined
agent.sources.src1.type = exec
agent.sources.src1.command=tail -F /opt/data/1.txt
agent.sources.src1.channels = ch1

# Each sink's type must be defined
agent.sinks.sink1.type = org.apache.flume.sink.kafka.KafkaSink
agent.sinks.sink1.kafka.bootstrap.servers = 103.15.202.158:9092
agent.sinks.sink1.partitioner.class=org.apache.flume.plugins.SinglePartition
agent.sinks.sink1.kafka.topic=test
agent.sinks.sink1.serializer.class=kafka.serializer.StringEncoder
agent.sinks.sink1.channel = ch1

# Each channel's type is defined.
agent.channels.ch1.type = memory
agent.channels.ch1.capacity = 100
```

Flume Source 支持的类型：

|Source类型	|说明 |
|-------------------|--------|	 
|Avro Source	|支持Avro协议（实际上是Avro RPC），内置支持	 
|Thrift Source	|支持Thrift协议，内置支持	 
|Exec Source	|基于Unix的command在标准输出上生产数据
|JMS Source	|从JMS系统（消息、主题）中读取数据，ActiveMQ已经测试过	 
|Spooling Directory Source	|监控指定目录内数据变更	 
|Twitter 1% firehose Source	|通过API持续下载Twitter数据，试验性质	 
|Netcat Source	|监控某个端口，将流经端口的每一个文本行数据作为Event输入	 
|Sequence Generator Source|	序列生成器数据源，生产序列数据	 
|Syslog Sources	|读取syslog数据，产生Event，支持UDP和TCP两种协议	 
|HTTP Source	|基于HTTP POST或GET方式的数据源，支持JSON、BLOB表示形式	 
|Legacy Sources	|兼容老的Flume OG中Source（0.9.x版本）	 

Flume Channel 支持的类型：

|Channel类型	|说明
|-------------------|------
|Memory Channel	|Event数据存储在内存中
|JDBC Channel	|Event数据存储在持久化存储中，当前Flume Channel内置支持Derby
|File Channel	|Event数据存储在磁盘文件中
|Spillable Memory Channel	|Event数据存储在内存中和磁盘上，当内存队列满了，会持久化到磁盘文件（当前试验性的，不建议生产环境使用）
|Pseudo Transaction Channel	|测试用途
|Custom Channel	|自定义Channel实现

Flume Sink支持的类型

|Sink类型 	|说明
|-------------------|---------
|HDFS Sink	|数据写入HDFS
|Logger Sink	|数据写入日志文件
|Avro Sink	|数据被转换成Avro Event，然后发送到配置的RPC端口上
|Thrift Sink	|数据被转换成Thrift Event，然后发送到配置的RPC端口上
|IRC Sink        |数据在IRC上进行回放
|File Roll Sink	|存储数据到本地文件系统
|Null Sink	|丢弃到所有数据
|HBase Sink	|数据写入HBase数据库
|Morphline Solr Sink	|数据发送到Solr搜索服务器（集群）
|ElasticSearch Sink	|数据发送到Elastic Search搜索服务器（集群）
|Kite Dataset Sink	|写数据到Kite Dataset，试验性质的
|Custom Sink	|自定义Sink实现


## 测试

kafka+zk环境搭建（略）

启动flume-ng：

```
bin/flume-ng agent -n agent -c conf -f conf/spool.conf -Dflume.root.logger=INFO,console
```
参数说明：

* -n 指定agent名称
* -c 指定配置文件目录
* -f 指定配置文件
* -Dflume.root.logger=DEBUG,console 设置日志等级

启动过程中，日志输出级别可以调高，方便及时发现错误

启动kafka消费者：

```
bin/kafka-console-consumer.sh --zookeeper 103.15.202.158:2181 --topic test --from-beginning
```
可以看到，输入到1.txt中的文件最后都会被消费者拿到。


### netcat源测试

配置修改：
```
agent.sources.src1.type = netcat
agent.sources.src1.channels = ch1
agent.sources.src1.bind = 192.168.202.162
agent.sources.src1.port = 4141
```

在终端向监听的端口发送消息：

```
echo "hello look hello hdfs" | nc 192.168.202.162 4141
```
kafka消费者可以拿到。

### sink：本地文件

```
#file_roll
agent.sinks.sink1.type = file_roll
agent.sinks.sink1.channel = ch1
agent.sinks.sink1.sink.directory = /opt/data/flume
```

还可设置文件生成时间间隔和文件名，详细见手册

### kafka到kafka

需要从其他业务线的kafka拉数据，存储到kafka中供消费使用

```bash
agent.sources = src1 
agent.channels = ch1
agent.sinks = sink1

#For each one of the sources
agent.sources.src1.type = org.apache.flume.source.kafka.KafkaSource
agent.sources.src1.channels = ch1
agent.sources.src1.batchSize = 5000
agent.sources.src1.batchDurationMillis = 2000
agent.sources.src1.kafka.bootstrap.servers = 192.168.5.194:9092, 192.168.5.195:9092, 192.168.5.196:9092, 192.168.5.197:9092, 192.168.5.198:9092, 192.168.5.199:9092, 192.168.5.200:9092
agent.sources.src1.kafka.topics = bf.bfsports.android.access.active, bf.bfsports.iphone.access.active

#interceptors 
agent.sources.src1.interceptors = i1
agent.sources.src1.interceptors.i1.type = static
agent.sources.src1.interceptors.i1.key = topic
agent.sources.src1.interceptors.i1.preserveExisting = false
agent.sources.src1.interceptors.i1.value = bf.dt.log

#kafka
agent.sinks.sink1.type = org.apache.flume.sink.kafka.KafkaSink
agent.sinks.sink1.kafka.bootstrap.servers = 103.15.202.158:9092,103.15.202.159:9092
agent.sinks.sink1.channel = ch1

# Each channel's type is defined.
agent.channels.ch1.type = memory
agent.channels.ch1.capacity = 10000
agent.channels.ch1.transactionCapacity = 10000
agent.channels.ch1.byteCapacityBufferPercentage = 20
agent.channels.ch1.byteCapacity = 1800000
```
配置的重点在于，会存在topic覆盖的问题，这里需要配置拦截器[Flume中同时使用Kafka Source和Kafka Sink的Topic覆盖问题](http://lxw1234.com/archives/2016/06/684.htm)

### sink：hdfs
```
agent.sinks.sink1.channel = ch1 
agent.sinks.sink1.type = hdfs
agent.sinks.sink1.hdfs.path = hdfs://192.168.206.184:9000/flume/events/%y%m%d%H0000
agent.sinks.sink1.hdfs.filePrefix = bfs_%y%m%d%H%M//文件名格式
agent.sinks.sink1.hdfs.fileSuffix = .log//文件后缀名
agent.sinks.sink1.hdfs.writeFormat = Text//文件格式
agent.sinks.sink1.hdfs.fileType = DataStream//文件类型，还可设置为压缩格式
agent.sinks.sink1.hdfs.useLocalTimeStamp = true
agent.sinks.sink1.hdfs.rollInterval = 300 //等待多长时间之后写文件，并不是写文件的时间间隔
agent.sinks.sink1.hdfs.roundUnit = second//写文件时间单位
agent.sinks.sink1.hdfs.rollCount = 0 //可以按照日志条数t写文件
agent.sinks.sink1.hdfs.rollSize = 0 //按照文件大小写文件
agent.sinks.sink1.hdfs.minBlockReplicas = 1 //文件拷贝份数，所以这里只能设置为1
agent.sinks.sink1.hdfs.round = true //时间单位设置
agent.sinks.sink1.hdfs.roundValue = 10 //表示精确到10分钟
agent.sinks.sink1.hdfs.roundUnit = minute //
agent.sinks.sink1.hdfs.batchSize = 100 //没多少条日志，写一次hdfs
agent.sinks.sink1.hdfs.threadsPoolSize = 10 //线程池个数
```
minBlocakReplicas必须设置为1，见[【Flume】【源码分析】flume中sink到hdfs，文件系统频繁产生文件，文件滚动配置不起作用？](http://blog.csdn.net/simonchi/article/details/43231891)
如果配置每五分钟写一个文件，则roundvalue精确到5分钟，同时rollinterval设置为5分钟。


参考：
[flume-1.7官方用户手册](https://flume.apache.org/FlumeUserGuide.html)
[基于Flume的美团日志收集系统(一)架构和设计](http://tech.meituan.com/mt-log-system-arch.html)
[Flume-ng的原理和使用](http://blog.javachen.com/2014/07/22/flume-ng.html)
[Flume中的HDFS Sink配置参数说明](http://lxw1234.com/archives/2015/10/527.htm)
[Flume整合kafka和hdfs出现的错误](http://www.ltingzyong.cn/2016/12/20/flume%E6%95%B4%E5%90%88kafka%E5%92%8Chdfs%E5%87%BA%E7%8E%B0%E7%9A%84%E9%94%99%E8%AF%AF/)
