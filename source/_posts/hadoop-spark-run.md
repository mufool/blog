---
title: Spark几种运行方式
date: 2017-06-09 14:41:29
tags: [HADOOP]
---

## Spark运行模式

Spark的运行模式多种多样，在单机上可以以Local和伪分布式模式运行；部署在集群上时有Spark内建的Standalone模式及对于外部框架的支持，有Mesos模式和Spark On YARN模式，这两者主要区别是资源管理交由谁负责。

<!-- more -->

### Local模式

本地模式，这种方式是在本地运行作业，其中local模式又分一下几种

1. local：所有计算都运行在一个线程当中，没有任何并行计算，通常我们在本机执行一些测试代码，或者练手，就用这种模式。
2. local[N]：指定使用几个线程来运行计算，比如local[4]就是运行4个worker线程。通常我们的cpu有几个core，就指定几个线程，最大化利用cpu的计算能力
3. local[*]：这种模式直接帮你按照cpu最多cores来设置线程数了。
4. local[N,M]：这里有两个参数，第一个代表的是用到的核个数；第二个参数代表的是容许该作业失败M次。上面的几种模式没有指定M参数，其默认值都是1；

```bash
/bin/spark-submit \
        --cluster cluster_name \
        --master local[*] \
        ...
```

### Standalone模式

Standalone模式中Spark集群中Master和Worker节点构成。用户程序通过与Master节点交互，申请所需资源，Worker节点负责具体Executor的启动运行。部署Standalone模式的集群仅需把编译好的Spark发布版本分发到各节点，部署路径尽量一致，且配置文件相同。

```bash
/bin/spark-submit \
        --cluster cluster_name \
        --master spark://host:port \
        ...
```

### Local Cluster模式

即伪分布式模式，是基于Standalone模式实现的，启动Master（主进程）和Worker（工作进程）的位置全部在本地。

### Yarn-standalone/Yarn-cluster模式，Mesos模式

通过Hadoop YARN框架或者mesos来调度Spark应用所需资源。适合生产模式。

```bash
/bin/spark-submit \
        --cluster cluster_name \
        --master mesos://host:port \
        ...
```

```bash
/bin/spark-submit \
        --cluster cluster_name \
        --master yarn-cluster \
        ...
```

### Yarn-client模式

这是YARN客户端模式。上面三种代表的是集群模式；这种代表的是客户端模式；

## Yarn-Cluster和Yarn-client模式区别

yarn-client主要用于与用户交互模式，yarn-cluster主要用于集群生产模式，主要区别是driver在运行位置，cluser模式下，driver运行在AM(app master)中，cluser模式下，driver在任务提交机上执行。

### client模式
Driver在任务提交机上执行，适用于交互和调试，也就是希望快速看到app的输出结果。ApplicationMaster只负责向ResourceManager申请executor需要的资源。client会和请求的container通信来调度他们工作，也就是client不能关闭。基于yarn时，spark-shell和pyspark必须要使用yarn-client模式。

[图片来自网络](https://www.slideshare.net/Hadoop_Summit/sparkonyarn-empower-spark-applications-on-hadoop-cluster)

![spark-client](http://pic-blog.bfvyun.com/spark/yarn-client.jpg)

### cluster模式
Driver运行在ApplicationMaster中，应用在生产过程中。Driver以及资源申请都在AppMaster执行，负责向YARN申请资源，并监督作业的运行状况。当用户提交完作业之后，就关闭client，作业会继续在YARN上。

![spark-cluster](http://pic-blog.bfvyun.com/spark/yarn-cluster.jpg)

参考：
[谈谈Spark运行模式](https://www.zybuluo.com/sasaki/note/252413)
[Apache Spark探秘：三种分布式部署方式比较](http://dongxicheng.org/framework-on-yarn/apache-spark-comparing-three-deploying-ways/)






















