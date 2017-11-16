---
title: Linux压缩命令对比
date: 2017-09-22 16:18:43
tags: [ZIP]
---
## .zip格式的压缩和解压缩

<!-- more -->

* zip 压缩文件名源文件
含义：这条命令压缩的是文件。

* zip -r 压缩文件名源目录
含义：这条命令压缩的是目录，包括目录下的文件一并压缩进去。

* unzip 压缩文件名
含义：解压缩，不管是压缩的文件还是压缩的目录都用此来解压缩

注意：Linux下的.zip和windows下的.zip格式是一样的，也就是说windows下的.zip压缩包可以直接拿到


## .gz格式的压缩和解压缩

* gzip 源文件
含义：将源文件压缩为.gz格式，但是源文件会消失。

* gzip -c 源文件 > 压缩文件
含义：将源文件压缩为.gz格式，但是源文件会保留。其实原理是将压缩的.gz输入到“压缩文件”而已。

* gzip -r 目录
含义：压缩目录下的所有子文件，但是注意不能压缩目录。

* gunzip 压缩文件
含义：解压缩。原有的.ga压缩文件会消失的。

* gzip -d 压缩文件
含义：解压缩。同上。

* gunzip -r 目录
含义：将目录下所有的.gz格式的文件解压缩。

注意：windows下的.rar格式压缩文件不能在Linux下使用。.gz格式是Linux下独有的压缩格式，但是也可以在windows下被解压缩。

## .bz2格式的压缩与解压缩

* bzip2 源文件
含义：压缩源文件为.bz2格式，不保留源文件。

* bzip2 -k 源文件
含义：压缩源文件，但是保留源文件。

注意：.bz2不支持压缩目录。

* bzip2 -d 压缩文件
含义：解压缩。如果加选项“-k”，则保留压缩文件

* bunzip2 压缩文件
含义：解压缩。如果加选项“-k”，则保留压缩文件

## .tar.gz和tar.bz2格式的压缩和解压缩

为了解决.gz格式不能压缩目录，所以Linux给出了.tar.gz的压缩格式。它的原理其实就是先将目录（也可以将文件）打包成一个.tar格式的单一文件包，然后再使用.gz的压缩方式对其压缩。那么我们就按照它的实现原理来讲几个命令：

### 打包成.tar.gz格式。

先将文件或者目录打包成.tart格式，使用如下命令：
```
tar -cvf 打包文件名源文件
```
选项：

* -c 打包的意思
* -v 显示过程
* -f 指定打包后的文件名

比如我们打包出了文件”cangls.tar”，然后再将其打包成.tar.gz。直接使用.gz格式的命令即可。如下：
```
gzip cangls.tar
```
这样子最终就打包成了cangls.tar.ga格式的压缩包了。

### 解压缩

下面我们可以一步步的将.tar.gz解压缩。首先使用.gz的命令解压成.tar格式，如下：
```
gunzip cangls.tar.gz
```
这样子就会被解压成cangls.tar。然后再使用.tar的解压方法，如下：
```
tar -xvf cangls.tar
```
这样子就最终解压成了cangls。

上面说的是其实现原理，你可以这样子一步步来压缩。也可以一步将文件或者目录打包成.tar.gz格式：
```
tar -zcvf 压缩包名源文件
```
选项：

* -z 就是直接打包成.tar.gz格式的意思

一句话将.tar.gz格式解压缩：
```
tar -zxvf 压缩包名
```
而关于.tar.bz2的实现原理跟上面是一样的，这里就不再多说。

下面做一下总结，其实.tar.gz和.tar.bz2是linux下最常用的命令。对于初学者，只需要记住一下几个命令即可：

一般记住下面的命令即可：

* tar -zcvf 压缩包名源文件或者目录
含义：将源文件或者目录打包成.tar.gz格式。

* tar -zxvf 压缩包名
含义：将.tar.gz格式的包解压。

* tar -jcvf 压缩包名源文件或者目录名
含义：将源文件或者目录压缩成.tar.bz2格式的包。

* tar -jxvf 压缩包名
含义：将.tar.bz2格式解压缩

上面的命令都是压缩到或者解压到当前目录下，如果想压缩到或者解压到其他目录下呢？

用下面的两个示例来说明一下方法吧：
* tar -zxvf cangls.tar.gz -c /tmp/
含义：将cangls.tar.gz解压到tmp目录下。也就是说，后面跟上“-c 目录名”，就是要解压到的地方。

* tar -zcvf /tmp/cangls.tar.gz cangls
含义：将cangls压缩到/tmp目录下，并且命名为cangls.tar.gz。也就是压缩到哪里，在前面直接加上目录即可。

## 各个压缩命令比较

已一个163M的node目录为例进行压缩比较

* tar -cvf node.tar node
压缩完后148M
* zip -r node.zip node
压缩完后44M
* tar -zcvf node.tgz node
压缩完后34M
* tar -jcvf node.tar.bz node
压缩完后28M
* tar -jcvf node.tar.bz2 node
压缩完后28M，只是bz2的压缩速度更快

综合起来，在压缩比率上： tar.bz=tar.bz2>tgz>zip>tar
耗费时间（打包，解压）
打包：tar.bz>tar.bz2>tgz>zip>tar
解压： tar.bz>tar.bz2>zip>tar>tgz
从效率角度来说，当然是耗费时间越短越好，可以根据需要选择不同的压缩工具，物理空间和时间上不能两全。
