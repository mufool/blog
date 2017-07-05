---
title: Spark中redis连接池的几种使用方法
date: 2017-07-04 17:37:11
tags: [SPARK,REDIS]
---

&emsp;&emsp;spark是一个大数据的分布式的计算框架，他的工作机制核心也是分布式，所以很多地方的使用一定要先理解它的工作机制，很多问题和性能优化都和spark的工作机制紧密相关。
&emsp;&emsp;这里主要介绍spark中redis的几种使用方法，通过使用方法理解spark的工作机制。

<!-- more -->

## 方法一：Master上集中处理

&emsp;&emsp;Spark采用了分布式计算中的Master-Slave模型。Master作为整个集群的控制器，负责整个集群的正常运行；Worker是计算节点，接受主节点命令以及进行状态汇报。这种方式便是将Worker上的所有数据收集到Master上，然后遍历写入redis。

TestRedisPool代码：

```java
public class TestRedisPool {
	private JedisPool pool = null;

	public TestRedisPool(String ip, int port, String passwd, int database) {
		if (pool == null) {
			JedisPoolConfig config = new JedisPoolConfig();
			config.setMaxTotal(500);
			config.setMaxIdle(30);
			config.setMinIdle(5);
			config.setMaxWaitMillis(1000 * 10);
			config.setTestWhileIdle(false);
			config.setTestOnBorrow(false);
			config.setTestOnReturn(false);
			pool = new JedisPool(config, ip, port, 10000, passwd, database);
			Logs.debug("init:" + pool);
		}
	}

	public JedisPool getRedisPool() {
		return pool;
	}

	public String set(String key,String value){
		Jedis jedis = null;
		try {
			jedis = pool.getResource();
			return jedis.set(key, value);
		} catch (Exception e) {
			e.printStackTrace();
			return "0";
		} finally {
			jedis.close();
		}
	}
}
```

示例代码如下，rdd对应在三个分区上：

```java
List<String> list = Arrays.asList("a","b","c","d", "e");
JavaRDD<String> javaRDD = new JavaSparkContext(spark.sparkContext()).parallelize(list, 3);

TestRedisPool testRedisPool = new TestRedisPool(redisIp, port, passwd, dbNum);
List<String> lst = javaRDD.collect();

for(String s:lst) {
	testRedisPool.set(s, getDateString2(0));
}
```

&emsp;&emsp;所有数据collect到Master上，只需要建立一个redis连接池处理。虽然减少了redis连接数，但是所有数据需要collect到Master上，大数据量的处理对Master压力较大，性能较差。

## 方法二：Worker上遍历所有数据

&emsp;&emsp;spark中所有的数据处理分为Tranformation和Action，foreach就是一个Action，通过foreach按分区遍历所有的数据进行处理，这种情况下输出只能在分区上看到，Master上无法看到。

```java
javaRDD.foreach(new VoidFunction<String>() {
	@Override
	public void call(String s) throws Exception {
		TestRedisPool testRedisPool = new TestRedisPool(redisIp, port, passwd, dbNum);
		Logs.debug(testRedisPool.getRedisPool());
		testRedisPool.set(s, getDateString2(0));
	}
});
```

Worker上的输出：

```bash
	2017-07-04 12:59:18 DEBUG: redis.clients.jedis.JedisPool@6bc8c6df
	2017-07-04 12:59:18 DEBUG: redis.clients.jedis.JedisPool@46c2ca89
	2017-07-04 12:59:18 DEBUG: redis.clients.jedis.JedisPool@ac221bf
	2017-07-04 12:59:18 DEBUG: redis.clients.jedis.JedisPool@1bccc548
	2017-07-04 12:59:18 DEBUG: redis.clients.jedis.JedisPool@25c1ef20
```

&emsp;&emsp;按分区历所有元素，TestRedisPool不需要实现序列化；每一个RDD中的元素都需要创建很多的redis连接池，即便使用短连接也会对redis造成很大的压力。效率也是极其低下的。

## 方法三：Master上创建，Worker上遍历所有数据

