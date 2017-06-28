---
layout: post
title: Nginx代理缓存配置详解
date: 2016-10-28 17:08:37
tags: [Nginx]
---

## Nginx代理相关配置

<!-- more -->

* proxy_buffers [number] [size]
number默认为8；size在32为平台下位4K，在64位平台为8K，即和一个内存页大小相等；此参数用来设定从后端server读取响应时使用的buffer空间，注意buffer的设定全部是针对一个链接而言（或者说是请求）。
* proxy_buffer_size [size]
默认值与proxy_buffers中size参数一致；设定用于保存后端server响应的第一部分内容的buffer大小，这部分包含一个小的响应的header。通常此值可以设置的更小。
* proxy_buffering [on|off]
默认值为on；设定是否buffer来自后端server的响应。
当buffering开启时，nginx将会缓存从后端server收到的响应，保存在proxy_buffer_size和proxy_buffers设定的buffer中；如果整个响应无法全部保存在buffer内存中，则剩余部分将会写入临时文件，临时文件由proxy_max_temp_file_size、proxy_temp_file_write_size设定。
当buffering关闭时，nginx收到响应后立即将会以同步的方式发送给客户端，nginx不会尝试读取整个响应（读取整个响应后才发送给客户端），nginx能够读取（等待客户端读取）的最大数据量为proxy_buffer_size。buffering可以通过响应的header中X-Accel-Buffering来指定，可选值为yes或者no；当然nginx也可以通过proxy_ignore_headers来忽略这个header。
* proxy_busy_buffers_size [size]
默认值为proxy_buffer_size或者proxy_buffers的2倍。如果nginx边读取响应，同时还将buffer中的数据发送给客户端，那么这个buffer即为busy；当buffering开启时，此指令用于设定当响应尚未完全读取之前，nginx能够发送给客户端的最大buffer数据量；剩余的buffer，将会用于读取响应，如果buffer不足，将写入临时文件。处于busy状态的buffer，尽管已经发送，当仍然不能被当前请求回收重用。
* proxy_max_temp_file_size [size]
默认值为1024m；当buffering开启时，如果proxy_buffer_size无法全部保存响应内容，那么剩余的将会被写入临时文件，这个指令就是控制临时文件的最大尺寸。
* proxy_temp_path [path] [level]
设定一个Path用来保存临时文件，path用来设定临时文件的路径，其中level表示目录的层级，最大为3级，1级的目录名有一个字符表示，2级为2个，三级为三个。例如：proxy_temp_path /home/data/nginx/tmp 1 2，表示开启2级目录。
* proxy_connect_timeout [time]
默认值为60s；定义nginx与后端server建立链接的超时时间，此时间不能超过75秒。
* proxy_hide_header [field]
默认nginx不会将响应中的Date、Server、X-Pa、X-Accel-...等headers发送给客户端。proxy_hide_header指令设置不需要发送的额外的field；反之，对于可以传递给客户端的filed，通过proxy_pass_header指令指定。
* proxy_http_version [1.0 | 1.1]
 默认值为1.0；指定与后端server通信时使用的http协议的版本，在与keepalive链接配合使用时，建议此值为1.1。
* proxy_ignore_headers [field...]
指定来自后端server的响应中的某些header不会被处理，如下几个fields可以被ignore：X-Accel-Redirect、X-Accel-Expires、X-Accel-Limit-Rate、X-Accel-Buffering、X-Accel-Charset、Expires、Cache-Control、Set-Cookie、Vary。不被处理就是nginx不会尝试解析这些header并应用它们，比如nginx处理来自后端server的Expires，将会影响它本地的文件cache的机制。
* proxy_intercept_errors [on | off]
默认值为“off”；当后端server的响应code >= 300时，是否跳转到error_page指令指定的错误页面上。如果为off，将nginx不做拦截，直接将后端server的响应返回给客户端。
```
proxy_intercept_errors on; 
error_page 404 /404.html; 
error_page 500 502 503 504 /50x.html  
```
* proxy_next_upstream
此指令很重要，用来设定当何种情况下，请求将会被转发给下一个后端server。此指令允许的参数列表为：
1）error：当nginx与后端server建立连接、发送请求、读取响应header时，发生错误。
2）timeout：当nginx与后端server在建立链接、发送请求（write）、读取响应header（read）时，操作超时。
3）invalid_header：如果后端server返回空的或者无效的header时。
4）http_500、http_502、http_503、http_504、http_403、http_404：后端server返回指定的错误code时。
5）off：不将请求转发给下一个server，直接响应错误code。
* proxy_pass [URL]
只在location段设置有效，设置转发给后端server时请求所使用的HTTP协议和URI，协议可以为http、https；地址可以为域名、ip，其中port是可选的，默认为80。如果proxy_pass指令指定了URI，那么请求中匹配location部分的URI将会被替换。
```
location /test { 
    proxy_pass http://127.0.0.1:8080/testex; 
} 
#http://exampe.org/test/a.html将会被转发给http://127.0.0.1:8080/testex/a.html 
```
	如果location中使用了uri，但是proxy_pass中没有使用，那么请求的uri将会全部添加到proxy_pass指定的路径之后。
