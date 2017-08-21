---
title: 域名邮箱服务
date: 2017-07-05 11:15:13
layout: post
tags: [DOMAIN]
---

## MX（Mail Exchanger）记录

MX是邮件交换记录，它指向一个邮件服务器，用于电子邮件系统发邮件时根据 收信人的地址后缀来定位邮件服务器。例如，当Internet上的某用户要发一封信给 user@mydomain.com 时，该用户的邮件系统通过DNS查找mydomain.com这个域名的MX记录，如果MX记录存在， 用户计算机就将邮件发送到MX记录所指定的邮件服务器上。 MX记录也叫做邮件路由记录，用户可以将该域名下的邮件服务器指向到自己的mail server上，然后即可自行操控所有的邮箱设置 。

<!-- more -->

## MX优先级

如果您的域有多个 MX 记录，邮件发件人将决定使用哪一个记录。MX 记录使用一个称为“首选项”的字段以确定优先级。当您创建 MX 记录时，大多数 DNS 托管提供商要求您设置首选数字。有些提供商将输入框标记为“首选项”，另一些标记为“优先级”。有些提供商要求输入数字，另一些提供商要求您选择“低”、“中”或“高”。

## 一级域名邮箱设置

以下是在DNSPOD上，添加主域名（mail.mydomain.com）的邮箱记录，将其指定到自定义的邮件服务器上（对应A记录的ip地址）
![domain-mail-1](http://mufool.qiniudn.com/domain/domain-mail-1.jpg)

## 二级域名邮箱设置

已有一级邮箱域名服务（mail.mydomain.com），现添加二级域名（mail.mails.mydomian.com）的邮件服务，将其cname到阿里云的邮件服务器上。
![domain-mail-2](http://mufool.qiniudn.com/domain/domain-mail-2.jpg)

