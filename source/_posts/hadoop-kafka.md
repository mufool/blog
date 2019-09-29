---
title: Kafka安装使用
date: 2017-06-09 14:42:38
tags: [KAFKA]
---
## 关于kafka

Kafka是一种高吞吐量的分布式发布订阅消息系统，它可以处理消费者规模的网站中的所有动作流数据。 这种动作（网页浏览，搜索和其他用户的行动）是在现代网络上的许多社会功能的一个关键因素。 这些数据通常是由于吞吐量的要求而通过处理日志和日志聚合来解决。 对于像Hadoop的一样的日志数据和离线分析系统，但又要求实时处理的限制，这是一个可行的解决方案。Kafka的目的是通过Hadoop的并行加载机制来统一线上和离线的消息处理，也是为了通过集群机来提供实时的消费。

<!-- more -->

## kafka架构


## 安装配置

下载kafka安装包，访问Kafka官网下载对应版本即可。([备用地址](http://pic-blog.bfvyun.com/hadoop/zookeeper-3.4.9.tar.gz))这里使用的版本为2.9.2-0.8.1.1。

```bash
tar -zxvf kafka_2.12-0.10.2.0.tgz
```

修改配置文件，简单配置只需要修改/config/server.properties文件即可。

```bash
vim config/server.properties
```
需要修改的内容：

- broker.id：当前kafka服务的id
- listeners、post：监听的客户端连接端口
- log.dirs：kafka数据、索引存储位置
- zookeeper.connect：kafka依赖的zookeeper服务地址
把配置好的kafka上传到其他节点上

## 启动Kafka

```bash
bin/kafka-server-start.sh config/server.properties &
```

kafka服务启动完成后，执行jps，可以看到：

```bash
28208 Kafka
```

## 测试kafka

创建topic

```bash
bin/kafka-topics.sh -zookeeper 192.168.205.173:2181,192.168.204.237:2181 -topic test -replication-factor 2 -partitions 1 -create
```

- create：创建topic
- zookeeper：连接的zookeeper节点地址
- replication-factor：数据副本数量
- partitions：对创建的topic进行分片
- topic：要创建的topic名称

查看topic

```bash
bin/kafka-topics.sh -zookeeper 192.168.205.173:2181,192.168.204.237:2181 -list
```

创建producer：

```bash
bin/kafka-console-producer.sh --broker-list nutch1:9092 --topic test
```
- broker-list：此处不是zookeeper的地址，而是kafka客户端的地址
- topic：向哪个topic发送消息

创建consumer

```bash
bin/kafka-console-consumer.sh --bootstrap-server 192.168.205.173:9092 --topic test --from-beginning
bin/kafka-console-consumer.sh --bootstrap-server 103.15.202.158:9092 --topic test --consumer-property group.id=debug_user_num_tags --from-beginning
```

- bootstrap-server：这里为topic地址，替换--zookeeper选项
- from-beginning：kafka消息存储在文件内，能够重复消费，这里代表偏移量(offsets),不加此参数从最新数据开始接收
- topic：从哪个topic消费消息
- --consumer-property: 添加其他参数，这里添加groupid，默认是随机生成一个groupid

## 停止

```bash
bin/kafka-server-stop.sh
```

