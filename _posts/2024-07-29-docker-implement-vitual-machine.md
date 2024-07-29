---
title: docker使用容器研究虚拟机的实现方法
description: 不使用dockerfile，达到在终端中运行docker容器的效果。
date: 2024-07-29 12:00:00
categories: [problem, devtool]
tags: [docker, virtual machine]
---

## 问题描述

docker 具备替代虚拟机的能力，但是各种教程指南都知道使用 dockerfile 等方法创建容器，使用 docker 分层缓存的机制。
这种传统的方法，会使得容器不方便管理（一般会专注于 dockerfile），命名混乱和占用大量空间（分层缓存机制导致）。
本文通过 docker 的`run`,`exec`等命令的使用方法研究，深入实现如何使用 docker 达到虚拟机的效果，即：

- 创建后命名，可以自由停止和再启动
- 虚拟机（容器）唯一，不分层，方便管理
- 不使用容器以外的其他依赖（如 dockerfile）
- 导出和导入镜像文件，方便分享

## 前置知识

### docker run

- _-i_ : 交互模式，可以输入命令
- _-t_ : 终端模式，可以看到命令执行结果
- _-d_ : 后台模式，容器在后台运行
- _--name_ : 容器名称，可以自定义
- _--rm_ : 容器退出后自动删除

### docker exec

- _-it_ : 与`docker run`命令相同

## 实现方法

```bash
# 创建容器
docker run -it --name ubuntu_bash_1 ubuntu:22.04 bash

# 启动容器
docker start ubuntu_bash_1

# 进入容器
docker attach ubuntu_bash_1
```