```
location /test { 
    proxy_pass http://127.0.0.1:8080; 
} 
#请求url为http://example.org/test/a.html将会被转发到http://127.0.0.1:8080/test/a.html 
```
	如果location中使用了正则表达式，那么在proxy_pass指令中不应该指定uri，否则uri的替换是无法断定的。
	如果在location中使用了“rewrite”指令（break）对请求的uri进行了修改，那么proxy_pass指令中的uri将会被忽略，被rewrite之后的全量uri将会传递给server。
```
location /test { 
    rewrite /test/([^/]+) /users?test=$1 break; 
    proxy_pass http://127.0.0.1; 
} 
#http://exmaple.org/test/zhangsan，将会转发到http://127.0.0.1/users?test=zhangsan  
```
	其中server名称、端口、uri等均可以使用变量：
```
proxy_pass http://$host$uri; 
##等价于 
proxy_pass $request;  
```
* proxy_pass_header [field]
 上述我们已经知道，proxy_hide_header指令默认不会把几个header传递给client，那么proxy_pass_header则允许其中某个header传递给客户端。
* proxy_pass_request_body [on | off]
默认值为on，不建议修改此值；是否将原始的请求body转发给后端server。如果你需要nginx对body进行裁剪，然后再转发给后端server，那么此处可以设定为off。
* proxy_pass_request_header [on | off]
 默认值为on，不建议修改此值；指定是否将请求的原始header转发给后端的server。如果在某些场景下，nginx需要忽略所有的请求header，或者对header进行改造时，可以关闭此值。
* proxy_read_timeout [time]
默认值为“60s”；设定nginx从后端server读取响应时的超时时间，此时间为两次read操作之间阻塞的最大时间，而非整个响应的读取耗时。
* proxy_send_timeout [time]
默认为“60s”；nginx将响应发送给客户端时最长的阻塞时间。同上。
* proxy_set_header [field] [value]
 此指令的作用是，将请求发送给后端server之前，重新设置或者append指定的header的值。当然我们也可以重新设置上述两个header。

## Nginx缓存开启
安装nginx之后只需要两个命令即可启用nginx缓存功能：proxy_cache_path和proxy_cache。proxy_cache_path用来设置缓存相关配置，proxy_cache用来开启缓存。
```
 proxy_cache_path /opt/data1 levels=1:2 keys_zone=my_cache:128m inactive=7d max_size=10g use_temp_path=off;
 
server{
listen       80;
 
location ~ \.lb$ {
       proxy_pass http://vodcdnsrc.baofengcloud.com;
                 proxy_cache my_cache;
                 proxy_cache_revalidate on;
                 proxy_cache_min_uses 3;
                 proxy_cache_use_stale error timeout updating http_500 http_502 http_503 http_504;
                 proxy_cache_lock on;
                 proxy_cache_key $request_uri; 
                 proxy_cache_valid 400 404 500 0m;
                 proxy_cache_valid any 1h;
         }
}
```

* /opt/data1：用于缓存本地文件的磁盘目录。
* levels：用于缓存文件的目录结构配置，不配置此项则所有文件存于同一个目录，大量文件存放于同一个目录会导致访问变慢。可以按照需求配置目录结构，如：1：2，是对请求uri进行MD5hash，其中最后以为做1级目录，倒数二三位做2级目录。
* keys_zone：内存缓存空间的名字和大小。
* inactive：指定了项目在不被访问的情况下能够在内存中保持的时间。在上面的例子中，如果一个文件在 60 分钟之内没有被请求，则缓存管理将会自动将其在内存中删除，不管该文件是否过期。该参数默认值为 10 分钟（10m）。
* max_size：设置了本地缓存的上限（在上面的例子中是 10G）。这是一个可选项；如果不指定具体值，那就是允许缓存不断增长，占用所有可用的磁盘空间。当缓存达到这个上线，处理器便调用 cache manager 来移除最近最少被使用的文件，这样把缓存的空间降低至这个限制之下。
* use_temp_path：指示nginx将临时文件写在同一个目录中，减少数据的拷贝。该参数在nginx 1.7版本及以上支持。
* proxy_cache：控制哪部分location启用缓存，也可将proxy_cache应用到server部分，这会将缓存应用到所有的location中。

