---
title: Centos升级gcc版本
date: 2017-11-16 16:46:15
tags: [GCC]
---

1. 下载源码包

<!-- more -->

```
wget http://ftp.gnu.org/gnu/gcc/gcc-4.8.0/gcc-4.8.0.tar.bz2
```
　　
解压

```
tar -jxvf  gcc-4.8.0.tar.bz2
```

2. 下载编译所需依赖库

```
cd gcc-4.8.0　
./contrib/download_prerequisites　
cd ..
```

3. 建立编译输出目录

```
mkdir gcc-build-4.8.0
```

4. 进入此目录，执行以下命令，生成makefile文件

```
cd  gcc-build-4.8.0
../gcc-4.8.0/configure --enable-checking=release --enable-languages=c,c++ --disable-multilib
```

5. 编译

```
make -j4
```
如果编译成功，则时间是比较长的，半个小时左右，所以如果你看它一直在输出没有立刻停下来，应该很开心！

6. 安装

```
sudo make install
```

7. 切换GCC到新版

确定新安装的GCC的路径,一般默认在/usr/local/bin下。可以先`updatedb`,然后`locate gcc-4.8|tail`找一下

```
ls /usr/local/bin | grep gcc
```

添加新GCC到可选项，倒数第三个是名字，倒数第二个参数为新GCC路径，最后一个参数40为优先级，设大一些之后就自动使用新版了

```
update-alternatives --install /usr/bin/gcc gcc /usr/local/bin/i686-pc-linux-gnu-gcc 40
```

8. 确认当前版本已经切换为新版

```
gcc -v
```

我这里用ssh远程的，发现版本没变，断开重练下，重新生成会话后发现变成了4.8了！