&emsp;&emsp;如果在Master上创建一个实例，在进行分区遍历时使用Master上创建的实例，这种方式是可以的，只需要将类实现序列即可。同时还可以通过广播变量，将实例在Worker上持久化，减少实例使用时的网络传输。

```java
TestRedisPool testRedisPool = new TestRedisPool(redisIp, port, passwd, dbNum);
javaRDD.foreach(new VoidFunction<String>() {
	@Override
	public void call(String s) throws Exception {
		Logs.debug(testRedisPool.getRedisPool());
		testRedisPool.set(s, getDateString2(0));
	}
});
```

输出

```bash
Exception in thread "main" org.apache.spark.SparkException: Task not serializable
...
Serialization stack:
	- object not serializable (class: redis.clients.jedis.JedisPool, value: redis.clients.jedis.JedisPool@3e4f80cb)
```

&emsp;&emsp;报错jedispool无法序列化，即使TestRedisPool类实现了序列化，但因为其成员变量jedispool本身并不支持序列化，所以这种方式在有成员变量无法序列化时也不可用。

## 方法四：Worker上按分区遍历

&emsp;&emsp;`foreachPartitions`也是一个Action操作，`foreach`和`foreachPartitions`的实现如下：

```scala
def foreach(f: T => Unit) {
	val cleanF = sc.clean(f)
	sc.runJob(this, (iter: Iterator[T]) => iter.foreach(cleanF))
}
```

```scala
def foreachPartition(f: Iterator[T] => Unit) {
	val cleanF = sc.clean(f)
	sc.runJob(this, (iter: Iterator[T]) => cleanF(iter))
}
```

&emsp;&emsp;`foreach`是使用提供的函数调用分区迭代器的`foreach`处理，`foreachPartition`是直接传入的是分区的指针。所以，其实`foreach`和`foreachPartition`并没有什么区别，`foreachPartition`只是让你有机会在迭代器的循环之外做一些事情，通常是像数据库连接或者redis等。所以，如果你没有任何可以对每个分区的迭代器做一次，并在整个过程中重复使用的操作，建议还是使用`foreach`来提高清晰度和降低复杂度。

```java
javaRDD.foreachPartition(new VoidFunction<Iterator<String>>() {
	@Override
	public void call(Iterator<String> stringIterator) throws Exception {
		TestRedisPool testRedisPool = new TestRedisPool(redisIp, port, passwd, dbNum);
		while (stringIterator.hasNext()) {
			Logs.debug(testRedisPool.getRedisPool());
			testRedisPool.set(stringIterator.next(), getDateString2(0));
		}
	}
});
```

Worker上的输出

```bash
	2017-07-04 13:30:29 DEBUG: redis.clients.jedis.JedisPool@21545755
	2017-07-04 13:30:29 DEBUG: redis.clients.jedis.JedisPool@111b1ab4
	2017-07-04 13:30:29 DEBUG: redis.clients.jedis.JedisPool@2b9b3bd5
	2017-07-04 13:30:29 DEBUG: redis.clients.jedis.JedisPool@21545755
	2017-07-04 13:30:29 DEBUG: redis.clients.jedis.JedisPool@111b1ab4
```

&emsp;&emsp;TestRedisPool不需要实现序列化，每个分区只需要创建一个redis连接池，正常情况下会创建和线程数一样多的连成池，这种情况下，redis连接池数量明显减少。

&emsp;&emsp;TestRedisPool在Master上定义时，和方法三种一样，同样因为jedispool无法序列化报错。

## 方法五：使用静态类型，按分区遍历

&emsp;&emsp;在方法四中，我们可以做到在每个分区上建立连接池，但是每台机器一般对应多个分区，怎么进一步减少连接池的创建呢。我们知道静态类型全局只有一份，如果将redis连接池定义为静态类型，做到每个worker上只创建一个redis连接池。

```java
public class TestRedisPool {
	private static JedisPool pool = null;
	...
}
```

使用示例：

```java
TestRedisPool testRedisPool = new TestRedisPool(redisIp, port, passwd, dbNum);
javaRDD.foreachPartition(new VoidFunction<Iterator<String>>() {
	@Override
	public void call(Iterator<String> stringIterator) throws Exception {
		while (stringIterator.hasNext()) {
			Logs.debug(testRedisPool.getRedisPool());
			testRedisPool.set(stringIterator.next(), getDateString2(0));
		}
	}
});
```