## Nginx缓存调优相关参数
* proxy_cache_revalidate ：指示 Nginx 在刷新来自服务器的内容时使用 GET 请求。如果客户端的请求项已经被缓存过了，但是在缓存控制头部中定义为过期，那么 Nginx 就会在 GET 请求中包含 If-Modified-Since 字段，发送至服务器端。这项配置可以节约带宽，因为对于 Nginx 已经缓存过的文件，服务器只会在该文件请求头中 Last-Modified 记录的时间内被修改时才将全部文件一起发送。
* proxy_cache_min_uses：该指令设置同一链接请求达到几次即被缓存，默认值为 1 。当缓存不断被填满时，这项设置便十分有用，因为这确保了只有那些被经常访问的内容会被缓存。
* proxy_cache_use_stale：该配置项指定，当无法从原始服务器获取最新的内容时， Nginx 可以分发缓存中的陈旧（stale，编者注：即过期内容）内容。这种情况一般发生在关联缓存内容的原始服务器宕机或者繁忙时。比起对客户端传达错误信息，Nginx 可发送在其内存中的陈旧的文件。 Nginx 的这种代理方式，为服务器提供额外级别的容错能力，并确保了在服务器故障或流量峰值的情况下的正常运行。如以上配置中当 Nginx 收到服务器返回的error，timeout或者其他指定的5xx错误，并且在其缓存中有请求文件的陈旧版本，则会将这些陈旧版本的文件而不是错误信息发送给客户端。
* proxy_cache_lock：该参数被启用时，当多个客户端请求一个缓存中不存在的文件（或称之为一个 MISS），只有这些请求中的第一个被允许发送至服务器。其他请求在第一个请求得到满意结果之后在缓存中得到文件。如果不启用proxy_cache_lock，则所有在缓存中找不到文件的请求都会直接与服务器通信。
* proxy_cache_key：设置Web缓存的Key值，Nginx根据Key值md5哈希存储缓存。
* proxy_cache_valid：设置不同响应的缓存，如以上配置，不缓存400,404,500，其他响应缓存1小时。

## 跨多块硬盘分割缓存
当有多块磁盘是，不需要建立磁盘RAID，nginx可以在多块磁盘之间分割缓存。
```
proxy_cache_path /opt/data1 levels=1:2 keys_zone=cache_1:128m inactive=7d max_size=10g use_temp_path=off;
proxy_cache_path /opt/data2 levels=1:2 keys_zone=cache_2:128m inactive=7d max_size=10g use_temp_path=off;

split_clients $request_uri $cache_disk {
        50% cache_1;
         * cache_2;
}

server{
        location ~ \.lb$ {
               proxy_pass http://vodcdnsrc.baofengcloud.com;
               proxy_cache_key $request_uri;
               proxy_cache $cache_disk;
        }
}
```
上面例子中配置了两个缓存区，cache_1和cache_2，分别属于不同的存储目录。split_clients配置指定文件按照$request_uri(请求URI)的hash值来决定存储在其中哪块磁盘上，同时分别指定了每块磁盘的比例。

## Nginx缓存状态检测

```
add_header X-Cache-Status $upstream_cache_status;
```
nginx提供了$upstream_cache_status这个变量来显示缓存的状态，我们可以在配置中添加一个http头来显示这一状态，使用add_header可以添加一个返回头。

$upstream_cache_status的可能值如下：

