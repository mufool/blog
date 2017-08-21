---
title: log4j2使用
date: 2017-07-06 18:08:41
tags: [JAVA]
---
## 基本使用

pom.xml中添加依赖

<!-- more -->

```xml
<dependencies>
	<dependency>
		<groupId>org.apache.logging.log4j</groupId>
		<artifactId>log4j-api</artifactId>
		<version>2.5</version>
	</dependency>
	<dependency>
		<groupId>org.apache.logging.log4j</groupId>
		<artifactId>log4j-core</artifactId>
		<version>2.5</version>
	</dependency>
</dependencies>
```

使用示例：

```java
public static void main(String[] args) {
	Logger logger = LogManager.getLogger(Logs.class.getName());
	logger.trace("trace level");
	logger.debug("debug level");
	logger.info("info level");
	logger.warn("warn level");
	logger.error("error level");
	logger.fatal("fatal level");
}
```

这里需要注意的是应用头文件是log4j2的头文件

```java
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
```

而非

```java
import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
```
否则会出现编译执行通过，无法打印日志的问题

```bash
ERROR StatusLogger No log4j2 configuration file found. Using default configuration: logging only errors to the console.
20:37:11.965 [main] ERROR  - error level
20:37:11.965 [main] FATAL  - fatal level
```

显示找不到配置文件，使用了默认的配置，输出了error和fatal两个级别的信息。

## 配置文件详解

log4j2默认会在classpath目录下寻找log4j.json、log4j.jsn、log4j2.xml等名称的文件，如果都没有找到，则会按默认配置输出，也就是输出到控制台。下面我们按默认配置添加一个log4j2.xml，添加到src根目录即可

log4j 2.x版本不再支持像1.x中的.properties后缀的文件配置方式，2.x版本配置文件后缀名只能为".xml",".json"或者".jsn"。
系统选择配置文件的优先级如下：

1. classpath下的名为log4j2-test.json 或者log4j2-test.jsn的文件
2. classpath下的名为log4j2-test.xml的文件
3. classpath下名为log4j2.json 或者log4j2.jsn的文件
4. classpath下名为log4j2.xml的文件

我们一般默认使用log4j2.xml进行命名。如果本地要测试，可以把log4j2-test.xml放到classpath，而正式环境使用log4j2.xml，则在打包部署的时候不要打包log4j2-test.xml即可。

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration status="OFF"， monitorinterval="30">
	<appenders>
		<Console name="Console" target="SYSTEM_OUT">
			<PatternLayout pattern="%d{HH:mm:ss.SSS} [%t] %-5level %logger{36} - %msg%n"/>
		</Console>
	</appenders>
	<loggers>
		<root level="trace">
			<appender-ref ref="Console"/>
		</root>
	</loggers>
