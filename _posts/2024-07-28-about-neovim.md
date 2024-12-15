---
title: Neovim
description: 使用Docker搭建Neovim开发环境.
date: 2024-07-28 12:00:00 +0800
categories: [Record]
tags: [neovim, docker]
author: paclarz
---

## 前言

我数年前就尝试研究 vim，到 neovim，lazyvim，到现在的 astro-nvim。

实话讲，归根结底是想要学习 lsp 等语言服务器的重要技术。奈何相对比较复杂，又有 vscode（几乎就这一个）的包装简单，和 nvim 的高度复杂一对比，就使人很容易呆在舒适区里了。因此，此事需要坚定目标，和耐心。

在各个 neovim 的发行版中，最终选择应当使用 lazyvim。因为这个插件本身几乎是必须的，懒加载功能和包管理功能几乎是一切的基础。约等于官方版本


## 研究环境

使用docker作为开发环境


```Dockerfile
FROM ubuntu:22.04

RUN sed -i 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list  

RUN apt update 

RUN apt upgrade -y

RUN apt install -y curl git 
RUN apt install -y curl build-essential 

RUN apt install -y curl ripgrep fd-find

ENV PATH="/root/app/node20/bin:/root/app/nvim/bin:${PATH}"


WORKDIR /root

```

使用docker-compose启动容器

```yaml
services:
  ubuntu_service:
    build: . # 从当前目录构建 Docker 镜像
    container_name: neovim_container_1
    volumes:
      - ./mount:/root # 将当前目录下的 mount 文件夹挂载到容器的 /root 文件夹
    entrypoint: /bin/bash -c "exec bash"
    tty: true
    stdin_open: true
```

运行 `docker-compose up` 启动容器

## 工程结构

此处位于docker容器内，用户根目录的`.config`文件下

```
\---nvim
    |   init.lua                        ---入口文件
        ...
    |
    \---lua
        +---config                      ---全局、lazy配置，启动文件夹
        |       lazy.lua
        |       nvim.lua
        |       setup.lua
        |
        \---plugins
                catppuccin.lua          ---插件文件夹
                lsp.lua
                ...
```

## TODOs


> 3rd Dec. 2024

* git两次合并问题：之前已经合并过的文件如何重新合并