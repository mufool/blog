---
title: Spark on yarn提交慢解决方法
date: 2017-06-09 14:42:16
tags: [HADOOP,SPARK]
---

## 现象

```bash
17/04/18 11:21:08 WARN Client: Neither spark.yarn.jars nor spark.yarn.archive is set, falling back to uploading libraries under SPARK_HOME.
```

<!-- more -->

spark on yarn提交慢，且提交时有warning提示，大意是：如果想要在yarn端（yarn的节点）访问spark的runtime jars，需要指定spark.yarn.archive 或者 spark.yarn.jars。如果都这两个参数都没有指定，spark就会把$SPARK_HOME/jars/所有的jar上传到分布式缓存中。这也是之前任务提交特别慢的原因。

## 解决方案

将$SPARK_HOME/jars/* 下spark运行依赖的jar上传到hdfs上。

```bash
hadoop fs -mkdir -p /tmp/spark/jars/
hadoop fs -put  /opt/hadoop/spark-2.1.0/jars/* /tmp/spark/jars/
```

vi $SPARK_HOME/conf/spark-defaults.conf

```bash
spark.yarn.jars  hdfs://master:9000/tmp/spark/jars/*.jar
```
再次提交，变快。

