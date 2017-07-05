---
title: Spark序列化
date: 2017-07-03 10:20:52
tags: [SPARK]
---
## 什么是序列化

&emsp;&emsp;对象的序列化（Serialization）用于将对象编码成一个字节流，以及从字节流中重新构建对象。将一个对象编码成一个字节流称为序列化该对象（Serializing）；相反的处理过程称为反序列化（Deserializing）。

<!-- more -->

序列化有三种主要的用途：

* 作为一种持久化格式：一个对象被序列化以后，它的编码可以被存储到磁盘上，供以后反序列化用。
* 作为一种通信数据格式：序列化结果可以从一个正在运行的虚拟机，通过网络被传递到另一个虚拟机上。
* 作为一种拷贝、克隆（clone）机制：将对象序列化到内存的缓存区中，然后通过反序列化，可以得到一个对已存对象进行深拷贝的新对象。
在分布式数据处理中，主要使用上面提到的前两种功能：数据持久化和通信数据格式。

## 为什么要序列化

&emsp;&emsp;在写Spark的应用时，尝尝会碰到序列化的问题。例如，在Driver端的程序中创建了一个对象，而在各个Executor中会用到这个对象 ，由于Driver端代码与Executor端的代码运行在不同的JVM中，甚至在不同的节点上，因此必然要有相应的序列化机制来支撑数据实例在不同的JVM或者节点之间的传输。

## 什么情况下需要序列化

以下一段spark代码：

```java
public class TransKey  implements Serializable {
	private String prefix;

	public TransKey() {
		prefix = "news_";
	}

	public String addPrefix(String s) {
		return prefix + s;
	}
}
```
 
```java
List<String> list = Arrays.asList("a","b","c");
JavaRDD<String> javaRDD = new JavaSparkContext(spark.sparkContext()).parallelize(list);

TransKey transKey = new TransKey();
JavaRDD<String> javaRDD1 = javaRDD.map(s -> transKey.addPrefix(s));
```

&emsp;&emsp;以上代码执行是会报错`org.apache.spark.SparkException: Task not serializable`，因为transkey在执行过程中需要从Driver传输到Executor。为Executor没有引用到Driver的实例。因此`TransKey `类需要实现序列化。

## 实现序列化

Spark可以使用Java的序列化框架。只要一个class实现了java.io.Serializable接口，那么Spark就能使用Java的ObjectOutputStream来序列化该类。

```java
public class TransKey implements Serializable {
    ...
}
```

对于用户自定义类，通过以上方法实现序列化即可正常使用。Spark还支持另一种序列化框架Kryo。Kryo是一个高效的序列化框架（可以比Java的序列化快10倍以上）。

```java
public class RedisUtilKryo implements KryoSerializable {
	private object pool = null;
	private Integer port;

	@Override
	public void write(Kryo kryo, Output output) {
		kryo.writeClassAndObject(output, pool);
	}

	@Override
	public void read(Kryo kryo, Input input) {
		pool = kryo.readClassAndObject(input);
	}
}
```

参考：
[Java 序列化的高级认识](https://www.ibm.com/developerworks/cn/java/j-lo-serial/index.html)
[spark-stream 访问 Redis](https://segmentfault.com/a/1190000006250481)
