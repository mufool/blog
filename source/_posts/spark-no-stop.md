---
title: Spark或Hadoop集群无法停止
date: 2017-07-06 19:06:25
tags: [SPARK]
---
## 现象

执行`sbin/stop-all.sh`，提示：

```powershell
Stopping namenodes on [master]
master: no namenode to stop
slave1: no datanode to stop
Stopping secondary namenodes [master]
master: no secondarynamenode to stop
```

<!-- more -->

jps显示进程都在：

```powershell
25280 Jps
4290 Master
21235 SecondaryNameNode
21395 ResourceManager
15687 Master
21052 NameNode
```

## 原因分析

以Spark为例，Spark启动停止都是通过`hadoop-daemon.sh`文件，其中部分代码如下：

```powershell
...
# some variables
log="$SPARK_LOG_DIR/spark-$SPARK_IDENT_STRING-$command-$instance-$HOSTNAME.out"
pid="$SPARK_PID_DIR/spark-$SPARK_IDENT_STRING-$command-$instance.pid"

# Set default scheduling priority
if [ "$SPARK_NICENESS" = "" ]; then
	export SPARK_NICENESS=0
fi

execute_command() {
	if [ -z ${SPARK_NO_DAEMONIZE+set} ]; then
		nohup -- "$@" >> $log 2>&1 < /dev/null &
		newpid="$!"

		echo "$newpid" > "$pid"

		# Poll for up to 5 seconds for the java process to start
		for i in {1..10}
		do
			if [[ $(ps -p "$newpid" -o comm=) =~ "java" ]]; then
				break
			fi
			sleep 0.5
		done

		sleep 2
		# Check if the process has died; in that case we'll tail the log so the user can see
		if [[ ! $(ps -p "$newpid" -o comm=) =~ "java" ]]; then
			echo "failed to launch: $@"
			tail -2 "$log" | sed 's/^/	/'
			echo "full log in $log"
		fi
	else
		"$@"
	fi
}

run_command() {
	mode="$1"
	shift

	mkdir -p "$SPARK_PID_DIR"

	if [ -f "$pid" ]; then
	TARGET_ID="$(cat "$pid")"
		if [[ $(ps -p "$TARGET_ID" -o comm=) =~ "java" ]]; then
			echo "$command running as process $TARGET_ID.  Stop it first."
			exit 1
		fi
	fi

	if [ "$SPARK_MASTER" != "" ]; then
		echo rsync from "$SPARK_MASTER"
		rsync -a -e ssh --delete --exclude=.svn --exclude='logs/*' --exclude='contrib/hod/logs/*' "$SPARK_MASTER/" "${SPARK_HOME}"
  fi

	spark_rotate_log "$log"
	echo "starting $command, logging to $log"

  case "$mode" in
	(class)
		execute_command nice -n "$SPARK_NICENESS" "${SPARK_HOME}"/bin/spark-class "$command" "$@"
		;;

	(submit)
		execute_command nice -n "$SPARK_NICENESS" bash "${SPARK_HOME}"/bin/spark-submit --class "$command" "$@"
		;;

	(*)
		echo "unknown mode: $mode"
		exit 1
		;;
	esac
}

case $option in

	(submit)

	run_command submit "$@"
	;;

	(start)

	run_command class "$@"
	;;

	(stop)

	if [ -f $pid ]; then
		TARGET_ID="$(cat "$pid")"
		if [[ $(ps -p "$TARGET_ID" -o comm=) =~ "java" ]]; then
			echo "stopping $command"
			kill "$TARGET_ID" && rm -f "$pid"
		else
			echo "no $command to stop"
		fi
	else
		echo "no $command to stop"
	fi
	;;

	(status)

	if [ -f $pid ]; then
		TARGET_ID="$(cat "$pid")"
		if [[ $(ps -p "$TARGET_ID" -o comm=) =~ "java" ]]; then
			echo $command is running.
			exit 0
		else
			echo $pid file is present but $command not running
			exit 1
		fi
	else
		echo $command not running.
		exit 2
	fi
	;;

	(*)
	echo $usage
	exit 1
	;;
esac
```
可以看到，启动是会生成pid文件，停止时会读取pid文件，并` kill "$TARGET_ID" && rm -f "$pid"`，在pid文件在不定义是，默认存放目录值tmp，linux系统默认每30天清理一次/tmp目录下的文件。pid文件丢失将导致无法正确关闭相应进程。

## 解决方法

pid文件的默认文件名格式如下：

```powershell
pid="$SPARK_PID_DIR/spark-$SPARK_IDENT_STRING-$command-$instance.pid"
```

通过代码可以知道，

```powershell
$SPARK_PID_DIR = /tmp
$SPARK_IDENT_STRING = hdfs #username
$command = org.apache.spark.deploy.master.Master # or worker
$instance = 1
```
所以，我们只需要找到对应进程的进程号，创建文件并添加就可以正常关闭进程

## 根治方法

既然tmp目录会被系统定时清理，那么我们重新设置对应服务的pid存放路径即可

修改hadoop-env.sh，增加：

```bash
export HADOOP_PID_DIR=/opt/hadoop/appid/
```

修改spark-env.sh，增加：

```bash
export SPARK_PID_DIR=/opt/hadoop/appid/
```

重启对应服务：

```powershell
-rw-rw-r-- 1 hdfs hdfs 6 Jul  6 15:54 hadoop-hdfs-datanode.pid
-rw-rw-r-- 1 hdfs hdfs 6 Jul  6 15:54 hadoop-hdfs-journalnode.pid
-rw-rw-r-- 1 hdfs hdfs 6 Jul  6 15:44 spark-hdfs-org.apache.spark.deploy.worker.Worker-1.pid
-rw-rw-r-- 1 hdfs hdfs 6 Jul  6 15:54 yarn-hdfs-nodemanager.pid
```

通过这个问题我们可以知道，很对linux下对应的服务都有类似的控制脚本，或者可以添加类似的控制脚本，但是在存放pid文件是我们也应该主要到这个问题。防止因为系统原因，导致服务无法正常重启等问题。