* MISS：响应在缓存中找不到，所以需要在服务器中取得。这个响应之后可能会被缓存起来。
* BYPASS：响应来自原始服务器而不是缓存，因为请求匹配了一个proxy_cache_bypass（见下面我可以在缓存中打个洞吗？）。这个响应之后可能会被缓存起来。
＊EXPIRED：缓存中的某一项过期了，来自原始服务器的响应包含最新的内容。
* STALE：内容陈旧是因为原始服务器不能正确响应。需要配置proxy_cache_use_stale。
* UPDATING：内容过期了，因为相对于之前的请求，响应的入口（entry）已经更新，并且proxy_cache_use_stale的updating已被设置。
* REVALIDATED：proxy_cache_revalidate命令被启用，NGINX检测得知当前的缓存内容依然有效（If-Modified-Since或者If-None-Match）。
* HIT：响应包含来自缓存的最新有效的内容。 

### Nginx缓存控制和优先级

nginx作为代理使用的时候，会从源站得到Cache-Control，No-Cache，No-Store等响应字段，此种情况下nginx不缓存文件，同时，nginx默认缓存GET以及HEAD信息，不缓存post。

* proxy_ignore_headers：可以配置nginx忽略哪些请求头，对不缓存的文件也进行缓存。
* proxy_cache_methods：可以配置nginx缓存哪些请求类型， GET HEAD POST。

影响缓存的配置项主要有：nginx的inactive，源服务器的max-age和Expires以及nginx的proxy_cache_vaild。其中优先级顺序为：
inactive、源服务器Expires、源服务器的max-age、proxy-cache-vaild。

### Nginx代理缓存配置文件

```
worker_processes  1; #处理进程数，一般与服务器线程数相同
 
events {
        use epoll;    #事件模型，epoll模型是Linux 2.6以上版本内核中的高性能网络I/O模型
        worker_connections 65535;
}
 
http {
        log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                        '$status $body_bytes_sent "$http_referer" '
                        '"$http_user_agent" "$http_x_forwarded_for" "$upstream_cache_status" ';
 
        access_log  /var/log/nginx/access.log   main;
        error_log   /var/log/nginx/error.log;
 
        sendfile on; #开启高效文件传输模式，sendfile指令指定nginx是否调用sendfile函数来输出文件，对于普通应用设为 on，如果用来进行下载等应用磁盘IO重负载应用，可设置为off，以平衡磁盘与网络I/O处理速度，降低系统的负载。
        #autoindex on; #开启目录列表访问，合适下载服务器，默认关闭。
        #tcp_nopush on; #防止网络阻塞
        #tcp_nodelay on; #防止网络阻塞    
        keepalive_timeout 65;#长连接超时时间，单位是秒
        include mime.types;
        default_type application/octet-stream;

        client_max_body_size 10m;    #允许客户端请求的最大单文件字节数
        client_body_buffer_size 128k;  #缓冲区代理缓冲用户端请求的最大字节数
        proxy_connect_timeout 90; 
        proxy_send_timeout 90;
        proxy_read_timeout 90;
        proxy_buffer_size 64k;
        proxy_buffers 4 128k;
        proxy_busy_buffers_size 256k; 
        proxy_temp_file_write_size 256k; 
 
        proxy_cache_path /opt/data1 levels=1:2 keys_zone=cache_1:128m inactive=7d max_size=10g use_temp_path=off;
        proxy_cache_path /opt/data2 levels=1:2 keys_zone=cache_2:128m inactive=7d max_size=10g use_temp_path=off;
 
        split_clients $request_uri $cache_disk {
                50% cache_1;
                * cache_2;
        }
 
        proxy_redirect off;
        #proxy_set_header Host $host; #设置回源的host信息
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
 
        server{
                listen       80;
                server_name localhost;
                access_log /var/log/nginx/doaccess.log main;
                error_log /var/log/nginx/doerror.log error;
 
                location = /crossdomain.xml {
                        root /opt/data;
                }
 
                location ~ \.lb$ {
                        proxy_pass http://vodcdnsrc.baofengcloud.com;
                        proxy_ignore_headers Cache-Control;
                        proxy_buffering on; 
                        proxy_cache_key $request_uri;
                        proxy_cache_lock on;
                        proxy_cache $cache_disk;
                        proxy_cache_use_stale error timeout updating http_500 http_502 http_503 http_504;
                        proxy_cache_valid 400 404 500 0m;
                        proxy_cache_valid any 1h;
                        proxy_cache_min_uses 1;
                        add_header X-Cache-Status "$upstream_cache_status";
                }
        }
}
```

参考
[ngx_http_proxy_module所有参数详解](http://nginx.org/en/docs/http/ngx_http_proxy_module.html?_ga=1.44900964.1568941527.1438257987)
[NGINX缓存使用官方指南](https://linux.cn/article-5945-1.html)
