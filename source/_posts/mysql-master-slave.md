---
layout: post
title: MYSQL安装及主从配置
date: 2017-06-09 14:35:18
tags: [MYSQL]
---

## yum安装mysql

* 安装mysql5.6的yum源

<!-- more -->

a. 直接从网上安装mysql的yum源

```
[user]$ sudo rpm -ivh
http://repo.mysql.com/mysql-community-release-el6-5.noarch.rpm
```

b. 从本地安装mysql的yum源
将mysql-community-release-el6-5.noarch.rpm上传至目标机器

```
[user]$ scp mysql-community-release-el6-5.noarch.rpm user@target:~
[user]$ cd
[user]$ sudo yum localinstall mysql-community-release-el6-5.noarch.rpm
```

* 更新源信息

```
[user]$ sudo yum makecache
```

*  列出当前yum的可用源列表

```
[user]$ sudo yum repolist
mysql-connectors-community      MySQL Connectors Community      9
mysql-tools-community           MySQL Tools Community           12
mysql56-community               MySQL 5.6 Community Server      78
```

* 查看mysql5.6可用安装包

```
[user]$ sudo yum search mysql-community

================================= N/S Matched: mysql-community =================================
mysql-community-bench.x86_64 : MySQL benchmark suite
mysql-community-client.x86_64 : MySQL database client applications and tools
mysql-community-client.i686 : MySQL database client applications and tools
mysql-community-common.i686 : MySQL database common files for server and client libs
mysql-community-common.x86_64 : MySQL database common files for server and client libs
mysql-community-devel.i686 : Development header files and libraries for MySQL database client applications
mysql-community-devel.x86_64 : Development header files and libraries for MySQL database client applications
mysql-community-embedded.i686 : MySQL embedded library
mysql-community-embedded.x86_64 : MySQL embedded library
mysql-community-embedded-devel.i686 : Development header files and libraries for MySQL as an embeddable library
mysql-community-embedded-devel.x86_64 : Development header files and libraries for MySQL as an embeddable library
mysql-community-libs.i686 : Shared libraries for MySQL database client applications
mysql-community-libs.x86_64 : Shared libraries for MySQL database client applications
mysql-community-libs-compat.i686 : Shared compat libraries for MySQL 5.1 database client applications
mysql-community-libs-compat.x86_64 : Shared compat libraries for MySQL 5.1 database client applications
mysql-community-release.noarch : MySQL repository configuration for yum
mysql-community-server.x86_64 : A very fast and reliable SQL database server
mysql-community-test.x86_64 : Test suite for the MySQL database server
```

* 安装mysql5.6

```
[user]$ sudo yum install -y mysql-community-client mysql-community-common mysql-community-devel mysql-community-libs mysql-community-libs-compat mysql-community-release mysql-community-server mysql-community-test
```

* 启动mysqld

```
[user]$ sudo /sbin/service mysqld start
```

* 查看mysql版本

```
[user]$ mysql -u root
mysql> select version();
+-----------+
| version() |
+-----------+
| 5.6.20    |
+-----------+
1 row in set (0.00 sec)
```

## 配置MySQL主
添加一个权限，并创建测试数据库testdb

```
grant all on *.*  to bfsportsdt@'192.168.193.226' identified by '85iwx|qttHsrlxPeyldb';
create database testdb;
```

配置主的my.cnf配置文件

```
log_bin=mysql-bin  #启动MySQ二进制日志系统
binlog-do-db=testdb   #需要同步的数据库名，如果有多个数据库，可重复此参数，每个数据库一行  
binlog-ignore-db=mysql    #不同步mysql系统数据库  
server_id = 1   #设置服务器id，为1表示主服务器
```

重启并查看状态

```
/sbin/service mysqld restart
```

```
mysql> show master status;
+------------------+----------+--------------+------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB |
+------------------+----------+--------------+------------------+
| mysql-bin.000002 |     1394 | sports,nlp   |                  |
+------------------+----------+--------------+------------------+
1 row in set (0.00 sec)
```

## 配置MySQL从

导入主上的数据库testdb

配置my.cnf

```
log_bin=mysql-bin   #启动MySQ二进制日志系统，注意：如果原来的配置文件中已经有这一行，就不用再添加了。  
replicate-do-db=testdb  
replicate-ignore-db=mysql  
read_only=1  
server_id = 2    #配置文件中已经有一行server-id=1，修改其值为2，表示为从数据库  
```

重启MySQL,并执行以下操作

```
stop slave;
change master to  master_host='192.168.193.226',master_user='bfsportsdt',master_password='85iwx|qttHsrlxPeyldb',master_log_file='mysql-bin.000002',master_log_pos=871;
start slave;
```

```
mysql> SHOW SLAVE STATUS\G 
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 192.168.193.226
                  Master_User: bfsportsdt
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: mysql-bin.000002
          Read_Master_Log_Pos: 6383
               Relay_Log_File: mysqld-relay-bin.000002
                Relay_Log_Pos: 4892
        Relay_Master_Log_File: mysql-bin.000002
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
              Replicate_Do_DB:testdb
          Replicate_Ignore_DB: 
           Replicate_Do_Table: 
       Replicate_Ignore_Table: 
      Replicate_Wild_Do_Table: 
  Replicate_Wild_Ignore_Table: 
                   Last_Errno: 0
                   Last_Error: 
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 5512
              Relay_Log_Space: 5919
              Until_Condition: None
               Until_Log_File: 
                Until_Log_Pos: 0
           Master_SSL_Allowed: No
           Master_SSL_CA_File: 
           Master_SSL_CA_Path: 
              Master_SSL_Cert: 
            Master_SSL_Cipher: 
               Master_SSL_Key: 
        Seconds_Behind_Master: 1
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error: 
               Last_SQL_Errno: 0
               Last_SQL_Error: 
1 row in set (0.00 sec)
```

注意查看：
Slave_IO_Running: Yes
Slave_SQL_Running: Yes
以上这两个参数的值为Yes，即说明配置成功！
