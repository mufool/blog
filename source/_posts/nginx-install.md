---
layout: post
title: nginx编译安装
date: 2017-06-16 19:48:32
tags: [NGINX]
---

## 编译

<!-- more -->

```
tar xzvf nginx-1.10.1.tar.gz
cd nginx-1.10.1
./configure \
--prefix=/opt/modules/nginx \
--sbin-path=/opt/modules/nginx/sbin/nginx \
--conf-path=/opt/modules/nginx/conf/nginx.conf \
--error-log-path=/var/log/nginx/error.log \
--http-log-path=/var/log/nginx/access.log \
--pid-path=/var/run/nginx/nginx.pid \
--lock-path=/var/lock/nginx.lock \
--user=nginx --group=nginx \
--with-http_ssl_module \
--with-http_stub_status_module \
--with-http_gzip_static_module \
--http-client-body-temp-path=/opt/modules/nginx/client_body_temp/ \
--http-proxy-temp-path=/opt/modules/nginx/nginx_proxy/ \
--http-fastcgi-temp-path=/opt/modules/nginx/fastcgi_temp/ \
--add-module=../redis2-nginx-module-0.13 \
--add-module=../nginx-http-concat-1.2.2
make
```

## 安装
```
make install
cp objs/nginx  /usr/local/bin/
groupadd nginx
useradd -g nginx nginx
cp init.d/nginx /etc/init.d/
chmod 755 /etc/init.d/nginx
```

## 添加开机启动
```
/sbin/chkconfig --add nginx
/sbin/chkconfig --level 35 nginx on
/sbin/service nginx start
```
