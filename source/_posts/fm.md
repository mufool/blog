---
title: FM原理和使用
date: 2017-11-20 18:49:12
tags: [机器学习]
---

## 简介

FM算法，全称Factorization Machines,一般翻译为“因子分解机”。2010年，它由当时还在日本大阪大学的Steffen Rendle提出。此算法的主要作用是可以把所有特征进行高阶组合，减少人工参与特征组合的工作，工程师可以将精力集中在模型参数调优。FM只需要线性时间复杂度，可以应用于大规模机器学习。经过部分数据集试验，此算法在稀疏数据集合上的效果要明显好于SVM。

<!-- more -->

## 模型形式

在线性回归模型中，每个feature具有一个权重，参数求解过程相当于构造一个超平面将空间分为两部分。线性回归最大的优点是简单高效，只需要计算好每个feature的权重。但是缺点也是模型比较简单，只能建模线性关系（不过大部分时候也够用了，不够用时可以用特征工程）。

传统线性回归基于以下模型，从模型方程易见，各特征分量xi和xj是相互独立。

![image](http://mufool.qiniudn.com/fm/fm1.jpg)
但是，一般线性模型无法学习到高阶组合特征，所以会将特征进行高阶组合，这里以二阶为例(理论上，FM可以组合任意高阶，但是由于计算复杂度，实际中常用二阶，后面也主要介绍二阶组合的内容)。模型形式为，

![image](http://mufool.qiniudn.com/fm/fm2.jpg)

相比于线性模型而言，二阶模型多了n(n−1)2参数。比如有(n=)1000个特征（连续变量离散化，并one-hot编码，特征很容易到达此量级），增加近50万个参数。

FM使用近似矩阵分解。将参数量级减少成线性量级。可以将所有参数Wij组合成一个矩阵。

![image](http://mufool.qiniudn.com/fm/fm3.jpg)

![image](http://mufool.qiniudn.com/fm/fm4.jpg)
很明显，实数矩阵W是对称的。所以，实对称矩阵W正定（至少半正定，这里假设正定）。根据矩阵的性质，正定矩阵可以分解。

定理：当k足够大时，对于任意对称正定矩阵
![image](http://mufool.qiniudn.com/fm/fm5.jpg)
存在矩阵

![image](http://mufool.qiniudn.com/fm/fm6.jpg)

使得
![image](http://mufool.qiniudn.com/fm/fm7.jpg)

带入后，模型如下
![image](http://mufool.qiniudn.com/fm/fm8.jpg)


问题从求解矩阵W变成了求解矩阵V

这样做的有点：
* W需要求解的参数个数为n*n，V需要求解的个数为n*k，k是一个可调整的参数，通常远远小于n
* 上面说过为求解wij，需要大量同时不为0的xi，xj，这个几乎是不可解的，没有那么多的样本。参数因子化使得 xhxi的参数和 xixj 的参数不再是相互独立的，因此我们可以在样本稀疏的情况下相对合理地估计FM的二次项参数。具体来说，xhxi 和 xixj 的系数分别为 <vh,vi> 和 <vi,vj>，它们之间有共同项 vi。也就是说，所有包含“xi的非零组合特征”（存在某个 j≠i，使得 xixj≠0）的样本都可以用来学习隐向量 vi，这很大程度上避免了数据稀疏性造成的影响。而在多项式模型中，whi 和 wij 是相互独立的。

总的来说，计算效率得到质提升是因为使用近似计算，将参数复杂度从O(n2)降到O(n)。之前工作中遇到的介数估算，也使用类似套路，减少计算时间复杂度。

## FM实践

使用真实环境中用户的数据测试一下几个FM库，测试样本共800万条，正负样本各一半，特征为325个。因为本例是点击率预测的，所以属于二分类问题。

### libfm使用示例

训练
```
./libFM -task c -train /opt/hadoop/hadoop-2.6.5/train1.txt -test /opt/hadoop/hadoop-2.6.5/test1.txt -rlog ./log.txt -dim '1,1,16' -iter 10 -init_stdev 0.001 -method sgd -learn_rate 0.001  -regular '0,0,0.001' -save_model mode.fm -out model.txt
```

预测，`-iter`设置为0即可
```
./libFM -task c -train /opt/hadoop/hadoop-2.6.5/train1.txt -test /opt/hadoop/hadoop-2.6.5/test1.txt -rlog ./log.txt -dim '1,1,16' -iter 0 -init_stdev 0.001 -method sgd -learn_rate 0.001  -regular '0,0,0.001' -load_model mode.fm -out model.txt
```

rlog.txt为输出的log文件，对于回归输出的是均方差；对于分类输出为准确率。

### fastFM使用

支持tests目录下的例子即可，对于als的使用，可能会报错，需要修改源码中报错部分再安装。

### alphaFM使用

训练
```
cat train1.txt | /opt/hadoop/alphaFM-master/bin/fm_train -dim 1,1,16 -m /opt/hadoop/hadoop-2.6.5/model_file.txt -w_l1 0.05 -v_l1 0.05 -init_stdev 0.001 -w_alpha 0.01 -v_alpha 0.01 -core 10
```
预测
```
bin/hdfs dfs -cat /fmdata/20171107/part-*| /opt/hadoop/alphaFM-master/bin/fm_predict -dim 8 -m /opt/hadoop/hadoop-2.6.5/model_file.txt -out fm_pre.txt -core 10
```

### 对比

| FM库 | 语言 | 训练时间 | 准确性 | 接口 | 其他 |
|---------|-------|-------------|----------| -------|-------|
| [libfm](https://github.com/srendle/libfm) | C++11 | 5min | 73% | 命令行，支持模型保存和载入 | 基于paper的实现，支持SGD, SGDA, ALS和MCMC |
| [pywFM](https://github.com/jfloff/pywFM) | python  | 5min | 同上 | 类sklearn接口，支持模型保存和载入 | python封装的libfm |
| [alphaFM](http://geek.csdn.net/news/detail/112231) | C++11 | 2min | 71% | 命令行，支持模型保存和载入 | 支持多线程，基于FTRL算法实现 |
| [fastFM](https://github.com/ibayer/fastFM) | python，c | 8min | sgd:61% als:73% mcmc:76%| 类sklearn接口，mcmc不支持模型保存载入 | SGD, ALS和MCMC |
| [pyFM](https://github.com/coreylynch/pyFM) | python，c | 大数据量无法计算 | 无 | 类sklearn接口，支持模型保存和载入 | 基于SGDA算法实现 |
| [Factorization Machines with libFM (Python/TensorFlow)](https://github.com/geffy/tffm/tree/master/tffm)| python  | 未测试 | | |
| [spark-libFM](https://github.com/zhengruifeng/spark-libFM) | scala | 未测试 | | |
| [DiFacto](https://github.com/dmlc/difacto) | c++ | 未测试 | | |

## FFM

FM有一个衍生算法FFM（Field-aware FM），大概思路是将特征进行分组，学习出更多的隐式向量V，FM可以看做FFM只有一个分组的特例。FFM复杂度比较高，比较适合高度稀疏数据；而FM可以应用于非稀疏数据，更加通用。

参考：
[libfm使用文档](http://www.libfm.org/libfm-1.42.manual.pdf)
[libfm中文翻译](http://d0evi1.com/libfm/)
[fastFM文档](http://ibayer.github.io/fastFM/guide.html)
[FM算法和fastFM包的使用介绍](http://www.tk4479.net/jiangda_0_0/article/details/77510029)
[FM, FTRL, Softmax](http://castellanzhang.github.io/2016/10/16/fm_ftrl_softmax/)
[老外的测试结果](https://github.com/arogozhnikov/arogozhnikov.github.io/blob/master/notebooks/2016-02-15-TestingLibFM.ipynb)
[美团fm](https://tech.meituan.com/deep-understanding-of-ffm-principles-and-practices.html)

