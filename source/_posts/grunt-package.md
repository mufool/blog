---
title: Grunt打包前端代码
date: 2017-09-22 16:19:23
tags: [JS]
---
## Grunt介绍
grunt是一套前端自动化构建工具，一个基于nodeJs的命令行工具，一般用于压缩文件，合并文件等，与java世界的Maven工具类似。

<!-- more -->

## Grunt安装
[Centos下安装Grunt](http://mufool.com/2017/08/21/centos-grunt/)

## Grunt使用

每一个gurnt都会需要这两个文件package.json和Gruntfile.js，package.json这个文件用来存储npm模块的依赖项，比如我们的打包若是依赖requireJS的插件；Gruntfile.js读取package信息，插件加载、注册任务，运行任务。

### package.json示例

```js
{
    "name": "clouds",
    "version": "0.0.1",
    "author": "xx@xx.com",
    "description": "clouds-app",
    "dependencies": {
        "ejs": "*",  
        "grunt": "~0.4.1",
        "grunt-contrib-less": "*",
        "grunt-contrib-uglify": "~0.2.2",
        "grunt-contrib-cssmin": "~0.9.0"
    }
}
```
devDependencies中添加所需要的插件，以及对应的版本信息。以及一些会显示在文件中的版本，作者信息等。
在已有package.json的情况下，执行`npm install`会自动将所需要的插件下载到node_modules目录下，

### Gruntfile.js示例

```js
module.exports = function (grunt) {
    var zipjs,compileJsConfig,config;
    config = {
        pkg: grunt.file.readJSON('package.json'),
        ismap: false,//是否生成调试代码
        path: {less: 'less/',style: 'style/',script:"script/",src:"src/"},
        less: { // 编译 LESS 文件
            compile: {
                files: {
                    '<%= path.style %>index.css':['<%= path.less %>index.less'],
                     ......
                }
            }
        },
        cssmin: { // 压缩 CSS 文件
            options: {
                report : "min"
            },
            combine: {
                files: {
                  '<%= path.style %>index.min.css': '<%= path.style %>index.css',
                ......
                }
            }
        },
        uglify: {// 压缩合并 JS 文件
            options: {
                report:'min',
                expand: true,
                mangle: true,
                sourceMapRoot: '../../',
                preserveComments: 'false',
                beautify: {
                    ascii_only: true//中文ascii化,防止中文乱码
                },
                banner: '/** \n' +//生成注释
                        ' * -------------------------------------------------------------\n' +
                        ' * Copyright (c) 2014 xx, All rights reserved. \n' +
                        ' * @version: <%= pkg.version%> \n' +
                        ' * @author: <%= pkg.author%> \n' +
                        ' * @description: <%= pkg.description%> \n' +
                        ' * @date: <%=grunt.template.today("yyyy-mm-dd  HH:MM:ss")%>\n' +
                        ' * ------------------------------------------------------------- \n' +
                        ' */ \n\n'
            }
        }
    };
    zipjs = {//压缩配置
        swfupload : {
            namespace : config.path.script+'swfUpload.min.js',
            dstname : [config.path.ui+'SwfLoaderBar.js',config.path.view+'swfUpload.js']
        },
                ......
    };
    compileJsConfig = function (config) {
        var json;
        for (var key in zipjs) {//需要压缩的代码
            json = {}
            json[zipjs[key].namespace] = zipjs[key].dstname;
            config.uglify[key] = {files:json};
        }
        if(config.ismap){
            config.uglify.options.sourceMap = function(path){// 生成 map文件的地址
                var file = path.split("/"),filename = file.pop(),route = file.join("/") + "/";
                return route + "map/" +  filename.replace('.js','.map');
            };
            config.uglify.options.sourceMappingURL = function(path){// 用于定义 map文件地址 并放在压缩文件底部， url相对于 压缩文件
                var file = path.split("/"),filename = file.pop();
                return "map/" +  filename.replace('.js','.map');
            };  
        }
        return config;
    };

    //读取配置文件
    grunt.initConfig(compileJsConfig(config));

    //加载任务的插件
    grunt.loadNpmTasks('grunt-contrib-less');
    grunt.loadNpmTasks('grunt-contrib-uglify');
    grunt.loadNpmTasks('grunt-contrib-cssmin'); 

    //注册任务
    grunt.registerTask('build', ['less','cssmin','uglify']);
    grunt.registerTask('default', ['uglify']);//不带参数，及执行uglify
};
```

参考：
[Grunt：任务自动管理工具](http://javascript.ruanyifeng.com/tool/grunt.html)

