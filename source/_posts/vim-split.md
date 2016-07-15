---
layout: post
title: vim分屏操作
date: 2016-07-08 12:16:24
tags:
---

## 打开分屏

### vim中打开分屏
<!-- more -->
```
	:sp filename		水平分屏
	:split filename
	:vsp filename		垂直分屏
	:vsplit filename
	:sview filename		只读分屏打开文件

	:split		水平打开当前文件分屏
	ctrl+W s	水平打开当前文件分屏
	:vspilt		垂直打开当前文件分屏
	ctrl+W v	垂直打开当前文件分屏

	:30split 打开一个高度为30的窗口
	:30vsplit 打开一个宽带为30的窗口
```

### shell中打开分屏
```
	vim -On file1, file2 ...  垂直分屏
	vim -on file1, file2 ...  水平分屏
```
其中n为分几个屏

## 切换分屏
```
	Ctrl+w w			后一个
	Ctrl+w p			前一个
	ctrl+w h,j,k,l		上下左右操作
	ctrl+w 				上下左右键头
```

## 关闭分屏
```
	ctrl+W c 	关闭当前窗口
	ctrl+w q 	关闭当前窗口，若只有一个分屏且退出vim
	ctrl+w o	关闭其他窗口
	:only  		仅保留当前分屏
	:hide  		关闭当前分屏
```

## 调整分屏的大小
```
	ctrl+w = 		所有分屏都统一高度
	ctrl+w + 		增加高度
	:res[ize] +N	使得当前窗口高度加N(默认值是1), 如果在 'vertical' 之后使用，则使得宽度加N

	ctrl+w - 		减少高度
	:res[ize] -N		使得当前窗口高度减N(默认值是1), 如果在 'vertical' 之后使用，则使得宽度减N

	10 ctrl+w +		增加10行高度
	10 ctrl+w -		减少10行高度

	:res[ize] [N]
	CTRL-W _ 		设置当前窗口的高度为 N (默认值为最大可能高度)。
 
	:vertical res[ize] [N]
	CTRL-W |			设置当前窗口的宽度为 N (默认值为最大可能宽度)。

	CTRL-W <			使得当前窗口宽度减 N (默认值是 1)
	CTRL-W >			使得当前窗口宽度加 N (默认值是 1)
```

## 移动分屏
```
	ctrl+W H,J,K,L
```
