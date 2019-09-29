---
title: Vimium使用
date: 2019-09-29 15:46:26
tags: [PLUGIN,VIM]
---

[TOC]

## 简介

Vimium 这个名字其实是 Vim 和 Chromium 的合体。很多人可能不知道 Vim，这么说吧，你是不是经常在电影里看到那些顶尖的黑客，他们在屏幕上来去自如，最关键的是，他们竟然都不用鼠标？没错，狭义地说，Vim 其实是 Linux 等平台上的一款文本编辑器，它可以让你彻底脱离鼠标，通过一系列快捷键，来操作任何一件事情。

Vimium是一款谷歌浏览器扩展程序，它继承了 Vim 中的常用操作，让我们在使用 Chrome 的过程中，无论是浏览网页、切换标签或是其它任何操作，全都可以只通过键盘完成。想像一下，你再也不需要移动鼠标去打开一个链接，手指不用离开键盘，一切都是这么流畅。

Vimium 插件可以帮我们做到：

- 帮助您在不触摸鼠标的情况下浏览网页
- 使用巧妙的突出显示方法来使用链接进行导航
- 可自定义的键盘快捷键
- 有一个页面内的帮助对话框来提醒您个性化的快捷键

github地址：https://github.com/philc/vimium
项目官网：http://vimium.github.io/

## 使用技巧

### 跳转任意链接

只用敲三下，打开当前页面上任意一个链接，任意一个页面上，哪所有再多链接，你也不用鼠标，最多只需要敲三个键，你就可以迅速打开任意一个链接。

你只需要按一下「f」，然后当前页面会显示所有可点击的元素，vimium 会生成一个对应的快捷键给这些链接。再输入对应的字符就可以打开。

### 打开新页面

- 复制一段链接：经常在网页上看到一段链接文字，但却是不可点的。原来你需要先复制，然后新建标签页，再粘贴，敲回车后才能打开。现在呢？你只需要把要打开的链接复制一下，直接按「p」或「P」就可以打开了，小写的 p 是在当前标签页打开，大写的 P 则新建标签页打开。

- 从收藏夹、历史记录打开：是不是之前看过什么网页，现在又想看了，还需要再打开历史记录找？或者想打开收藏夹里的某个链接？现在，直接按下「o」，输入对应的关键字后，会一起搜索你的历史记录和收藏夹，如果你输的是一个网址，回车还能直接打开。

### 标签页快速切换

- 有时候在查找信息、翻阅资料时，经常会一口气打开几十个网站，东西一多，Chrome 会自动将每个标签页的宽度缩小，几乎就看不到它们的标题了。用了 Vimium，你可以按一下大写的「T」，就可以显示当前打开的所有标签页，并支持快捷搜索和跳转。

### 自定义搜索引擎

配置自定义搜索引擎，通过快捷键 o/O 调起搜索框，输入搜索引擎简写，再输入空格，再输入搜索词回车，则会调用对应的搜索引擎进行搜索。

常用的搜索引擎配置
```
w: https://www.wikipedia.org/w/index.php?title=Special:Search&search=%s Wikipedia

# More examples.
#
# (Vimium supports search completion Wikipedia, as
# above, and for these.)
#
g: https://www.google.com/search?q=%s Google
G: https://www.google.com/search?q=%s Google
zh: https://www.zhihu.com/search?type=content&q=%s 知乎
ZH: https://www.zhihu.com/search?type=content&q=%s 知乎
tb https://s.taobao.com/search?q=%s 淘宝
TB https://s.taobao.com/search?q=%s 淘宝
jd https://search.jd.com/Search?keyword=%s 京东
JD https://search.jd.com/Search?keyword=%s 京东
bd: https://www.baidu.com/s?wd=%s 百度
BD: https://www.baidu.com/s?wd=%s 百度
bz https://search.bilibili.com/all?keyword=%s b站
BZ https://search.bilibili.com/all?keyword=%s b站
az: https://www.amazon.com/s/?field-keywords=%s Amazon
AZ: https://www.amazon.com/s/?field-keywords=%s Amazon
aqy https://so.iqiyi.com/so/q_%s 爱奇艺
AQY https://so.iqiyi.com/so/q_%s 爱奇艺
tm https://list.tmall.com/search_product.htm?q=%s 天猫
TM https://list.tmall.com/search_product.htm?q=%s 天猫
yk https://so.youku.com/search_video/q_%s 优酷
YK https://so.youku.com/search_video/q_%s 优酷
db https://www.douban.com/search?q=%s 豆瓣
DB https://www.douban.com/search?q=%s 豆瓣
y: https://www.youtube.com/results?search_query=%s Youtube
Y: https://www.youtube.com/results?search_query=%s Youtube
# l: https://www.google.com/search?q=%s&btnI I'm feeling lucky...
# gm: https://www.google.com/maps?q=%s Google maps
# b: https://www.bing.com/search?q=%s Bing
# d: https://duckduckgo.com/?q=%s DuckDuckGo
# qw: https://www.qwant.com/?q=%s Qwant
```

