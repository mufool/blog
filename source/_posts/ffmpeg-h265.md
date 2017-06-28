---
layout: post
title: 编译支持h265的ffmpeg
date: 2016-09-20 15:01:31
tags: [FFMPEG]
---

## 准备

cmake要升级要2.8.8 yasm要升级到1.2.0

<!-- more -->

## 安装x264

{% codeblock %}
git clone git://git.videolan.org/x264.git
cd x264
./configure --enable-static --disable-opencl --disable-avs
--disable-cli --disable-ffms --disable-gpac --disable-lavf
--disable-swscale
make
sudo make install
sudo ldconfig
{% endcodeblock %}

## 安装x265

```bash
	hg clone https://bitbucket.org/multicoreware/x265
	hg checkout 0.8
	cd x265/build/linux
	./make-Makefiles.bash
	# 这里将 LOG_CU_STATISTICS　设置为ON，然后，按下“c”，实现configure，按下“q”退出
	make
	sudo make install
	sudo ldconfig
```

## 编译ffmpeg

```
./configure --enable-gpl --enable-libx264 --enable-libx265 --disable-stripping --disable-optimizations --extra-cflags=-g --enable-libfaac --enable-nonfree --enable-libspeex --extra-cflags=-I/usr/local/include --extra-ldflags=-L/usr/local/lib
make
```

出错：
<img src="http://mufool.qiniudn.com/ffmpeg/h265-1.png" alt="">

查看config.log

```
In file included from /tmp/ffconf.gFGcukGK.c:1:
/usr/local/include/x264.h:40:4: warning: #warning You must include stdint.h or inttypes.h before x264.h
check_pkg_config x265 x265.h x265_encoder_encode
pkg-config --exists --print-errors x265
Package x265 was not found in the pkg-config search path.
Perhaps you should add the directory containing `x265.pc'
to the PKG_CONFIG_PATH environment variable
No package 'x265' found
ERROR: x265 not found
```

提示找不到x265的链接库文件x265.pc, 将编译目录下的x265.pc拷贝到/usr/local/lib下：

```
cp x265.pc /usr/local/lib
```

然后修改/etc/profile中的环境变量PKG_CONFIG_PATH:

```
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/lib/
```

查看是否已包含h265

```
pkg-config --list-all | greo x265
```

重新编译ffmpeg，还是出错：
<img src="http://mufool.qiniudn.com/ffmpeg/h265-2.png" alt="">

```
#ls  /usr/local/lib | grep libx264
libx264.a
libx264.so
libx264.so.146 
```

可能原先我做过编译，在/usr/local目录下面安装了x264，可能有冲突，把x264在/usr/local目录下的一些相关文件卸载掉，重新编译x264，再编译ffmpeg

运行ffmpeg，已包含x265
<img src="http://mufool.qiniudn.com/ffmpeg/h265-3.png" alt="">

 
接下来转码一个h.265视频到h.264看看效果。
ffmpeg -i h265.mkv -c:v libx264 -preset medium -c:a aac -strict experimental -f mp4 -b:a 128k outputh264.mp4

参考：
[Linux编译FFmpeg，支持x264和x265(HEVC)](http://scateu.me/2014/03/06/compile-ffmpeg-on-linux-with-x264-and-x265-support.html)
