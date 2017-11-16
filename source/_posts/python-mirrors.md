---
title: Python使用国内源下载
date: 2017-11-16 16:54:00
tags: [PYTHON]
---

## 现象

通过pip安装scipy、scikit-learn等库的时候，可能会报上面的错误

<!-- more -->

```
ReadTimeoutError: HTTPSConnectionPool(host='pypi.python.org', port=443): Read timed out.
```

## 原因及解决方法

以上原因是因为默认使用国外源进行下载，下载速度慢导致超时。解决方法更换成国内园即可。

国内源：
* http://pypi.douban.com/  豆瓣
* http://pypi.hustunique.com/  华中理工大学
* http://pypi.sdutlinux.org/  山东理工大学
* http://pypi.mirrors.ustc.edu.cn/  中国科学技术大学

下载时指定源

```
sudo pip  install --index https://pypi.mirrors.ustc.edu.cn/simple/  scikit-learn
```

或者，更改默认的配置，创建~/.pip/pip.conf，添加

```
[global]
index-url = https://pypi.mirrors.ustc.edu.cn/simple/ 
```
