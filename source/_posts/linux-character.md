---
layout: post
title: Linux字符集更改
date: 2017-05-15 15:01:31
tags: [LINUX]
---

查看当前字符集设置：

```
	echo $LANG
```

<!-- more -->

查看当前支持的字符集：

```
	locale -a
```

修改当前字符集设置：

```
	vi /etc/locale.conf
	source /etc/locale.conf
```