</configuration>
```

根节点Configuration有两个属性：status和monitorinterval

- status用来指定log4j本身的打印日志的级别
- monitorinterval用于指定log4j自动重新配置的监测间隔时间，单位是s，最小是5s

有两个子节点:Appenders和Loggers

### Appenders

Appenders负责定义日志输出的目的地，它可以是控制台（ConsoleAppender）、文件（FileAppender）、以Email的形式发送出去（SMTPAppender）等，Log4j 2官网介绍了20种Appender：http://logging.apache.org/log4j/2.x/manual/appenders.html。

下面介绍3种常用的Appender：ConsoleAppender、FileAppender、RollingFileAppender

**1.ConsoleAppender**

ConsoleAppender将输出写到System.err或System.out。上面测试例子中的Appender均为ConsoleAppender，输出写到了System.out。如果想将输出写到System.err，设置Console标签下的target为"SYSTEM_ERR "即可

- name：指定Appender的名字
- target：SYSTEM_OUT 或 SYSTEM_ERR,一般只设置默认:SYSTEM_OUT
- PatternLayout：输出格式，不设置默认为:%m%n

**2.FileAppender**

FileAppender将输出写到指定文件，在File标签下设置fileName即可。fileName可以是绝对路径的文件也可以是相对路径的文件

- name：指定Appender的名字
- fileName：指定输出日志的目的文件带全路径的文件名
- PatternLayout：输出格式，不设置默认为:%m%n

**3.RollingFileAppender**

RollingFileAppender跟FileAppender的基本用法一样。但RollingFileAppender可以设置log文件的size（单位：KB/MB/GB）上限、数量上限，当log文件超过设置的size上限，会自动被压缩。RollingFileAppender可以理解为滚动输出日志，如果log4j2记录的日志达到上限，旧的日志将被删除，腾出的空间用于记录新的日志

- name：指定Appender的名字
- fileName：指定输出日志的目的文件带全路径的文件名
- PatternLayout：输出格式，不设置默认为：%m%n
- filePattern：指定新建日志文件的名称格式
- Policies：指定滚动日志的策略，就是什么时候进行新建日志文件输出日志
- TimeBasedTriggeringPolicy：Policies子节点，基于时间的滚动策略，interval属性用来指定多久滚动一次，默认是1 hour。modulate=true用来调整时间：比如现在是早上3am，interval是4，那么第一次滚动是在4am，接着是8am，12am...而不是7am
- SizeBasedTriggeringPolicy：Policies子节点，基于指定文件大小的滚动策略，size属性用来定义每个日志文件的大小
- DefaultRolloverStrategy：用来指定同一个文件夹下最多有几个日志文件时开始删除最旧的，创建新的(通过max属性)。

**4.Filters**

Filter可以过滤log事件，并控制log输出，log4j2定义了10种 Filter：http://logging.apache.org/log4j/2.x/manual/filters.html

BurstFilter可以控制某一级别的log的并发情况：
```xml
<?xml version="1.0" encoding="UTF-8"?>
<Configuration status="warn" name="MyApp" packages="">
	<Appenders>
		<RollingFile name="RollingFile" fileName="logs/app.log"
				filePattern="logs/app-%d{MM-dd-yyyy}.log.gz">
			<BurstFilter level="INFO" rate="16" maxBurst="100"/>
			<PatternLayout pattern="%d{HH:mm:ss.SSS} [%t] %-5level %logger{36} - %msg%n"/>
			<Policies>
				<TimeBasedTriggeringPolicy />
				<SizeBasedTriggeringPolicy size="1 KB"/>
			</Policies>
			<DefaultRolloverStrategy max="10"/>
		</RollingFile>
	</Appenders>
	<Loggers>
		<Root level="trace">
			<AppenderRef ref="RollingFile"/>
		</Root>
	</Loggers>
</Configuration>
```
- level：BurstFilter过滤的事件级别
- rate：每秒允许的log事件的平均值
- maxBurst：当BurstFilter过滤的事件超过rate值，排队的log事件上限。超过此上限的log，将被丢弃。默认情况下maxBurst = 10*rate

按以上配置，假定每个log事件的执行时间较长，输出117个log事件（INFO级别）到RollingFileAppenders，BurstFilter会过滤得到INFO级别的log事件，之后会发生：16个log事件在执行，100个等待执行，1个被丢弃。

ThresholdFilter按日志级别区分文件输出：
```java
<Configuration status="WARN" monitorInterval="300">
	<properties>
		<property name="LOG_HOME">D:/logs</property>
	</properties>
	<Appenders>
		...
		<RollingRandomAccessFile name="InfoFile"
			fileName="${LOG_HOME}/info.log"
			filePattern="${LOG_HOME}/$${date:yyyy-MM}/info-%d{yyyy-MM-dd}-%i.log">
			<Filters>
				<ThresholdFilter level="warn" onMatch="DENY" onMismatch="NEUTRAL" />
				<ThresholdFilter level="trace" onMatch="ACCEPT" onMismatch="DENY" />
			</Filters>
			<PatternLayout pattern="%date{yyyy-MM-dd HH:mm:ss.SSS} %level [%thread][%file:%line] - %msg%n" />
			<Policies>
				<TimeBasedTriggeringPolicy />
				<SizeBasedTriggeringPolicy size="10 MB" />
			</Policies>
			<DefaultRolloverStrategy max="20" />
		</RollingRandomAccessFile>

		<RollingRandomAccessFile name="ErrorFile"
			fileName="${LOG_HOME}/error.log"
			filePattern="${LOG_HOME}/$${date:yyyy-MM}/error-%d{yyyy-MM-dd}-%i.log">
			<Filters>
				<ThresholdFilter level="warn" onMatch="ACCEPT" onMismatch="DENY" />
				<ThresholdFilter level="error" onMatch="ACCEPT" onMismatch="DENY" />
			</Filters>
			<PatternLayout pattern="%date{yyyy-MM-dd HH:mm:ss.SSS} %level [%thread][%file:%line] - %msg%n" />
			<Policies>
				<TimeBasedTriggeringPolicy />
				<SizeBasedTriggeringPolicy size="10 MB" />
			</Policies>
			<DefaultRolloverStrategy max="20" />
		</RollingRandomAccessFile>
		...
	</Appenders>
	<Loggers>
		<Root level="trace">
			<AppenderRef ref="Console" />
			<AppenderRef ref="FatalFile" />
			<AppenderRef ref="ErrorFile" />
		</Root>
	</Loggers>
