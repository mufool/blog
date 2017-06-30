---
title: Hadoop和Spark部署
date: 2017-06-09 14:40:53
tags: [HADOOP]
---

## SSH 免密码登录

安装Openssh server

<!-- more -->

```bash
sudo yum install openssh-server
```
在所有机器上都生成私钥和公钥

```bash
ssh-keygen -t rsa   #一路回车
```

需要让机器间都能相互访问，就把每个机子上的id_rsa.pub发给master节点，传输公钥可以用scp来传输。

```bash
scp ~/.ssh/id_rsa.pub spark@master:~/.ssh/id_rsa.pub.slave1
```

在master上，将所有公钥加到用于认证的公钥文件authorized_keys中

```bash
cat ~/.ssh/id_rsa.pub* >> ~/.ssh/authorized_keys
```

将公钥文件authorized_keys分发给每台slave

```
scp ~/.ssh/authorized_keys spark@slave1:~/.ssh/
```

在每台机子上验证SSH无密码通信

```bash
ssh master
ssh slave1
ssh slave2
```

如果登陆测试不成功，则可能需要修改文件authorized_keys的权限（权限的设置非常重要，因为不安全的设置安全设置,会让你不能使用RSA功能 ）

```bash
chmod 600 ~/.ssh/authorized_keys
```

## 安装 Java
从官网下载最新版 Java 就可以，Spark官方说明 Java 只要是6以上的版本都可以，我下的是jdk-8u121-linux-x64.tar.gz
在/opt/hdp目录下直接解压

```
tar -xzvf jdk-8u121-linux-x64.tar.gz
```

修改环境变量sudo vi /etc/profile，添加下列内容，注意将home路径替换成你的：

```bash
export WORK_SPACE=/opt/hadoop
export HADOOP_HOME=$WORK_SPACE/hadoop-2.6.5
export JAVA_HOME=$WORK_SPACE/jdk1.8.0_121
export PATH=$JAVA_HOME/bin:$JAVA_HOME/jre/bin:$PATH
export CLASSPATH=$CLASSPATH:.:$JAVA_HOME/lib:$JAVA_HOME/jre/lib
```

然后使环境变量生效，并验证 Java 是否安装成功

```bash
$ source /etc/profile   #生效环境变量
$ java -version         #如果打印出如下版本信息，则说明安装成功
java version "1.8.0_121"
Java(TM) SE Runtime Environment (build 1.8.0_121-b13)
Java HotSpot(TM) 64-Bit Server VM (build 25.121-b13, mixed mode)
```

