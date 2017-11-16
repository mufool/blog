---
title: Hexo博客环境搭建
date: 2017-09-13 17:20:19
tags: [HEXO]
---
## git安装

<!-- more -->

```
yum install git -y
```

## 安装Node

到 Node.js 官网下载相应平台的 最新版本 ，一路安装即可。[Node.js 究竟是什么？](https://www.ibm.com/developerworks/cn/opensource/os-nodejs/index.html)

```java
wget https://nodejs.org/dist/v6.11.3/node-v6.11.3.tar.gz  --no-check-certificate
tar -xzvf node-v6.11.3.tar.gz
cd node-v6.11.3
./configure
make
make install
```

## 安装hexo

```
npm install -g hexo

```

在blog所在目录下安装插件

```
npm install hexo --save
npm install hexo-deployer-git --save
```

同时，执行以下命令查看缺少的插件逐个安装，否则无法生成所需要的index.html等文件

```
npm ls --depth 0
```

## 配置ssh

### 生产key并添加

```
ssh-keygen -t rsa -C "邮件地址@gmail.com"
```

一路回车，将生产的id_rsa.pub文件内容添加到github的SSH keys的配置项中。

### 测试

```
ssh -T git@github.com
```

提示

```
Hi cnfeat! You've successfully authenticated, but GitHub does not provide shell access.
```

### 设置用户信息

现在你已经可以通过 SSH 链接到 GitHub 了，还有一些个人信息需要完善的。
Git 会根据用户的名字和邮箱来记录提交。GitHub 也是用这些信息来做权限的处理，输入下面的代码进行个人信息的设置，把名称和邮箱替换成你自己的，名字必须是你的真名，而不是GitHub的昵称。

```
$ git config --global user.name "mufool"//用户名
$ git config --global user.email  "email@gmail.com"//填写自己的邮箱
```

## 生产部署

```
hexo g
hexo d
```
提交成功

注：其他问题，自行google

参考：
[如何搭建一个独立博客](http://www.jianshu.com/p/05289a4bc8b2)
