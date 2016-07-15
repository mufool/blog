---
layout: post
title: WOWZA流媒体直播配置
tags: [WOWZA]
---

## 本文目的

1. 安装和使用wowza流媒体服务器
2. 使用ffmpeg向wowza推直播ts流并播放

## wowza流媒体服务器简介

WowzaStreaming Engine 4 (也就是著名的WowzaMedia Server®)是一个高性能、可扩展的流媒体服务器软件，支持直播、VOD、在线视频聊天、远程录制功能， 它也支持多种播放器技术，包括：

* Adobe® HTTP Dynamic Streaming (HDS). AdobeFlash® 播放器
* Apple® HTTP Live Streaming (HLS). iPhone®,iPad®, iPod touch®, Safari® 浏览器,QuickTime® 播放器
* Microsoft® Smooth Streaming. MicrosoftSilverlight®
* MPEG-DASH streaming. DASH clients
* Real Time Streaming Protocol (RTSP/RTP).QuickTime 播放器,VLC 媒体播放器,以及许多移动终端
* MPEG-2 Transport Streams (MPEG-TS). 机顶盒和IPTV解决方案
<!-- more -->

## wowza下载安装
* 下载

	[官网下载页面](http://www.wowza.com/pricing/installer)：可以选择你自己需要的平台版本进行下载

	[百度云地址](http://pan.baidu.com/s/1c0hfgOC)：linux版本，本文配置已linux为例

* 获取许可密钥

	在官网注册一个账户，Wowza就会给你发一个使用密钥，我这里获得的密钥有效期为半年。

* 安装 

	```bash
	sudo chmod +x WowzaStreamingEngine-4.0.3.rpm.bin 
	sudo ./WowzaStreamingEngine-4.1.2.tar.bin
	```

	其中安装过程根据控制台打印的提示，问你是否同意license条款：yes，提示输入Wowza Streaming Engine Manager管理员用户名和密码。这个用户名和密码是用来登陆管理页面时需要，如丢失只能在安装目录的conf目录下相关文件中找回，接下来会要求输入license key，输入后开始安装，默认安装在/usr/local下。

* 使用

	wowza 4 引入了友好的可视化服务管理，用户不需要去面对各种 conf 也能通过网页对 wowza 服务进行管理、配置了，甚至还可以轻松地对 wowza 的服务的各个应用的状态进行实时监控。刚装完时，无法通过http://192.168.200.81:8088/enginemanager登陆到管理页面上去，这个时候需要重启一下服务：

	```bash
	/etc/init.d/WowzaStreamingEngine start
	/etc/init.d/WowzaStreamingEngineManager start
	```

	通过http://192.168.200.81::8088/enginemanager登陆管理页面
	<img src="http://7j1zu0.com1.z0.glb.clouddn.com/wowzalogin.jpg" alt="">

## wowza直播源设置步骤

1. 登陆Wowza管理页面
2. applications下默认有live和vod两个应用，也可以自己根据需要在重新添加一个应用，这里我们选择live
	<img src="http://7j1zu0.com1.z0.glb.clouddn.com/wowzapic1.jpg" alt="">
3. 选着左侧Stream Files，然后再Add Stream File,即可创建流
	<img src="http://7j1zu0.com1.z0.glb.clouddn.com/wowzapic2.jpg" alt="">
4. 添加流名称和地址，名称任意，流地址为服务器地址和想使用的端口组合
	<img src="http://7j1zu0.com1.z0.glb.clouddn.com/wowzapic3.jpg" alt="">
5. 进入Server->Stream Files点击流名称的箭头连接按钮
	<img src="http://7j1zu0.com1.z0.glb.clouddn.com/wowzapic4.jpg" alt="">
	这里可以注意一下，左边有个Startup Streams,这里是当前启动的流，创建的流需要启动，否则无法使用。启动流点击流名称的加号按钮即可，启动后会看到服务器已经监听响应端口。
6. 添加Application Name和MediaCasterType，这里推的是rtsp的ts流
	<img src="http://7j1zu0.com1.z0.glb.clouddn.com/wowzapic5.jpg" alt="">
7. 再次回到Applictions->Stream Files进入创建的stream，右上角Test Players即可观看到推流结果
	<img src="http://7j1zu0.com1.z0.glb.clouddn.com/wowzapic6.jpg" alt="">

## ffmpeg推流

使用ffmpeg推rtsp的ts流到服务器，地址即为之前创建的流的ip和端口，命令如下：

```bash
ffmpeg -re -i "panda.mp4" -acodec copy -vcodec copy -vbsf h264_mp4toannexb -f mpegts udp://192.168.200.81:5004?pkt_size=1316
```
