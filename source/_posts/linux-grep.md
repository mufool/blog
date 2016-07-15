---
layout: post
title: grep使用详解
tags: [LINUX]
---

## grep简介

grep （global search regular expression(RE) and print out the line,全面搜索正则表达式并把行打印出来）是一种强大的文本搜索工具，它能使用正则表达式搜索文本，并把匹配的行打印出来。Unix的grep家族包 括grep、egrep和fgrep。egrep和fgrep的命令只跟grep有很小不同。egrep是grep的扩展，支持更多的re元字符， fgrep就是fixed grep或fast grep，它们把所有的字母都看作单词，也就是说，正则表达式中的元字符表示回其自身的字面意义，不再特殊。linux使用GNU版本的grep。它功能 更强，可以通过-G、-E、-F命令行选项来使用egrep和fgrep的功能。

<!-- more -->

grep的工作方式是这样的，它在一个或多个文件中搜索字符串模板。如果模板包括空格，则必须被引用，模板后的所有字符串被看作文件名。搜索的结果被送到屏幕，不影响原文件内容。

grep可用于shell脚本，因为grep通过返回一个状态值来说明搜索的状态，如果模板搜索成功，则返回0，如果搜索不成功，则返回1，如果搜索的文件不存在，则返回2。我们利用这些返回值就可进行一些自动化的文本处理工作。
 
## grep正则表达式元字符集（基本集）

