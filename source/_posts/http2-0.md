---
title: HTTP/2.0入门
date: 2017-11-30 17:56:33
tags: [HTTP]
---
## HTTP协议

HTTP协议（HyperTextTransferProtocol，超文本传输协议）是用于从WWW服务器传输超文本到本地浏览器的传输协议。

<!-- more -->

## HTTP发展史

![imag](http://pic-blog.bfvyun.com/http2.0/http21.jpg)

## HTTP/2.0主要特点

这是 Akamai 公司建立的一个官方的演示[HTTP/2 is the future of the Web, and it is here!](https://http2.akamai.com/demo)，用以说明 HTTP/2 相比于之前的 HTTP/1.1 在性能上的大幅度提升。 同时请求 379 张图片，从Load time 的对比可以看出 HTTP/2 在速度上的优势。

![imag](http://pic-blog.bfvyun.com/http2.0/http22.jpg)

HTTP/2 源自 SPDY/2，SPDY 系列协议由谷歌开发，于 2009 年公开。它的设计目标是降低 50% 的页面加载时间。当下很多著名的互联网公司都在自己的网站或 APP 中采用了 SPDY 系列协议（当前最新版本是SPDY/3.1），因为它对性能的提升是显而易见的。主流的浏览器（谷歌、火狐、Opera）也都早已经支持 SPDY，它已经成为了工业标准，HTTP Working-Group 最终决定以 SPDY/2 为基础，开发 HTTP/2。HTTP/2标准于2015年5月以RFC 7540正式发表。
但是，HTTP/2 跟 SPDY 仍有不同的地方，主要是以下两点：
* HTTP/2 支持明文 HTTP 传输，而 SPDY 强制使用 HTTPS
* HTTP/2 消息头的压缩算法采用 HPACK ，而非 SPDY 采用的 DEFLATE

HTTP2.0 的出现，相比于 HTTP1.x ，大幅度的提升了 web 性能。其中主要特点如下。

### 多路复用（Multiplexing）

![imag](http://pic-blog.bfvyun.com/http2.0/http23.jpg)

对于 HTTP1.1，浏览器通常最多有链接的限制，即使开启多个链接，每个连接都需要消耗服务器资源，同时HTTP是基于TCP的，每个连接需要有慢启动的过程，无法充分利用带宽资源。
HTTP2.0的多路复用允许单一的 HTTP/2 连接同时发起多重的请求-响应消息。让所有数据流共用同一个连接，可以更有效地使用 TCP 连接，让高带宽也能真正的服务于 HTTP 的性能提升。
HTTP2.0具体是如何实现单连接中发送多个请求呢？
HTTP基于TCP，TCP是双向流传输，一个是从client到server，一个是从server到客户端。单个流中传输的数据是有序的，主要发送有序，接受就可以接受到。比如：发送 hello http两个单词，接受端收到的也分别是hello和http。如果是将hello http混着这发出去，hehllottp，则服务器就没法讲两个单词分开。要实现这个效果，HTTP2.0中引入了二进制分帧这个新概念。

### 二进制分帧

![imag](http://pic-blog.bfvyun.com/http2.0/http24.jpg)
在应用层与传输层之间增加一个二进制分帧层，以此达到“在不改动 HTTP 的语义，HTTP 方法、状态码、URI 及首部字段的情况下，突破 HTTP1.1 的性能限制，改进传输性能，实现低延迟和高吞吐量。”

HTTP/2 的三个概念：
* 数据流：已建立的连接内的双向字节流，可以承载一条或多条消息。
* 消息：与逻辑请求或响应消息对应的完整的一系列帧。
* 帧：HTTP/2 通信的最小单位，每个帧都包含帧头，至少也会标识出当前帧所属的数据流。

在二进制分帧层上，HTTP2.0 会将所有传输的信息分割为更小的消息和帧，并对它们采用二进制格式的编码，其中 HTTP1.x 的首部信息会被封装到 Headers 帧，而我们的 request body 则封装到 Data 帧里面。

![imag](http://pic-blog.bfvyun.com/http2.0/http25.jpg)

总结关系如下：
* 所有通信都在一个 TCP 连接上完成，此连接可以承载任意数量的双向数据流。
* 每个数据流都有一个唯一的标识符和可选的优先级信息，用于承载双向消息。
* 每条消息都是一条逻辑 HTTP 消息（例如请求或响应），包含一个或多个帧。
* 帧是最小的通信单位，承载着特定类型的数据，例如 HTTP 标头、消息负载，等等。 来自不同数据流的帧可以交错发送，然后再根据每个帧头的数据流标识符重新组装。

### 请求优先级

HTTP消息分解为很多独立的帧之后，客户端和服务器交错发送和传输这些帧的顺序就成为关键的性能决定因素。有没有可能当我们需要一些关键的JS或者CSS的时候，服务器却还在接受不太重要的一些图片信息等。
HTTP2.0为每个数据流设置了一个优先级，每个数据流分配一个介于 1 至 256 之间的整数作为优先级，同时数据流之间可以存在显示的依赖关系。
客户端可以构建和传递“优先级树”，表明它倾向于如何接收响应。反过来，服务器可以使用此信息通过控制 CPU、内存和其他资源的分配设定数据流处理的优先级，在资源数据可用之后，带宽分配可以确保将高优先级响应以最优方式传输至客户端。

### 首部压缩

HTTP/1 中，HTTP 请求和响应都是由「状态行、请求 / 响应头部、消息主体」三部分组成。一般而言，消息主体都会经过 gzip 压缩，或者本身传输的就是压缩过后的二进制文件（例如图片、音频），但状态行和头部却没有经过任何压缩，直接以纯文本传输。
页面产生的请求数越多，消耗在头部的流量越多，尤其是每次都要传输 UserAgent、Cookie 这类不会频繁变动的内容，完全是一种浪费。

![imag](http://pic-blog.bfvyun.com/http2.0/http26.jpg)

HTTP2.0 在客户端和服务器端使用“首部表”来跟踪和存储之前发送的键-值对，对于相同的数据，不再通过每次请求和响应发送；通信期间几乎不会改变的通用键-值对（用户代理、可接受的媒体类型，等等）只需发送一次。

首部发生变化了，那么只需要发送变化了数据在 Headers 帧里面，新增或修改的首部帧会被追加到“首部表”。首部表在 HTTP2.0 的连接存续期内始终存在，由客户端和服务器共同渐进地更新。

### 服务器推送

![imag](http://pic-blog.bfvyun.com/http2.0/http27.jpg)
HTTP/2 新增的另一个强大的新功能是，服务器可以对一个客户端请求发送多个响应。 换句话说，除了对最初请求的响应外，服务器还可以向客户端推送额外资源，而无需客户端明确地请求。
一个服务器经常知道一个页面需要很多附加资源，在它响应浏览器第一个请求的时候，可以开始推送这些资源。这允许服务端去完全充分地利用一个可能空闲的网络，改善页面加载时间。
当然这同时也是它的一个缺点，如果客户端已经缓存了数据，此时会产生不必要的冗余。这也是为什么推荐服务器提示（Server Hints）的原因。

参考：
[HTTP/2 简介](https://developers.google.com/web/fundamentals/performance/http2/?hl=zh-cn)
[检查网站是否支持 SPDY 或者 HTTP/2 的 Chrome 扩展](https://chrome.google.com/webstore/detail/http2-and-spdy-indicator/mpbpobfflnpcgagjijhmgnchggcjblin?hl=zh-CN)
[配置Nginx，开启HTTP/2](https://iyaozhen.com/nginx-http2-conf.html)
[HTTP2中英对照版](https://github.com/fex-team/http2-spec/blob/master/HTTP2%E4%B8%AD%E8%8B%B1%E5%AF%B9%E7%85%A7%E7%89%88(06-29).md)
