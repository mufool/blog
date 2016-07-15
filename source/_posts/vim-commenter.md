---
layout: post
title: vim注释
date: 2016-07-11 13:19:48
tags:
---

## 简单介绍
支持多种语言的补全，还支持单行注释，批量注释，等各种命令映射。

<!-- more -->

## 使用方法
以下count代表数字，就是向下注释几行的意思，leader代表组合键的切入点，就是从这个键开始,vim捕获组合键，我这里的leader 是\逗号

```
	[count][leader]cc	注释当前行，加上数字就向下注释多少行 //fdsa
	[count][leader]cn	强制嵌套注
	[count][leader]c[空格]	注释与取消注释之间切换
	[count][leader]cm	前后注释     /*lfkdsa*/
	|NERDComInvertComment|	分别注释选中的行
	[count][leader]cs	性感注释   这里弄不效果 哦，可尝试一下
	[count][leader]cy	跟cc一样,为/*   */注释方法
	[leader]c$		从当前行开始注释到最后一行
	[leader]cA		在行的末尾添加注释
	[leader]ca		切换注释标记集   比较  // 变成 /*   */
	[count][[leader]cm	为光标以下 n 行添加块注释
	[count][leader]cl	Same cc, 并且左对齐
	[count][leader]cb	Same cc, 并且两端对齐.
	[count][leader]cu	取消注释
```
 
使用<leader>cc快捷键进行注释选中的行，<leader>cu进行反注释。其中<leader>是键盘映射，默认情况下是反斜杆“”，则上述快捷键分别为：cc和cu。你可以使用命令自定义，例如命令:let mapleader=”,”将<leader>定义为”,”键。