在插件的options中加入快捷配置即可。


## 快捷键

### 当前页面操作

```
?       显示help，查询vimium的所有使用方法
h       向左滚动
j       向下滚动
k       向上滚动
l       向右滚动
gg      滚动到顶部
G       滚动到底部
d       向下滚动半页
u       向上滚动半页面
f       显示链接字母，在当前页面打开
F       显示链接字母，在新的页面打开
r       刷新
gs      显示网页源代码
i       进入插入模式，所有按键的命令都无效，直至ESC键退出
yy      将当前的网址复制到剪贴板
yf      显示链接字母，并将网址拷贝到剪贴板
gf      循环到下一帧(尤其在选择网页内置视频的时候很管用)
gF      聚焦主/顶框架
```

### 新页面操作

```
o       搜索网址，书签，或历史记录，在当前页面打开
O       搜索网址，书签，或历史记录，在新的页面打开
b       搜索书签，在当前页面打开
B       搜索书签，在新的页面打开
T       搜索当前浏览器的所有标签
```

### 使用搜索

```
/       进入查找模式，输入关键字查找，ESC退出
n       切换到下一个匹配
N       切换到上一个匹配
```

### 浏览历史记录

```
H       回到历史，也就是回到前一页
L       在历史上前进，也就是回到后一页
```

### 标签操作

```
J, gT   切换到左边tab
K, gt   切换到右边tab
g0      切换到第一个tab
g$      切换到最后一个tab
^       切换到刚才的tab
t       创建一个新的页面
yt      复制当前页面
x       关闭当前页面
X       恢复刚才关闭的页面
p       在当前标签页打开剪切板中的URL，如不是URL则默认引擎搜索
P       在新标签页打开剪切板中的URL，如不是URL则默认引擎搜索
W       将当前标签移动到新窗口
<a-p>   pin/unpin current tab
```

### 标记

```
ma      当页标记，只能在当前tab页面跳转，m + 一个小写字母
mA      全局标记，可以再切换到其他tab的跳转过来，m + 一个大写字母
`a      跳转到当页标记
`A      跳转到全局标记
``      跳回之前的位置(也就是说，在执行gg，G，n，N，或/ a 之前的位置）
```

### 进阶控制命令

```
<<      当前标签页向左移动
>>      当前标签页向右移动
<a-f>   在新标签中打开多个链接
gi      聚焦页面上的第一个（或第n个）文本输入框
gu      跳转到URL层次的父类(xxx.com/yyy/zzz 跳转到 xxx.com/yyy)
gU      转到URL层次结构的根目录(也就是 xxx.com)
ge      编辑当前的网址，在当前页面打开
gE      编辑当前网址，在新的页面打开
zH      滚动到最左边
zL      滚动到最右边
v       进入预览模式;使用p / P粘贴，然后使用y来拷贝
V       enter visual line mode
<a-m>   开/关静音
<a-p>   固定标签栏
```

### 其他

```
5t      数字num + t，打开num个tab页面
<Esc>   ESC按钮，可以从任意控制命令中退出，也可以从任意模式中退出（例如插入模式、查找模式）
```

### 预览模式（visual mode）

```
先用 / 定位，找到想要选择的字符
    再按 v ,进入模式
    然后使用
        j：向下一行
        k：向上一行
        h：向左一个字符或标点（数字+h，可以移动多个字符）
        l：向右一个字符或标点（数字+l，可以移动多个字符）
        w：下一个标点符号后位置，包括看不见的换行符
        e：下一个标点符号前位置
        b：取消选中上一个字符，字符和标点算一个字符
```

参考：

[vimium 成神之路-键盘党的胜利](https://zhuanlan.zhihu.com/p/64533566)
[vimium 官方视频](https://v.youku.com/v_show/id_XMjM0MTE3MDcy.html)
