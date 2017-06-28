---
title: hexo添加disqus评论
date: 2017-06-19 12:42:28
tags: [hexo]
---
## 注册disqus

disqus[官网](https://disqus.com)，按要求注册一个账户，添加你的博客地址

## 获取shortname

在Settings->General下可以看到你的Shortname。

## 添加到blog

打开根目录下的config.yml, 在最后面添加，disqus_shortname: your_disqus_short_name，去掉其他评论配置。

刷新页面即可看到评论系统。
