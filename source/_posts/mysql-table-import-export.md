---
title: Mysql单表大数据导出导入
date: 2017-11-30 17:21:57
tags: [MYSQL]
---

## 命令使用

<!-- more -->

```
SELECT * INTO OUTFILE '/var/lib/mysql-files/data.txt' FIELDS TERMINATED BY ',' FROMOLD_TABLE;
LOAD DATA INFILE '/var/lib/mysql-files/data.txt' INTO TABLE NEW_TABLE;
```

## 问题

一般使用时会遇到一下问题

```
The MySQL server is running with the --secure-file-priv option so it cannot execute this statement
```

## 报错原因
secure_file_priv 设置了指定目录，需要在指定的目录下进行数据导出
```
mysql> show variables like '%secure%';
+--------------------------+-----------------------+
| Variable_name            | Value                |
+--------------------------+-----------------------+
| require_secure_transport | OFF                  |
| secure_auth              | ON                    |
| secure_file_priv        | /var/lib/mysql-files/ |
+--------------------------+-----------------------+
3 rows in set (0.00 sec)
```
这个参数用来限制数据导入和导出操作的效果，例如执行LOAD DATA、SELECT … INTO OUTFILE语句和LOAD_FILE()函数。这些操作需要用户具有FILE权限。 如果这个参数为空，这个变量没有效果； 如果这个参数设为一个目录名，MySQL服务只允许在这个目录中执行文件的导入和导出操作。这个目录必须存在，MySQL服务不会创建它； 如果这个参数为NULL，MySQL服务会禁止导入和导出操作。这个参数在MySQL 5.7.6版本引入。