这种在Master上创建TestRedisPool实例的方式，在worker上无法获取到，会报`java.lang.NullPointerException`异常。

```java
javaRDD.foreachPartition(new VoidFunction<Iterator<String>>() {
	@Override
	public void call(Iterator<String> stringIterator) throws Exception {
		TestRedisPool testRedisPool = new TestRedisPool(redisIp, port, passwd, dbNum);
		while (stringIterator.hasNext()) {
			Logs.debug(testRedisPool.getRedisPool());
			testRedisPool.set(stringIterator.next(), getDateString2(0));
		}
	}
});
```

Worker输出

```bash
	2017-07-04 16:38:04 DEBUG: init:redis.clients.jedis.JedisPool@416605b2
	2017-07-04 16:38:04 DEBUG: init:redis.clients.jedis.JedisPool@416605b2
	2017-07-04 16:38:04 DEBUG: redis.clients.jedis.JedisPool@416605b2
	2017-07-04 16:38:04 DEBUG: redis.clients.jedis.JedisPool@416605b2
	2017-07-04 16:38:04 DEBUG: init:redis.clients.jedis.JedisPool@416605b2
	2017-07-04 16:38:04 DEBUG: redis.clients.jedis.JedisPool@416605b2
	2017-07-04 16:38:04 DEBUG: redis.clients.jedis.JedisPool@416605b2
	2017-07-04 16:38:04 DEBUG: redis.clients.jedis.JedisPool@416605b2
```

&emsp;&emsp;TestRedisPool也不需要序列化。因为本实验环境中只有一个worker节点，所以这里看到始终只有一个redis连接池实例。这种情况下是在分区上分别创建实例，分区对应的就是虚拟线程的个数，所以相当于3个线程同时去获取jedispool实现，所以一共init了三次。如果做成单例模式就能解决init多次的问题。

## 方法六：使用单例模式，按分区遍历

jedispool使用单例模式实现：

```java
public class TestRedisPool {
	private static JedisPool pool = null;
	String ip;
	Integer port;
	String passwd;
	Integer database;

	public TestRedisPool(String ip, int port, String passwd, int database) {
		this.ip = ip;
		this.port = port;
		this.passwd = passwd;
		this.database = database;
	}

	public JedisPool getRedisPool() {
		if (pool == null) {
			synchronized (RedisUtils.class) {
				if (pool == null) {
					JedisPoolConfig config = new JedisPoolConfig();
					config.setMaxTotal(500);
					config.setMaxIdle(30);
					config.setMinIdle(5);
					config.setMaxWaitMillis(1000 * 10);
					config.setTestWhileIdle(false);
					config.setTestOnBorrow(false);
					config.setTestOnReturn(false);
					pool = new JedisPool(config, ip, port, 10000, passwd, database);
					Logs.debug("init:" + pool);
				}
			}
		}
		return pool;
	}
	...
}
```

&emsp;&emsp;以上`volatile`保证当jedispool未初始化完成是不能被获取到，`synchronized`解决多线程冲突的问题。这两个关键词的使用其实也就是`lazy initialize`的实现。

```java
javaRDD.foreachPartition(new VoidFunction<Iterator<String>>() {
	@Override
	public void call(Iterator<String> stringIterator) throws Exception {
		TestRedisPool testRedisPool = new TestRedisPool(redisIp, port, passwd, dbNum);
		while (stringIterator.hasNext()) {
			Logs.debug("class:" + testRedisPool );
			Logs.debug("pool:" + testRedisPool .getRedisPool());
			testRedisPool .set(stringIterator.next(), getDateString2(0));
		}
	}
});
```

节点上输出如下：

