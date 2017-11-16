---
title: Maven下载慢的解决方法
date: 2017-06-09 14:42:05
tags: [HADOOP]
---

## 问题描述

Maven仓库默认下载速度很慢，非常影响项目的开发速度和构建速度。

<!-- more -->

## 解决办法

### 使用Nexus搭建私服

使用Nexus搭建私服的问题在于，如果是第一次构建，仍然会比较慢，它适用于团队。

### 更换镜像仓库

镜像仓库则比较适用于个人，可以利用国内其他人搭建的maven库，加速下载。这里使用的是阿里云的镜像仓库。

在maven的setting.xml里配置mirrors的子节点，添加如下可用的镜像仓库的mirror：

```xml
  <mirrors>
    <!-- mirror
     | Specifies a repository mirror site to use instead of a given repository. The repository that
     | this mirror serves has an ID that matches the mirrorOf element of this mirror. IDs are used
     | for inheritance and direct lookup purposes, and must be unique across the set of mirrors.
     |
    <mirror>
      <id>mirrorId</id>
      <mirrorOf>repositoryId</mirrorOf>
      <name>Human Readable Name for this Mirror.</name>
      <url>http://my.repository.com/repo/path</url>
    </mirror>
     -->
        <mirror>
                <id>nexus-aliyun</id>
                <mirrorOf>central</mirrorOf>
                <name>Nexus aliyun</name>
                <url>http://maven.aliyun.com/nexus/content/groups/public</url>
        </mirror>
  </mirrors>
```

## 配置默认仓库地址
在pom.xml中也使用aliyu的仓库
```xml
    <repositories>
        <repository>
            <id>central</id>
            <name>Maven Repository Switchboard</name>
            <layout>default</layout>
            <!-- <url>http://repo.akka.io/releases</url>  -->
            <url>http://maven.aliyun.com/nexus/content/groups/public</url>
            <snapshots>
            <enabled>false</enabled>
            </snapshots>
        </repository>
    </repositories>
```