</Configuration>
```

- DENY，日志将立即被抛弃不再经过其他过滤器
- NEUTRAL，有序列表里的下个过滤器过接着处理日志
- ACCEPT，日志会被立即处理，不再经过剩余过滤器

以上两个配置将info以下的日志写入info.log，warn和error写入error.log

### Loggers

Loggers节点，常见的有两种：Root和Logger。

**1.Root**

Root节点用来指定项目的根日志，如果没有单独指定Logger，那么就会默认使用该Root日志输出
 - Level：日志输出级别，共有8个级别，按照从低到高为：All < Trace < Debug < Info < Warn < Error < Fatal < OFF.
 - AppenderRef：Root的子节点，用来指定该日志输出到哪个Appender。

**2.Logger**

Logger节点用来单独指定日志的形式，比如要为指定包下的class指定不同的日志级别等。
- Level：日志输出级别，共有8个级别，按照从低到高为：All < Trace < Debug < Info < Warn < Error < Fatal < OFF.
- name：用来指定该Logger所适用的类或者类所在的包全路径，继承自Root节点.
- AppenderRef：Logger的子节点，用来指定该日志输出到哪个Appender,如果没有指定，就会默认继承自Root.如果指定了，那么会在指定的这个Appender和Root的Appender中都会输出，此时我们可以设置Logger的additivity="false"只在自定义的Appender中进行输出。

### 日志级别

共有8个级别，按照从低到高为：All < Trace < Debug < Info < Warn < Error < Fatal < OFF。

- All：最低等级的，用于打开所有日志记录
- Trace：是追踪，就是程序推进以下，你就可以写个trace输出，所以trace应该会特别多，不过没关系，我们可以设置最低日志级别不让他输出
- Debug：指出细粒度信息事件对调试应用程序是非常有帮助的
- Info：消息在粗粒度级别上突出强调应用程序的运行过程
- Warn：输出警告及warn以下级别的日志
- Error：输出错误信息日志
- Fatal：输出每个严重的错误事件将会导致应用程序的退出的日志
- OFF：最高等级的，用于关闭所有日志记录

程序会打印高于或等于所设置级别的日志，设置的日志等级越高，打印出来的日志就越少。

## 自定义读取配置文件

读取配置文件方式自定义：

```java
File file = new File("./conf/log4j2.xml");
BufferedInputStream in = null;
try {
	in = new BufferedInputStream(new FileInputStream(file));
} catch (FileNotFoundException e) {
	e.printStackTrace();
}
ConfigurationSource source = null;
try {
	source = new ConfigurationSource(in);
} catch (IOException e) {
	e.printStackTrace();
}
Configurator.initialize(null, source);
```

## 自定义输出格式

%d{HH:mm:ss.SSS} 表示输出到毫秒的时间
%t 输出当前线程名称
%-5level 输出日志级别，-5表示左对齐并且固定输出5个字符，如果不足在右边补0
%logger 输出logger名称，因为Root Logger没有名称，所以没有输出
%msg 日志文本
%n 换行

其他常用的占位符有：

%F 输出所在的类文件名，如Client.java
%L 输出行号
%M 输出所在方法名
%l 输出语句所在的行数, 包括类名、方法名、文件名、行数

## 自定义logger

初始化logger时，可以：

```java
Logger logger = LogManager.getLogger("mylog"); 
```

或者

```java
Logger logger = LogManager.getLogger(Logs.class.getName()); 
```

Logs为应用程序中的日志类名。

这样在配置文件中，即可以使用自定义的logger，控制自定义log的输出，与root区分开。

```xml
<Loggers>
	<Logger name="mylog" level="trace" additivity="false">
		<AppenderRef ref="Console" />
	</Logger>
	<Root level="error">
		<AppenderRef ref="Console" />
	</Root>
