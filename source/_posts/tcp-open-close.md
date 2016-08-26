---
layout: post
title: TCP开始结束及状态转换
tags: [TCP]
---

## TCP的状态图

<img src="http://mufool.qiniudn.com/tcp/tcpfsm.png" alt=""><img src="http://mufool.qiniudn.com/tcp/tcpopenclose.jpg" alt="">
[图片地址](http://www.tcpipguide.com/free/t_TCPOperationalOverviewandtheTCPFiniteStateMachineF-2.htm)

<!-- more -->

## 建立连接协议（三次握手）

* 客户端发送一个带SYN标志的TCP报文到服务器。
* 服务器端回应客户端的，这个报文同时带ACK标志和SYN标志，它表示对刚才客户端SYN报文的回应；同时又标志SYN给客户端，询问客户端是否准备好进行数据通讯。
* 客户必须再次回应服务段一个ACK报文。

## 连接终止协议（四次握手）

为什么是四次：由于TCP连接是全双工的，因此每个方向都必须单独进行关闭。当一方完成它的数据发送任务后就能发送一个FIN来终止这个方向的连接。收到一个FIN只意味着这一方向上没有数据流动，一个TCP连接在收到一个FIN后仍能发送数据。首先进行关闭的一方将执行主动关闭，而另一方执行被动关闭。

* TCP客户端发送一个FIN，用来关闭客户到服务器的数据传送。
* 服务器收到这个FIN，它发回一个ACK，确认序号为收到的序号加1。和SYN一样，一个FIN将占用一个序号。
* 服务器关闭客户端的连接，发送一个FIN给客户端。
* 客户段发回ACK报文确认，并将确认序号设置为收到序号加1。

## 服务端（被动方）状态转换

CLOSED->LISTEN->SYN_RECV->ESTABLISHED->CLOSE_WAIT->LAST_ACK->CLOSED

## 客户端（主动方）状态转换

CLOSED->SYN_SENT->ESTABLISHED->FIN_WAIT_1->FIN_WAIT_2->TIME_WAIT->CLOSED

## 状态解释

CLOSED：表示初始状态。

LISTEN：表示服务器端的某个SOCKET处于监听状态，可以接受连接。

SYN_RCVD：表示接受到了SYN报文，在正常情况下，这个状态是服务器端的SOCKET在建立TCP连接时的三次握手会话过程中的一个中间状态，很短暂，基本上用netstat你是很难看到这种状态的，除非你特意写了一个客户端测试程序，故意将三次TCP握手过程中最后一个ACK报文不予发送。

SYN_SENT：这个状态与SYN_RCVD遥想呼应，当客户端SOCKET执行CONNECT连接时，它首先发送SYN报文，因此也随即它会进入到了SYN_SENT状态，并等待服务端的发送三次握手中的第2个报文。SYN_SENT状态表示客户端已发送SYN报文。

ESTABLISHED：表示连接已经建立。

FIN_WAIT_1：FIN_WAIT_1和FIN_WAIT_2状态的真正含义都是表示等待对方的FIN报文。而这两种状态的区别是：FIN_WAIT_1状态实际上是当SOCKET在ESTABLISHED状态时，它想主动关闭连接，向对方发送了FIN报文，此时该SOCKET即进入到FIN_WAIT_1状态。而当对方回应ACK报文后，则进入到FIN_WAIT_2状态，在实际的正常情况下，无论对方何种情况下，都应该马上回应ACK报文，所以FIN_WAIT_1状态一般是比较难见到的，而FIN_WAIT_2状态还有时常常可以用netstat看到。

FIN_WAIT_2：实际上FIN_WAIT_2状态下的SOCKET，表示半连接，即客户端已经关闭连接，但服务端暂时还有点数据需要传送给你，稍后再关闭连接。

TIME_WAIT：表示收到了对方的FIN报文，并发送出了ACK报文，就等2MSL后即可回到CLOSED可用状态了。如果FIN_WAIT_1状态下，收到了对方同时带FIN标志和ACK标志的报文时，可以直接进入到TIME_WAIT状态，而无须经过FIN_WAIT_2状态。

CLOSING：这种状态比较特殊，实际情况中应该是很少见，属于一种比较罕见的例外状态。正常情况下，当你发送FIN报文后，按理来说是应该先收到（或同时收到）对方的ACK报文，再收到对方的FIN报文。但是CLOSING状态表示你发送FIN报文后，并没有收到对方的ACK报文，反而却也收到了对方的FIN报文。什么情况下会出现此种情况呢？其实细想一下，也不难得出结论：那就是如果双方几乎在同时close一个SOCKET的话，那么就出现了双方同时发送FIN报文的情况，也即会出现CLOSING状态，表示双方都正在关闭SOCKET连接。

CLOSE_WAIT：表示在等待关闭。怎么理解呢？当对方close一个SOCKET后发送FIN报文给自己，系统毫无疑问地会回应一个ACK报文给对方，此时则进入到CLOSE_WAIT状态。接下来呢，实际上你真正需要考虑的事情是察看你是否还有数据发送给对方，如果没有的话，那么你也就可以close这个SOCKET，发送FIN报文给对方，也即关闭连接。所以你在CLOSE_WAIT状态下，需要完成的事情是等待你去关闭连接。

LAST_ACK: 这个状态还是比较容易好理解的，它是被动关闭一方在发送FIN报文后，最后等待对方的ACK报文。当收到ACK报文后，即可以进入到CLOSED可用状态了。
