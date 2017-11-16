---
layout: post
title: Crtmpserver编译部署
date: 2016-07-13 17:08:37
tags: [crtmpserver]
---

## 动态编译并安装到指定目录

### 动态编译

```
cd crtmpserver/builders/cmake
cmake . -DCMAKE_BUILD_TYPE=Release -DCRTMPSERVER_INSTALL_PREFIX=<install-dir>  (例如 /opt/crtmpserver)
make
make install
```
<!-- more -->

在 /opt/crtmpserver中可以看到整理好的文件,crtmpserver在sbin文件夹中,crtmpserver.lua在etc文件夹中

### 复制配置表

```
cp ./crtmpserver/crtmpserver.lua /opt/crtmpserver/etc
```

### 复制动态库

查看当前连接的动态库

```
ldd sbin/crtmpserver
```

进入安装目录并复制额外的库

```
cd /opt/crtmpserver
cp /lib64/libssl.so.0.9.8e ./lib
cp /lib64/libcrypto.so.0.9.8e ./lib
cp /lib64/libdl-2.5.so ./lib
```

### 打包

```
cd /opt
tar -czvf crtmpserver.tar.gz ./crtmpserver
```

### 安装到新的机器上

解压

```
cd /opt
tar -zxvf crtmpserver.tar.gz
cd crtmpserver
```

复制动态库到系统目录

```
cp ./lib/crtmpserver/lib*.so /lib64
```

复制运行程序到库目录

```
cp ./sbin/crtmpserver lib/crtmpserver/
```

启动程序

```
cd lib/crtmpserver
./crtmpserver --use-implicit-console-appender  ../../etc/crtmpserver.lua
```

## 静态编译DEBUG版

在CMakeList.txt开始位置加入下面一句即可

```
SET(ENV{COMPILE_STATIC} "1")
```

编译的时调整参数为Debug

```
cmake . -DCMAKE_BUILD_TYPE=Debug -DCRTMPSERVER_INSTALL_PREFIX=<install-dir>  (例如 /opt/crtmpserver)
```

参考：http://blog.csdn.net/fireroll/article/details/20546299
