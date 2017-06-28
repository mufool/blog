---
title: Linux下su与su -命令的区别
date: 2017-06-09 14:38:26
tags: [LINUX]
---

## su命令

su命令用于切换当前用户身份到其他用户身份，变更时须输入所要变更的用户帐号与密码。
在不加参数的情况下，su命令默认表示切换到root用户，之后只要输入root密码就可以切换身份为root了，操作完成后，使用exit或者Ctrl+D可以退出root切换到原先的用户。

<!-- more -->

### 语法

```
su (选项) (参数)
```

### 选项

```
-c <指令>，--command=<指令>：执行完指定的指令后，即恢复原来的身份
-f，--fast：适用于csh与tsch，使shell不用去读取启动文件
-，-l，--login：改变身份时，也同时变更工作目录，以及HOME,SHELL,USER,logname。此外，也会变更PATH变量
-m，-p，--preserve-environment：变更身份时，不要变更环境变量
-s，--shell=：指定要执行的shell
--help：显示帮助
--version；显示版本信息
```

### 参数

用户：指定要切换身份的目标用户。

### 实例

变更帐号为root并在执行ls指令后退出变回原使用者： 

```
su -c ls root 
```

变更帐号为test并改变工作目录至test的home目录： 

```
su - test 或者 su -l test
```

### su和su -的区别

su命令和su -命令最大的本质区别就是：已切换到root用户为例， 前者只是切换了root身份，但Shell环境仍然是普通用户的Shell；而后者连用户和Shell环境一起切换成root身份了。
因此，当时用su命令切换用户执行命令的时候，切记两者的区别，以免出现环境变量错误导致的程序执行错误问题。、
如果只需要切换执行一条命令，su -c是更好的选择，执行完操作后就会切换回原来的账户。

### su命令的缺点

普通用户切换到root用户需要提供密码，从root切换到普通用户不需要密码 su命令虽然很方便，但是缺陷也很明显，就是切换成其他用户的时候需要知道对方密码。

如果需要切换到root用户就需要root密码，root是系统权限最高的用户，如果让太多人知道root密码，必然会不安全。为了解决这个问题我们可以使用sudo命令

## sudo命令

sudo命令用来以其他身份来执行命令，预设的身份为root。在/etc/sudoers中设置了可执行sudo指令的用户。若其未经授权的用户企图使用sudo，则会发出警告的邮件给管理员。
相比于su切换身份需要用户的密码，经常性的是需要root密码用户使用sudo时，必须先输入密码，之后有5分钟的有效期限，超过期限则必须重新输入密码。

### 语法
```
sudo(选项)(参数)
```

### 选项
```
-b：在后台执行指令
-h：显示帮助
-H：将HOME环境变量设为新身份的HOME环境变量
-k：结束密码的有效期限，也就是下次再执行sudo时便需要输入密码
-l：列出目前用户可执行与无法执行的指令
-p：改变询问密码的提示符号
-s：执行指定的shell
-u<用户>：以指定的用户作为新的身份。若不加上此参数，则预设以root作为新的身份
-v：延长密码有效期限5分钟
-V ：显示版本信息。
```

### sudo权限配置

配置sudo必须通过编辑/etc/sudoers文件，而且只有超级用户才可以修改它，还必须使用visudo编辑。之所以使用visudo有两个原因，一是它能够防止两个用户同时修改它；二是它也能进行有限的语法检查。所以，即使只有你一个超级用户，你也最好用visudo来检查一下语法。 

此时我们有三种选择：键入“e”是重新编辑，键入“x”是不保存退出，键入“Q”是退出并保存。如果真选择Q，那么sudo将不会再运行，直到错误被纠正。

visudo默认的是在vi里打开配置文件，用vi来修改文件。我们可以在编译时修改这个默认项。visudo不会擅自保存带有语法错误的配置文件，它会提示你出现的问题，并询问该如何处理。
此时我们有三种选择：键入“e”是重新编辑，键入“x”是不保存退出，键入“Q”是退出并保存。如果真选择Q，那么sudo将不会再运行，直到错误被纠正。

### /etc/sudoers文件修改

```
Defaults   !visiblepw
Defaults    !env_reset
Defaults    env_keep =  "COLORS DISPLAY HOSTNAME HISTSIZE INPUTRC KDEDIR LS_COLORS"
Defaults    env_keep += "MAIL PS1 PS2 QTDIR USERNAME LANG LC_ADDRESS LC_CTYPE"
Defaults    env_keep += "LC_COLLATE LC_IDENTIFICATION LC_MEASUREMENT LC_MESSAGES"
Defaults    env_keep += "LC_MONETARY LC_NAME LC_NUMERIC LC_PAPER LC_TELEPHONE"
Defaults    env_keep += "LC_TIME LC_ALL LANGUAGE LINGUAS _XKB_CHARSET XAUTHORITY"
Defaults   env_keep += "HOME"
root    ALL=(ALL)       ALL

User_Alias DTDEV = dtdev
DTDEV      ALL=(ALL)     NOPASSWD:ALL,!/bin/bash,!/bin/su root,!/usr/bin/chattr,!/usr/sbin/useradd,!/usr/sbin/userdel,!/usr/bin/passwd

User_Alias SPORTS =dtdev1,dtdev2
SPORTS       ALL=(ALL)       NOPASSWD: ALL
```
第一个ALL是指网络中的主机，我们后面把它改成了主机名，它指明foobar可以在此主机上执行后面的命令。第二个括号里的ALL是指目标用户，也就是以谁的身份去执行命令。最后一个ALL当然就是指命令名了。例如，我们想让dtdev用户在linux主机上以dtdev1或dtdev2的身份执行kill命令，这样编写配置文件：

```
dtdev    linux=(dtdev1,dtdev2)    /bin/kill
```

但这还有个问题，dtdev到底以dtdev1还是dtdev2的身份执行？这时我们应该想到了sudo -u了，它正是用在这种时候。 foobar可以使用sudo -u jimmy kill PID或者sudo -u rene kill PID，但这样挺麻烦，其实我们可以不必每次加-u，把dtdev1或dtdev2设为默认的目标用户即可。再在上面加一行：

```
Defaults:dtdev     runas_default=dtdev1
```

Defaults后面如果有冒号，是对后面用户的默认，如果没有，则是对所有用户的默认。就像配置文件中自带的一行：

```
Defaults    !env_reset
```
表示所有用户切换都不重置环境变量

很多时候，我们本来就登录了，每次使用sudo还要输入密码就显得烦琐了。我们可不可以不再输入密码呢？当然可以，我们这样修改配置文件：

```
SPORTS       ALL=(ALL)   NOPASSWD: ALL
```
你也可以说“某些命令用户dtdev不可以运行”，如以上配置通过使用!操作符，但这不是一个好主意。因为，用!操作符来从ALL中“剔出”一些命令一般是没什么效果的，一个用户完全可以把那个命令拷贝到别的地方，换一个名字后再来运行。

### 日志安全

sudo为安全考虑得很周到，不仅可以记录日志，还能在有必要时向系统管理员报告。但是，sudo的日志功能不是自动的，必须由管理员开启。这样来做：
```
touch /var/log/sudo
vi /etc/syslog.conf
```
在syslog.conf最后面加一行（必须用tab分割开）并保存：
```
local2.debug /var/log/sudo
```
重启日志守候进程
```
ps aux grep syslogd
```
把得到的syslogd进程的PID（输出的第二列是PID）填入下面：
```
kill –HUP PID 
```
