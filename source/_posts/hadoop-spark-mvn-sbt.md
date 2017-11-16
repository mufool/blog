---
title: Spark程序编译运行
date: 2017-06-09 14:41:53
tags: [MAVEN]
---

## sbt构建scala应用

### 下载安装
sbt是一款Spark用来对scala编写程序进行打包的工具，[下载sbt-launch.jar](https://repo.typesafe.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/0.13.11/sbt-launch.jar)的下载地址。
安装在 /usr/local/sbt 中：

```bash
sudo mkdir /usr/local/sbt
sudo chown -R hadoop /usr/local/sbt		 # 此处的 hadoop 为你的用户名
cd /usr/local/sbt
```

<!-- more -->

下载后，执行如下命令拷贝至 /usr/local/sbt 中：

```bash
cp /opt/hdp/sbt-launch.jar ./
```

接着在 /usr/local/sbt 中创建 sbt 脚本（vim ./sbt），添加如下内容：

```bash
#!/bin/bash
SBT_OPTS="-Xms512M -Xmx1536M -Xss1M -XX:+CMSClassUnloadingEnabled -XX:MaxPermSize=256M"
java $SBT_OPTS -jar `dirname $0`/sbt-launch.jar "$@"
```

保存后，为 ./sbt 脚本增加可执行权限:

```bash
chmod u+x ./sbt
```

最后运行如下命令，检验 sbt 是否可用，首次运行会处于 “Getting org.scala-sbt sbt 0.13.11 ...” 的下载状态，请耐心等待

```bash
./sbt sbt-version
```

只要能得到如下图的版本信息就没问题：

```bash
:: retrieving :: org.scala-sbt#boot-scala
		confs: [default]
		5 artifacts copied, 0 already retrieved (24494kB/22ms)
[info] Set current project to sbt (in build file:/usr/local/sbt/)
[info] 0.13.11
```

### 编写scala应用程序

在终端中执行如下命令创建一个文件夹 sparkapp 作为应用程序根目录：

```bash
cd ~		   # 进入用户主文件夹
mkdir ./sparkapp		# 创建应用程序根目录
mkdir -p ./sparkapp/src/main/scala	   # 创建所需的文件夹结构
```

在 ./sparkapp/src/main/scala 下建立一个名为 SimpleApp.scala 的文件（vim ./sparkapp/src/main/scala/SimpleApp.scala），添加代码如下（目前不需要理解代码的具体含义，只需要理解如何编译运行代码就可以）：

```scala
 /* SimpleApp.scala */
	import org.apache.spark.SparkContext
	import org.apache.spark.SparkContext._
	import org.apache.spark.SparkConf
 
	object SimpleApp {
		def main(args: Array[String]) {
			val logFile = "file:///usr/local/spark/README.md" // Should be some file on your system
			val conf = new SparkConf().setAppName("Simple Application")
			val sc = new SparkContext(conf)
			val logData = sc.textFile(logFile, 2).cache()
			val numAs = logData.filter(line => line.contains("a")).count()
			val numBs = logData.filter(line => line.contains("b")).count()
			println("Lines with a: %s, Lines with b: %s".format(numAs, numBs))
		}
	}
```

### 使用 sbt 打包 Scala 程序

该程序依赖 Spark API，因此我们需要通过 sbt 进行编译打包。 ./sparkapp 中新建文件 simple.sbt（vim ./sparkapp/simple.sbt），添加内容如下，声明该独立应用程序的信息以及与 Spark 的依赖关系：


```bash
name := "Simple Project"
version := "1.0"
scalaVersion := "2.11.8"
libraryDependencies += "org.apache.spark" %% "spark-core" % "2.1.0"
```

为保证 sbt 能正常运行，先执行如下命令检查整个应用程序的文件结构：

```bash
[root@localhost sparkapp]# find .
.
./src
./src/main
./src/main/scala
./src/main/scala/SimpleApp.scala
./simple.sbt
```

接着，我们就可以通过如下代码将整个应用程序打包成 JAR（首次运行同样需要下载依赖包 ）：

```bash
/usr/local/sbt/sbt package
```

对于刚安装好的Spark和sbt而言，第一次运行上面的打包命令时，会需要几分钟的运行时间，因为系统会自动从网络上下载各种文件。后面再次运行上面命令，就会很快，因为不再需要下载相关文件。
打包成功的话，会输出如下图内容：

```powershell
[info] Packaging /opt/hdp/sparkapp/target/scala-2.11/simple-project_2.11-1.0.jar ...
[info] Done packaging.
[success] Total time: 697 s, completed Feb 28, 2017 6:32:05 PM
```

生成的 jar 包的位置为 ~/sparkapp/target/scala-2.11/simple-project_2.11-1.0.jar

### 通过spark-submit 运行程序

```bash
/opt/hdp/spark-2.1.0/bin/spark-submit --class "SimpleApp" /opt/hdp/sparkapp/target/scala-2.11/simple-project_2.11-1.0.jar  | grep 'Lines'
```

## maven构建java应用程序

### 下载安装maven

[apache-maven-3.3.9-bin.zip的下载地址](http://mirrors.hust.edu.cn/apache/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.zip)
选择安装在/usr/local/maven中：

```powershell
tar -xzvf apache-maven-3.3.9-bin.tar.gz 
cd /usr/local
sudo mv apache-maven-3.3.9/ ./maven
sudo chown -R hadoop ./maven
```

### 编写Java应用程序代码

在终端执行如下命令创建一个文件夹sparkapp2作为应用程序根目录
在 ./sparkapp2/src/main/java 下建立一个名为 SimpleApp.java 的文件（vim ./sparkapp2/src/main/java/SimpleApp.java），添加代码如下：

```java
/*** SimpleApp.java ***/
import org.apache.spark.api.java.*;
import org.apache.spark.api.java.function.Function;
 
public class SimpleApp {
	public static void main(String[] args) {
		String logFile = "file:///usr/local/spark/README.md"; // Should be some file on your system
		JavaSparkContext sc = new JavaSparkContext("local", "Simple App",
			"file:///usr/local/spark/", new String[]{"target/simple-project-1.0.jar"});
		JavaRDD<String> logData = sc.textFile(logFile).cache();
 
		long numAs = logData.filter(new Function<String, Boolean>() {
			public Boolean call(String s) { return s.contains("a"); }
		}).count();
 
		long numBs = logData.filter(new Function<String, Boolean>() {
			public Boolean call(String s) { return s.contains("b"); }
		}).count();
 
		System.out.println("Lines with a: " + numAs + ", lines with b: " + numBs);
	}
}
```

### maven打包应用

该程序依赖Spark Java API,因此我们需要通过Maven进行编译打包。在./sparkapp2中新建文件pom.xml(vim ./sparkapp2/pom.xml),添加内容如下，声明该独立应用程序的信息以及与Spark的依赖关系：

```xml
<project>
	<groupId>edu.berkeley</groupId>
	<artifactId>simple-project</artifactId>
	<modelVersion>4.0.0</modelVersion>
	<name>Simple Project</name>
	<packaging>jar</packaging>
	<version>1.0</version>
	<repositories>
		<repository>
			<id>Akka repository</id>
			<url>http://repo.akka.io/releases</url>
		</repository>
	</repositories>
	<dependencies>
		<dependency> <!-- Spark dependency -->
			<groupId>org.apache.spark</groupId>
			<artifactId>spark-core_2.10</artifactId>
			<version>2.1.0</version>
		</dependency>
	</dependencies>
</project>
```

接着，我们可以通过如下代码将这整个应用程序打包成Jar首次运行mvn package命令时，系统会自动从网络下载相关的依赖包，同样消耗几分钟的时间，后面再次运行mvn package命令，速度就会快很多):

```bash
/usr/local/maven/bin/mvn package
```

如出现下图，说明生成Jar包成功：

```bash
[INFO] --- maven-jar-plugin:2.4:jar (default-jar) @ simple-project ---
[INFO] Building jar: /opt/hdp/sparkapp2/target/simple-project-1.0.jar
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 1.469 s
[INFO] Finished at: 2017-03-03T12:46:57+08:00
[INFO] Final Memory: 32M/268M
[INFO] ------------------------------------------------------------------------
```

### 通过spark-submit 运行程序

最后，可以通过将生成的jar包通过spark-submit提交到Spark中运行，如下命令：

```bash
/opt/hdp/spark-2.1.0/bin/spark-submit  --class "SimpleApp" ~/sparkapp2/target/simple-project-1.0.jar
```

参考
[Spark安装和使用](http://dblab.xmu.edu.cn/blog/931-2/)