## 安装 Scala
Spark官方要求 Scala 版本为 2.11.8，注意不要下错版本，我这里下了 2.11.8，[官方下载地址](http://downloads.lightbend.com/scala/2.11.8/scala-2.11.8.tgz)

同样我们在~/workspace中解压

```bash
tar -zxvf scala-2.11.8.tgz
```

再次修改环境变量sudo vi /etc/profile，添加以下内容：

```bash
export SCALA_HOME=$WORK_SPACE/scala-2.11.8
export PATH=$PATH:$SCALA_HOME/bin
```

同样的方法使环境变量生效，并验证 scala 是否安装成功

```bash
$ source /etc/profile   #生效环境变量
$ scala -version        #如果打印出如下版本信息，则说明安装成功
Scala code runner version 2.11.8 -- Copyright 2002-2016, LAMP/EPFL
```

## 安装配置 Hadoop YARN

### 官网下载解压

同样我们在~/workspace中解压

```
tar -zxvf hadoop-2.6.5.tar.gz
```

### 配置 Hadoop

cd ~/hadoop/hadoop-2.6.5/etc/hadoop进入hadoop配置目录，需要配置有以下7个文件：hadoop-env.sh，yarn-env.sh，slaves，core-site.xml，hdfs-site.xml，maprd-site.xml，yarn-site.xml

1、在hadoop-env.sh中配置JAVA_HOME

```bash
# The java implementation to use.
export JAVA_HOME=/opt/hadoop/jdk1.8.0_121
```

2、在yarn-env.sh中配置JAVA_HOME

```
# some Java parameters
export JAVA_HOME=/opt/hadoop/jdk1.8.0_121
```

3、在slaves中配置slave节点的ip或者host，

```
slave1
slave2
```
4、修改core-site.xml

```xml
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://master:9000/</value>
    </property>
    <property>
         <name>hadoop.tmp.dir</name>
         <value>file:/home/spark/workspace/hadoop-2.6.0/tmp</value>
    </property>
</configuration>
```

* `fs.default.name`是NameNode的URI。`hdfs://主机名:端口/`
* `hadoop.tmp.dir` ：Hadoop的默认临时路径，这个最好配置，如果在新增节点或者其他情况下莫名其妙的DataNode启动不了，就删除此文件中的tmp目录即可。不过如果删除了NameNode机器的此目录，那么就需要重新执行NameNode格式化的命令。

5、修改hdfs-site.xml

```xml
<configuration>
    <property>
        <name>dfs.namenode.secondary.http-address</name>
        <value>master:9001</value>
    </property>
    <property>
        <name>dfs.namenode.name.dir</name>
        <value>file:/opt/hdp/hadoop-2.6.5/dfs/name</value>
    </property>
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>file:/opt/hdp/hadoop-2.6.5/dfs/data</value>
    </property>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>
</configuration>
```

* `dfs.name.dir`是NameNode持久存储名字空间及事务日志的本地文件系统路径。 当这个值是一个逗号分割的目录列表时，nametable数据将会被复制到所有目录中做冗余备份。
* `dfs.data.dir`是DataNode存放块数据的本地文件系统路径，逗号分割的列表。 当这个值是逗号分割的目录列表时，数据将被存储在所有目录下，通常分布在不同设备上。
* `dfs.replication`是数据需要备份的数量，默认是3，如果此数大于集群的机器数会出错。
注意：此处的name1、name2、data1、data2目录不能预先创建，hadoop格式化时会自动创建，如果预先创建反而会有问题。

6、修改mapred-site.xml

```xml
<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
</configuration>
```

7、修改yarn-site.xml

```xml
<configuration>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
    <property>
        <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
        <value>org.apache.hadoop.mapred.ShuffleHandler</value>
    </property>
    <property>
        <name>yarn.resourcemanager.address</name>
        <value>master:8032</value>
    </property>
    <property>
        <name>yarn.resourcemanager.scheduler.address</name>
        <value>master:8030</value>
    </property>
    <property>
        <name>yarn.resourcemanager.resource-tracker.address</name>
        <value>master:8035</value>
    </property>
    <property>
        <name>yarn.resourcemanager.admin.address</name>
        <value>master:8033</value>
    </property>
    <property>
        <name>yarn.resourcemanager.webapp.address</name>
        <value>master:8088</value>
    </property>
</configuration>
```

将配置好的hadoop-2.6.0文件夹分发给所有slaves吧

```bash
scp -r ~/workspace/hadoop-2.6.0 spark@slave1:~/workspace/
```

### 启动 Hadoop

在 master 上执行以下操作，就可以启动 hadoop 了。

```bash
/opt/hadoop/hadoop-2.6.5    #进入hadoop目录
bin/hadoop namenode -format     #格式化namenode
sbin/start-dfs.sh               #启动dfs 
sbin/start-yarn.sh              #启动yarn
```

验证 Hadoop 是否安装成功，可以通过jps命令查看各个节点启动的进程是否正常。在 master 上应该有以下几个进程：

```bash
$ jps  #run on master
3407 SecondaryNameNode
3218 NameNode
3552 ResourceManager
3910 Jps
```

在每个slave上应该有以下几个进程：

```bash
$ jps   #run on slaves
2072 NodeManager
2213 Jps
1962 DataNode
```

或者在浏览器中输入 http://192.168.205.173:8088 ，应该有 hadoop 的管理界面出来了，并能看到 slave1 和 slave2 节点。

## Spark安装

### 下载解压

进入官方下载地址下载最新版 Spark。我下载的是`spark-1.3.0-bin-hadoop2.4.tgz`。

在~/workspace目录下解压

```bash
tar -zxvf spark-2.1.0-bin-hadoop2.6.tgz
mv spark-2.1.0-bin-hadoop2.6.tgz  spark-2.1.0    #原来的文件名太长了，修改下
```

### 配置 Spark

```bash
cd  /opt/hadoop/spark-2.1.0/conf    #进入spark配置目录
cp spark-env.sh.template spark-env.sh   #从配置模板复制
```

在spark-env.sh末尾添加以下内容（这是我的配置，你可以自行修改）：

```bash
export SCALA_HOME=/opt/hadoop/scala-2.11.8
export JAVA_HOME=/opt/hadoop/jdk1.8.0_121
export HADOOP_HOME=/opt/hadoop/hadoop-2.6.5
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export SPARK_MASTER_HOST=master
export SPARK_LOCAL_IP=192.168.206.184
export MASTER=spark://${SPARK_MASTER_IP}:${SPARK_MASTER_PORT}
export SPARK_MASTER_PORT=7077
export SPARK_LOCAL_DIRS=/opt/hadoop/spark-2.1.0
export SPARK_DRIVER_MEMORY=2G
export SPARK_EXECUTOR_MEMORY=2G
```

注：在设置Worker进程的CPU个数和内存大小，要注意机器的实际硬件条件，如果配置的超过当前Worker节点的硬件条件，Worker进程会启动失败。

vi slaves在slaves文件下填上slave主机名：

```bash
slave1
slave2
```

将配置好的spark-2.1.0文件夹分发给所有slaves吧

```bash
scp -r spark-2.1.0 root@slave1:/opt/hadoop/
```

### 启动Spark

```bash
sbin/start-all.sh
```

### 验证 Spark 是否安装成功

用jps检查，在 master 上应该有以下几个进程：

```bash
$ jps
7949 Jps
7328 SecondaryNameNode
7805 Master
7137 NameNode
7475 ResourceManager
```

在 slave 上应该有以下几个进程：

```bash
$jps
3132 DataNode
3759 Worker
3858 Jps
3231 NodeManager
```

进入Spark的Web管理页面： http://192.168.204.184:8080

## 运行示例

```shell
#本地模式两线程运行
./bin/run-example SparkPi 10 --master local[2]

#Spark Standalone 集群模式运行
./bin/spark-submit \
  --class org.apache.spark.examples.SparkPi \
  --master spark://master:7077 \
  lib/spark-examples-1.3.0-hadoop2.4.0.jar \
  100

#Spark on YARN 集群上 yarn-cluster 模式运行
./bin/spark-submit \
    --class org.apache.spark.examples.SparkPi \
    --master yarn \  # can also be `yarn-client`
    lib/spark-examples*.jar \
    10
```


`--class`: 你的应用的启动类 (如 org.apache.spark.examples.SparkPi)
`--master`: 集群的master URL (如 spark://23.195.26.187:7077)
`--deploy-mode`: 是否发布你的驱动到worker节点(cluster) 或者作为一个本地客户端 (client) (default: client)*
`--conf`: 任意的Spark配置属性， 格式key=value. 如果值包含空格，可以加引号
`application-jar`: 打包好的应用jar,包含依赖. 这个URL在集群中全局可见。 比如hdfs:// 共享存储系统， 如果是 file://path， 那么所有的节点的path都包含同样的jar.
`application-arguments`: 传给main()方法的参数


参考：
[CentOS配置ssh无密码登录](https://my.oschina.net/u/1169607/blog/175899)
[Spark On YARN 集群安装部署](http://wuchong.me/blog/2015/04/04/spark-on-yarn-cluster-deploy/)
[Hadoop集群配置（最全面总结）](http://blog.csdn.net/hguisu/article/details/7237395)
