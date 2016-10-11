---
layout: post
title: DNS解析原理
tags: [DNS]
---

## 什么是DNS

DNS（Domain Name System，域名系统），因特网上作为域名和IP地址相互映射的一个分布式数据库，能够使用户更方便的访问互联网，而不用去记住能够被机器直接读取的IP数串。通过主机名，最终得到该主机名对应的IP地址的过程叫做域名解析（或主机名解析）。

<!-- more -->

## 域名结构

<img src="http://mufool.qiniudn.com/dns/structure.jpg" alt="">

1. 根域名服务器：根域名服务器是最高层次的域名服务器，也是最重要的域名服务器。所有的根域名服务器都知道所有的顶级域名服务器的域名和IP地址。
2. 顶级域名服务器： 这些域名服务器负责管理在该顶级域名服务器注册的所有二级域名。当收到DNS查询请求时，就给出相应的回答(可能是最后的结果，也可能是下一步应当找的域名服务器的IP地址)。
3. 权限域名服务器：这是负责一个区的域名服务器。当一个权限域名服务器还不能给出最后的查询回答时，就会告诉发出查询请求的DNS客户，下一步应当找哪一个权限域名服务器。
4. 本地域名服务器：本地域名服务器并不属于域名服务器层次结构，但它对域名系统非常重要。当一个主机发出DNS查询请求时，这个查询请求报文就发送给本地域名服务器。

## 域名记录类型

A记录：子域名对应的目标主机地址。目标主机地址类型只能使用IP地址
MX记录：将以该域名为结尾的电子邮件指向对应的邮件服务器以进行处理。
NS记录：解析服务器记录。用来表明由哪台服务器对该域名进行解析。
CNAME 记录：通常称别名指向。目标主机地址只能使用主机名，不能使用IP地址。一个主机地址同时存在A记录和CNAME记录，则CNAME记录不生效。

## DNS解析过程

[图片地址](http://www.tcpipguide.com/free/t_DNSNameResolutionProcess-2.htm)

<img src="http://mufool.qiniudn.com/dns/dnsresolution.png" alt="">

1. 浏览器中输入“www.net.compsci.googleplex.edu”，发出解析请求。
2. 本机的域名解析器( resolver)查询本地缓存和host文件中是否为域名的映射关系，如果有则调用这个IP地址映射，完成解析。
3. 如果hosts与本地DNS解析器缓存都没有相应的网址映射关系，则本地解析器会向TCP/IP参数中设置的首选DNS服务器（我们叫它本地DNS服务器）发起一个递归的查询请求。
4. 服务器收到查询时，如果要查询的域名，包含在本地配置区域资源中，则返回解析结果给客户机，完成域名解析，此解析具有权威性。如果要查询的域名，不由本地DNS服务器区域解析，但该服务器已缓存了此网址映射关系，则调用这个IP地址映射，完成域名解析，此解析不具有权威性。
5. 如果本地DNS服务器本地区域文件与缓存解析都失效，则根据本地DNS服务器的设置（是否设置转发器）进行查询，如果未用转发模式，本地DNS就把请求发至13台根DNS。如果用的是转发模式，此DNS服务器就会把请求转发至上一级DNS服务器，由上一级服务器进行解析，上一级服务器如果不能解析，或找根DNS或把转请求转至上上级，以此循环。
6. 根DNS服务器收到请求后会判断这个域名(.edu)是谁来授权管理，并会返回一个负责该顶级域名服务器的一个IP。
7. 本地DNS服务器收到IP信息后，将会联系负责.edu域的这台服务器。
8. 负责.edu域的服务器收到请求后，如果自己无法解析，它就会找一个管理.edu域的下一级DNS服务器地址(googleplex.com)给本地DNS服务器。
9. 当本地DNS服务器收到这个地址后，就会找googleplex.com域服务器，10、11重复上面的动作，进行查询。
12. 最后compsci.googleplex.edu返回需要解析的域名的IP地址给本地DNS服务器。
13. 本地域名服务器缓存这个解析结果（同时也会缓存，6,8,10返回的结果）。
14. 本地域名服务器同时将结果返回给本机域名解析器。
15. 本机缓存解析结果。
16. 本机解析器将结果返回给浏览器。
17. 浏览器通过返回的IP地址发起请求。

## 递归查询和迭代查询

* 递归查询：如果主机所询问的本地域名服务器不知道被查询域名的IP地址，那么本地域名服务器就以DNS客户的身份，向其他根域名服务器继续发出查询请求报文，而不是让该主机自己进行下一步的查询。
* 迭代查询：当根域名服务器收到本地域名服务器发出的迭代查询请求报文时，要么给出所要查询的IP地址，要么告诉本地域名服务器：“你下一步应当向哪一个域名服务器进行查询”。然后让本地域名服务器进行后续的查询，而不是替本地域名服务器进行后续的查询。

由此可见，本地DNS服务器开启转发模式时，客户端到本地DNS服务器，本地DNS与上级DNS服务器之间属于递归查询；未开启转发时，客户端到本地DNS服务器，DNS服务器之前属于迭代查询。

实际环境中，以为采用递归模式会导致DNS服务器流量很大，所以现在大多数的DNS都是迭代模式。这也是CDN厂商只能DNS实现的前提。

参考：
[DNS原理及其解析过程](http://369369.blog.51cto.com/319630/812889/)
[DNS101](https://www.verisign.com/assets/DNS101_zh_CN.pdf)
[域名的基础介绍及基本知识](https://www.douban.com/note/531534428/)