</Loggers>
```

## 自定义Appender

```xml
<Configuration status="WARN" monitorInterval="300">
	<Appenders>
		<Console name="Console" target="SYSTEM_OUT">
			<PatternLayout pattern="%d{HH:mm:ss.SSS} [%t] %-5level %logger{36} - %msg%n" />
		</Console>
		<File name="MyFile" fileName="./logs/app.log">
			<PatternLayout pattern="%d{HH:mm:ss.SSS} [%t] %-5level %logger{36} - %msg%n" />
		</File>
	</Appenders>
	<Loggers>
		<Logger name="mylog" level="trace" additivity="true">
			<AppenderRef ref="MyFile" />
		</Logger>
		<Root level="error">
			<AppenderRef ref="Console" />
		</Root>
	</Loggers>
</Configuration>
```

## 按大小和时间生成日志文件

```xml
<Configuration status="WARN" monitorInterval="300">
	<properties>
		<property name="LOG_HOME">D:/logs</property>
		<property name="FILE_NAME">mylog</property>
	</properties>
	<Appenders>
		<Console name="Console" target="SYSTEM_OUT">
			<PatternLayout pattern="%d{HH:mm:ss.SSS} [%t] %-5level %logger{36} - %msg%n" />
		</Console>
		<RollingRandomAccessFile name="myfile"
			fileName="${LOG_HOME}/${FILE_NAME}.log"
			filePattern="${LOG_HOME}/$${date:yyyy-MM}/${FILE_NAME}-%d{yyyy-MM-dd HH-mm}-%i.log">
			<PatternLayout
				pattern="%d{yyyy-MM-dd HH:mm:ss.SSS} [%t] %-5level %logger{36} - %msg%n" />
			<Policies>
				<TimeBasedTriggeringPolicy interval="1" />
				<SizeBasedTriggeringPolicy size="10 MB" />
			</Policies>
			<DefaultRolloverStrategy max="20" />
		</RollingRandomAccessFile>
	</Appenders>
	<Loggers>
		<Logger name="mylog" level="trace" additivity="false">
			<AppenderRef ref="myfile" />
		</Logger>
		<Root level="error">
			<AppenderRef ref="Console" />
		</Root>
	</Loggers>
</Configuration>
```
TimeBasedTriggeringPolicy这个配置需要和filePattern结合使用，注意filePattern中配置的文件重命名规则是${FILE_NAME}-%d{yyyy-MM-dd HH-mm}-%i，最小的时间粒度是mm，即分钟，TimeBasedTriggeringPolicy指定的size是1，结合起来就是每1分钟生成一个新文件。如果改成%d{yyyy-MM-dd HH}，最小粒度为小时，则每一个小时生成一个文件。

## 异步写文件

```java
...
<Appenders>
	<Console name="Console" target="SYSTEM_OUT">
	...
	</Console>
	<RollingRandomAccessFile name="MyFile"
	...
	</RollingRandomAccessFile>
	<Async name="Async">
		<AppenderRef ref="MyFile" />
	</Async>
</Appenders>
...
```

## 日志输出到flume

配置文件：
```xml
<Configuration status="WARN" monitorInterval="300">
	<Appenders>
		<Flume name="eventLogger" compress="false">
			<Agent host="127.0.0.1" port="41414" />
			<RFC5424Layout enterpriseNumber="18060" includeMDC="true" appName="MyApp" />
		</Flume>
	</Appenders>
	<Loggers>
		<Root level="trace">
			<AppenderRef ref="eventLogger" />
		</Root>
	</Loggers>
</Configuration>
```

flume上配置source类型为avro即可

```bash
...
agent1.sources.source.type=avro
agent1.sources.source.channels=channel
agent1.sources.source.bind=0.0.0.0
agent1.sources.source.port=41414
...
```

参考：
[详解log4j2(下) - Async/MongoDB/Flume Appender 按日志级别区分文件输出](http://blog.csdn.net/autfish/article/details/51244787)
