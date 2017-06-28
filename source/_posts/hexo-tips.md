---
title: hexo博客颜色设置
date: 2016-07-18 16:13:40
tags: [hexo]
---

hexo博客的颜色由css控制，具体文件是由位于目录hexoblog/public/css下的main.css来定义，通过这篇博客[Hexo博客小知识：更改背景颜色](http://prozhuchen.github.io/2016/07/10/Hexo%E5%8D%9A%E5%AE%A2%E5%B0%8F%E7%9F%A5%E8%AF%86%EF%BC%9A%E6%9B%B4%E6%94%B9%E8%83%8C%E6%99%AF%E9%A2%9C%E8%89%B2/)介绍的方法修改以下两处可以将博客背景色更换成自己喜欢的颜色

<!-- more -->

```stylus
/*头部的背景颜色设置*、
2134 .header {
2135   background: #d1fab8;
2136 }

/*主体部分颜色设置*/
 187   position: relative;
 188   font-family: 'Lato', "PingFang SC", "Microsoft YaHei", sans-serif;
 189   font-size: 14px;
 190   line-height: 2;
 191   color: #555;
 192   background: #e0fccf;
 193 }
```

但是以上修改在重新生成blog时会失效，原因是main.css也是在博客发布时生成的，每次发布都会被重新生成的文件替换掉，所以只有修改源文件中的定义才能生效，源文件目录themes/next/source/css

修改文件themes/next/source/css/_variables/base.styl以下两处，增加header-bgex 和body-bgex两个颜色定义，一个是头部和脚部的颜色值定义，一个是主题部分颜色值定义。同时主题颜色的更改在48行修改body-bg-colo的值即可。

```stylus
11 $header-bgex  = #d1fab8
12 $body-bgex    = #e0fccf
13 $whitesmoke   = #f5f5f5
14 $gainsboro    = #eee
15 $gray-lighter = #ddd
16 $grey-light   = #ccc
17 $grey         = #bbb
18 $grey-dark    = #999
...
47 // Background color for <body>
48 //$body-bg-color              = white
49 $body-bg-color                = $body-bgex
```

修改themes/next/source/css/_schemes/Mist/sidebar/_header.styl文件中头部的背景色为base.styl定义的背景色

```stylus
3 .header { background: $header-bgex; }
```

修改themes/next/source/css/_schemes/Mist/index.styl中footer相关定义，可以修改footer颜色值

```stylus
 72 // Footer
 73 // --------------------------------------------------
 74 .footer {
 75   margin-top: 80px;
 76   padding: 10px 0;
 77   background: $header-bgex;
 78   color: $grey-dim;
 79 }
```

其他部分的颜色样式修改同理。
