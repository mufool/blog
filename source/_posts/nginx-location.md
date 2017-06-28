---
layout: post
title: Nginx location优先级
date: 2016-10-28 17:08:37
tags: [Nginx]
---

### 一、精确匹配

<!-- more -->

```
location = /web/crossdomain.xml {
...
}
```

### 二、前缀匹配

* 普通前缀匹配

```
location /web/ {

...
}
```

* 优先前缀匹配

```
location ^~/web/ {
...
}
```

### 三、正则匹配

* 区分大小写
```
location ~ /web/.*\.xml$ {
...
}
```

* 不区分大小写
```
location ~* /web/.*\.xml$ {
...
}
```
* 区分大小写取反
```
location !~ /web/.*\.xml$ {
...
}
```

* 不区分大小写取反
```
location !~* /web/.*\.xml$ {
... 
}
```

### 四、指定匹配
```
error_page 404 = @fallback;
location @fallback {
... 
}
```

### 五、匹配优先级详解
先匹配普通，再匹配正则，正则匹配不覆盖普通匹配则精确匹配，但覆盖普通匹配的最大前缀匹配结果。
1. 匹配普通location，没有顺序之分，原则是找到严格精确匹配（=），找到严格精确匹配则匹配结束。
2. 如果没有找到严格精确匹配，找到所有普通location中的最大前缀匹配（~或^~）。
3. 如果找到的最大前缀匹配是优先前缀匹配（^~），则匹配结束。否则进行正则匹配。
4. 正则匹配没有顺序之分，原则是匹配成功便终止匹配。
5. 如果没有匹配的正则location，则使用第三步中的普通最大前缀匹配。

### 六、匹配示例
请求url：http://example.com/web/crossdomain.xml

1、如果精确匹配命中
```
location = /web/crossdomain.xml {
...
}
```
则优先精确匹配，并结束匹配。

2、如果命中多个前缀匹配
```
location /web/ {
...
}
 
location /web/crossdomain.xml {
...
}
```
则记住其中最大前缀匹配，即/web/crossdomain.xml，并继续匹配

3、如果最长前缀匹配中是优先前缀匹配
```
location /web/ {
... 
}
 
location ^~ /web/crossdomain.xml {
... 
}
```
则命中此最长的优先前缀匹配，即^~/web/crossdomain.xml，并终止匹配

4、如果命中多个正则匹配
```
location /web/ {
... 
}
 
location /web/crossdomain.xml {
... 
}
 
location ~* /web/ {
... 
}
 
location ~* /web/crossdomain.xml {
... 
}
```
则忽略第二，三步中的最长前缀匹配，使用第一个命中的正则匹配，即~* /web/，并结束匹配

5、否则，命中前面几步中记住的最长前缀匹配

6、如果均未匹配到，且有404指定匹配
```
error_page 404 = @fallback;
location @fallback {
...
}
```