```bash
	2017-07-04 17:13:48 DEBUG: class:test.TestRedisPool@4ac996de
	2017-07-04 17:13:48 DEBUG: class:test.TestRedisPool@7f6973f9
	2017-07-04 17:13:48 DEBUG: class:test.TestRedisPool@1e24e8f6
	2017-07-04 17:13:48 DEBUG: init:redis.clients.jedis.JedisPool@68caaac
	2017-07-04 17:13:48 DEBUG: pool:redis.clients.jedis.JedisPool@68caaac
	2017-07-04 17:13:48 DEBUG: pool:redis.clients.jedis.JedisPool@68caaac
	2017-07-04 17:13:48 DEBUG: pool:redis.clients.jedis.JedisPool@68caaac
	2017-07-04 17:13:48 DEBUG: class:test.TestRedisPool@7f6973f9
	2017-07-04 17:13:48 DEBUG: pool:redis.clients.jedis.JedisPool@68caaac
	2017-07-04 17:13:48 DEBUG: class:test.TestRedisPool@1e24e8f6
	2017-07-04 17:13:48 DEBUG: pool:redis.clients.jedis.JedisPool@68caaac
```

&emsp;&emsp;可以看到现在jedispool只init了一次，并且全局也只有一个jedispool。但是现在TestRedisPool对象还是被创建了多个，改为在Master上定义，并已广播变量的形式分发到Worker上可以解决这个问题，这种情况下TestRedisPool需要序列化。

## 方法七：使用单例模式，Driver上定义，分区上遍历

 ```java
TestRedisPool testRedisPool = new TestRedisPool(redisIp, port, passwd, dbNum);
final Broadcast<TestRedisPool> broadcastRedis = new JavaSparkContext(spark.sparkContext()).broadcast(testRedisPool);
javaRDD.foreachPartition(new VoidFunction<Iterator<String>>() {
	@Override
	public void call(Iterator<String> stringIterator) throws Exception {
		TestRedisPool redisClient1 = broadcastRedis.getValue();
		while (stringIterator.hasNext()) {
			Logs.debug("class:" + redisClient1);
			Logs.debug("pool:" + redisClient1.getRedisPool());
			redisClient1.set(stringIterator.next(), getDateString2(0));
		}
	}
});
```

输出如下，类实例和redispool都只创建一次，也使用同一个。

```bash
	2017-07-04 17:17:32 DEBUG: class:test.TestRedisPool@62044018
	2017-07-04 17:17:32 DEBUG: class:test.TestRedisPool@62044018
	2017-07-04 17:17:32 DEBUG: class:test.TestRedisPool@62044018
	2017-07-04 17:17:32 DEBUG: init:redis.clients.jedis.JedisPool@3a820c05
	2017-07-04 17:17:32 DEBUG: pool:redis.clients.jedis.JedisPool@3a820c05
	2017-07-04 17:17:32 DEBUG: pool:redis.clients.jedis.JedisPool@3a820c05
	2017-07-04 17:17:32 DEBUG: pool:redis.clients.jedis.JedisPool@3a820c05
	2017-07-04 17:17:32 DEBUG: class:test.TestRedisPool@62044018
	2017-07-04 17:17:32 DEBUG: pool:redis.clients.jedis.JedisPool@3a820c05
	2017-07-04 17:17:32 DEBUG: class:test.TestRedisPool@62044018
	2017-07-04 17:17:32 DEBUG: pool:redis.clients.jedis.JedisPool@3a820c05
```

&emsp;&emsp;现在是TestRedisPool在Master上定义，广播到各个Worker上；同时jedispool在每台worker上也始终只会有一个实例存在。但是也会有人会疑问，为什么jedispool现在没有序列化的问题（方法三），或者定义成静态导致worker上获取不到jedispool（方法五第一种情况）的问题。这是因为，方法三中jedispool为普通类型是，和类一起序列化，因为其本身不支持序列化，所以报错；方法五中，定义成静态类型之后，静态类型不属于类，所以TestRedisPool序列化不会出错，但是因为jedispool在Master上定义和初始化，不会传输到节点上，节点上获取到的jedispool都为null，所以报错。而方法七中使用懒启动的方式，在使用的是才会初始化jedispool，所以实际是在节点上完成的初始化，所以不会有问题。

参考：
[Java中单例模式实现](https://www.zhihu.com/question/29971746)