| 元字符 | 基本功能 | 示例
|--------|----------|--------------
| ^ | 锚定行的开始 | '^grep'匹配所有以grep开头的行
| $ | 锚定行的结束 | 'grep$'匹配所有以grep结尾的行
| . | 匹配一个非换行符的字符 | 'gr.p'匹配gr后接一个任意字符，然后是p
| * | 匹配零个或多个先前字符 | '*grep'匹配所有一个或多个空格后紧跟grep的行。 .*一起用代表任意字符
| [] | 匹配一个指定范围内的字符 | '[Gg]rep'匹配Grep和grep
| [^] | 匹配一个不在指定范围内的字符 | '[^A-FH-Z]rep'匹配不包含A-R和T-Z的一个字母开头，紧跟rep的行
| \(..\) | 标记匹配字符 | '\(love\)'，love被标记为1
| \< | 锚定单词的开始 | '\<grep'匹配包含以grep开头的单词的行
| \> | 锚定单词的结束 | 'grep\>'匹配包含以grep结尾的单词的行
| x\{m\} | 重复字符x，m次 | '0\{5\}'匹配包含5个o的行
| x\{m,\} | 重复字符x,至少m次 | 'o\{5,\}'匹配至少有5个o的行
| x\{m,n\} | 重复字符x，至少m次，不多于n次 | 'o\{5,10\}'匹配5--10个o的行
| \w | 匹配文字和数字字符，也就是[A-Za-z0-9 | 'G\w*p'匹配以G后跟零个或多个文字或数字字符，然后是p
| \W | \w的反置形式，匹配一个或多个非单词字符 | 点号句号等
| \b | 单词锁定符 | '\bgrep\b'只匹配grep

## 用于egrep和 grep -E的元字符扩展集

+——匹配一个或多个先前的字符。如：'[a-z]+able'，匹配一个或多个小写字母后跟able的串，如loveable,enable,disable等。

?——匹配零个或多个先前的字符。如：'gr?p'匹配gr后跟一个或没有字符，然后是p的行。

a|b|c——匹配a或b或c。如：grep|sed匹配grep或sed

()——分组符号，如：love(able|rs)ov+匹配loveable或lovers，匹配一个或多个ov。

x{m},x{m,},x{m,n}——作用同x\{m\},x\{m,\},x\{m,n\}
 
## POSIX字符类

为了在不同国家的字符编码中保持一至，POSIX(The Portable Operating System Interface)增加了特殊的字符类，如[:alnum:]是A-Za-z0-9的另一个写法。要把它们放到[]号内才能成为正则表达式，如[A- Za-z0-9]或[[:alnum:]]。在linux下的grep除fgrep外，都支持POSIX的字符类。

| POSIX字符组 | 说明 | ASCII语言环境
|-------------|------|------------------
| [:alnum:] | 文字数字字符 | [a-zA-Z0-9]
| [:alpha:] | 文字字符 | [a-zA-Z]
| [:digit:] | 数字字符 | [0-9]
| [:graph:] | 非空字符（非空格、控制字符） | [\x21-\x7E]
| [:lower:] | 小写字符 | [a-z]
| [:cntrl:] | 控制字符 | [\x00-\x1F\x7F]
| [:print:] | 非空字符（包括空格） | [\x20-\x7E]
| [:punct:] | 标点符号 | [][!"#$%&'()*+,./:;<=>?@\^_`{&#124;}~-]
| [:space:] | 所有空白字符（新行,空格,制表符）| [ \t\r\n\v\f]
| [:upper:] | 大写字符 | [A-Z]
| [:xdigit:] | 十六进制数字（0-9，a-f，A-F） | [A-Fa-f0-9]
| [:word:] | 字母字符 | [A-Za-z0-9_]
| [:ascii:] | ASCII字符 | [\x00-\x7F]
| [:blank:] | 空格字符和制表符 | [ \t]
 
## grep选项

| 选项 | 含义 | 选项 | 含义
|------|------|------|------------
| 匹配模式选择: | - | 输入控制: | - |
| -E, --extended-regexp | 扩展正则表达式egrep  | -m, --max-count=NUM | 匹配的最大数 
| -F, --fixed-strings | 一个换行符分隔的字符串的集合fgrep | -b, --byte-offset | 打印匹配行前面打印该行所在的块号码
| -G, --basic-regexp | 基本正则 | -n, --line-number | 显示的加上匹配所在的行号 
| -P, --perl-regexp | 调用的perl正则 | --line-buffered | 刷新输出每一行 
| -e, --regexp=PATTERN | 后面根正则模式，默认无 | -H, --with-filename | 当搜索多个文件时，显示匹配文件名前缀 
| -f, --file=FILE | 从文件中获得匹配模式 | -h, --no-filename | 当搜索多个文件时，不显示匹配文件名前缀 
| -i, --ignore-case | 不区分大小写  | --label=LABEL | print LABEL as filename for standard input
| -w, --word-regexp | 匹配整个单词  | -o, --only-matching | show only the part of a line matching PATTERN
| -x, --line-regexp | 匹配整行  | -q, --quiet, --silent | 不显示任何东西
| -z, --null-data  | a data line ends in 0 byte, not newline  | --binary-files=TYPE | assume that binary files are TYPE
| 杂项: | - | -a, --text | 匹配二进制的东西 
| -s, --no-messages  | 不显示错误信息 | -I | 不匹配二进制的东西
| -v, --invert-match | 显示不匹配的行 | -d, --directories=ACTION | 目录操作，读取，递归，跳过
| -V, --version  | 显示版本号 | -D, --devices=ACTION | 设置对设备，FIFO,管道的操作，读取，跳过
| --help | 显示帮助信息 | -R, -r, --recursive | 递归调用 
| --mmap | use memory-mapped input if possible | --include=PATTERN | files that match PATTERN will be examined
| 文件控制: | - | --exclude=PATTERN | files that match PATTERN will be skipped
| -B, --before-context=NUM | 打印匹配本身以及前面的几个行由NUM控制 | --exclude-from=FILE | files that match PATTERN in FILE will be skipped
| -A, --after-context=NUM | 打印匹配本身以及随后的几个行由NUM控制 | -L, --files-without-match | 匹配多个文件时，显示不匹配的文件名 
| -C, --context=NUM | 打印匹配本身以及随后，前面的几个行由NUM控制 | -l, --files-with-matches | 匹配多个文件时，显示匹配的文件名 
| -NUM  | 根-C的用法一样的 | -c, --count | 显示匹配了多少次 
| --colo[u]r[=WHEN] | use markers to distinguish the matching string | -Z, --null | print 0 byte after FILE name
| -U, --binary | do not strip CR characters at EOL (MSDOS) | - | - 
| -u, --unix-byte-offsets | report offsets as if CRs were not there (MSDOS) | -  | -

注：部分选项对应的取值
--binary-files=TYPE：TYPE is 'binary', 'text', or 'without-match'
-d, --directories=ACTION：ACTION is 'read', 'recurse', or 'skip'
-D, --devices=ACTION：ACTION is 'read' or 'skip'
--colour[=WHEN]：WHEN may be `always', `never' or `auto'

## 应用举例

1. 匹配包含root的行
	```
	[root@jsyd-1 shell]# grep root gtest
	root:x:0:0:root:/root:/bin/bash
	```

2. 匹配以root或者zhang开始的行，使用反斜杠或者-E
	```
	[root@jsyd-1 shell]# cat gtest | grep '^\(root\|zhang\)'
	root:x:0:0:root:/root:/bin/bash
	zhangy:x:1000:100:,,,:/home/zhangy:/bin/bash

	[root@jsyd-1 shell]#  cat gtest | grep -E '^(root|zhang)'
	zhangsan:x:1000:100:,,,:/home/zhangjx:/bin/bash
	zhangsan:x:33:33::/srv/http:/bin/false/zhangsan
	```

3. 匹配以zhang开头且只包含字母的行
	```
	[root@jsyd-1 shell]# echo zhangjiaxing | grep 'zhang[a-z]*$'
	zhangsan
	```

4. -n参数显示匹配的行数
	```
	[root@jsyd-1 shell]# cat gtest | grep -n zhang
	7:zhangy:x:1000:100:,,,:/home/zhangy:/bin/bash 
	13:ba:x:1002:1002::/home/zhangy:/bin/bash 
	15:@zhangsan:*:1004:1004::/home/test:/bin/bash
	```

5. -v参数反选，不包含bin的行
	```
	[root@jsyd-1 shell]# cat gtest | grep -nv 'bin'
	16:policykit:x:102:1005:Po
	```

6. -c输出匹配的行数，不以bin开头的行数
	```
	[root@jsyd-1 shell]# cat gtest | grep -cv '^bin'
	15
	```

7. -i忽略大小写匹配
	```
	[root@jsyd-1 shell]# cat gtest | grep system
	[root@jsyd-1 shell]# cat gtest | grep -i system
	dbus:x:81:81:System message bus:/:/bin/false
	```

8. -w必须匹配整个单词
	```
	[root@jsyd-1 shell]# cat gtest | grep -w zhang
	[root@jsyd-1 shell]# cat gtest | grep -w zhangy
	zhangy:x:1000:100:,,,:/home/zhangy:/bin/bash 
	ba:x:1002:1002::/home/zhangy:/bin/bash
	```

9. -x必须正行都和关键字相同
	```
	[root@jsyd-1 shell]# cat gtest | grep aaaa
	bin:x:1:1:bin:/bin:/bin/false,aaa,bbbb,cccc,aaaaaa
	aaaa

	[root@jsyd-1 shell]# cat gtest | grep -x aaaa
	aaaa
	```

10. -m设定匹配的最大次数，只输出前两个匹配到的行
	```
	[root@jsyd-1 shell]# cat gtest | grep -m 2 zhang
	zhangy:x:1000:100:,,,:/home/zhangy:/bin/bash
	ba:x:1002:1002::/home/zhangy:/bin/bash
	```

11. -b显示匹配到时所在的字节数
	```
	[root@jsyd-1 shell]# cat gtest | grep -b zhang
	253:zhangy:x:1000:100:,,,:/home/zhangy:/bin/bash
	504:ba:x:1002:1002::/home/zhangy:/bin/bash
	586:@zhangying:*:1004:1004::/home/test:/bin/bash
	```

12. -H多文件匹配输出文件名，-h不输出
	```
	[root@jsyd-1 shell]# grep -H zhang gtest*
	gtest:@zhangjiaxing:*:1004:1004::/home/test:/bin/bash
	gtest:zhangjx:x:1000:100:,,,:/home/zhangjx:/bin/bash
	gtest:zhangjx:x:33:33::/srv/http:/bin/false/zhangjx
	gtest1:zhangy:x:1000:100:,,,:/home/zhangy:/bin/bash
	gtest1:ba:x:1002:1002::/home/zhangy:/bin/bash
	gtest1:@zhangying:*:1004:1004::/home/test:/bin/bash
	```

13. -l只输出匹配到的文件名，-L相反输出没有匹配到的文件名，可通过$?查看匹配的结果
	```
	[root@jsyd-1 shell]# grep -l zhang gtest*
	gtest
	gtest1

	[root@jsyd-1 shell]# grep -L zhang gtest*
	```

14. -o输出匹配到的部分，而不是整行

15. -q不输出任何内容，可通过echo $?查看匹配的结果

16. -R对目录进行递归匹配，shell为文件目录
	```
	grep zhang -R shell/
	```

17. 输出匹配前后的行
	```
	cat gtest | gerp -A 3 zhang 输出匹配后三行
	cat gtest1 | grep -B 3 zhang 输出匹配前三行
	cat gtest1 | grep -3 zhang == cat gtest1 | grep -C 3 zhang 出匹配前后个三行
	```

18. 显示颜色
	```
	cat gtest1 | grep  zhang --colour=always
	```

19. 从文件g1中获取匹配的关键字
	```
	grep -f g1 gtest1
	```

20. 匹配zhang后接一个小写字符，POSIX字符使用需要两个[]
	```
	[root@jsyd-1 shell]# grep zhang[[:lower:]] gtest
	@zhangjiaxing:*:1004:1004::/home/test:/bin/bash
	zhangjx:x:1000:100:,,,:/home/zhangjx:/bin/bash
	zhangjx:x:33:33::/srv/http:/bin/false/zhangjx
	```

21. 匹配zhang后接3个小写字符
	```
	[root@jsyd-1 shell]# egrep zhang[[:lower:]]{3} gtest
	@zhangjiaxing:*:1004:1004::/home/test:/bin/bash
	```

## grep中模式之间的or、and、not操作

1. grep或(or)操作四种方式
	```
	$grep 'pattern1\|pattern2' filename 使用\|
	$grep -E 'pattern1|pattern2' filename 使用grep -E
	$egrep -E 'pattern1|pattern2' filename 使用egrep：同上
	$grep -e pattern1 -e pattern2 filename 通过制定多个-e
	```

2. grep与(and)操作
	```
	$grep -E 'pattern1.*pattern2|pattern2.*pattern1' filename 使用-E选项和模式字符, 查找同时包含两个模式的行
	$grep 'pattern1' filename | grep 'pattern2' 用管道实现
	```

3. grep非(not)操作
	```
	$grep -v zhang filename 使用-v选项实现
	```

## grep与egrep、fgrep、pgrep的区别

grep家族由命令grep、egrep、fgrep组成。grep命令是在文件中逐行全局查找指定的正则表达式，并且打印所有包含该表达式的行。egrep and fgrep均是grep的变体。egrep命令是扩展的grep，它能支持更多的正则表达式元字符。fgrep命令是固定的grep(fixed grep),有时也称作快速grep，它按字面解释所有字符，也就是说，正则表达式元字符不会被特殊处理，它们只匹配自己。自由软件基金会提供了grep的免费版本，称作GNU grep。Linux系统上使用的就是这种版本的grep。

+ grep命令:
由来：grep = global regular expression print 它表示"全局查找正正则表达式(RE)并且打印结果行"。

+ egrep (扩展的grep):
使用egrep的主要好处是它在grep提供的正则表达式元字符集的基础上添加了更多的元字符。但是egrep 不支持使用\( \) 和\{ \}。如果使用的Linux系统，请参考GNU的grep -E命令.

| 元字符 | 功能 | 实例 | 匹配对象
|--------|------|------|----------
| + | 匹配一个或多个前导字符 | [a-z]+ove | 匹配一个或多个小写字符后跟ove
| ？| 匹配0个或1个前导字符 | lo?ve | 匹配l后跟0个或者1个o以及字符ve
| a&#124;b | 匹配a或b | love&#124;hate | 匹配love或者hate两个之一
| () | 字符组 | love(able&#124;ly)(ov)+ | 匹配loveable或lovely匹配ov的一次或多次

+ fgrep（固定的grep或快速的grep）
fgrep命令的运行方式grep类似，但它不对任何正则表达式元字符做特殊处理。所有字符都只代表它自己的本身作为字符的意思。美元符就是美元符，全部如此。

+ pgrep（将模式解释为perl PE）
参考grep -P

参考：
[http://blog.51yip.com/linux/1008.html](http://blog.51yip.com/linux/1008.html)
[http://man.chinaunix.net/newsoft/grep/open.htm](http://man.chinaunix.net/newsoft/grep/open.htm)
[http://blog.csdn.net/gaoyingju/article/details/7737651](http://blog.csdn.net/gaoyingju/article/details/7737651)
