---
title: Docker
description: Docker 相关操作记录
date: 2024-07-28 12:00:00 +0800
categories: [Record]
tags: [docker]
author: paclarz
---

## 前言

docker 貌似仍然算是一个新兴技术

目前比较有把握的是，确实可以取代我的虚拟机需求，不需要复杂的配置和大量的存储空间，速度也是完全的降维打击。但是目前如果在 docker 中开发，甚至都不说使用 vscode 或者 lsp 等高级功能，光是容器内外同步，就有些不是很完美，莫说依赖环境。

因此应当更加深入的研究，更好的使用。

## 基本使用

### 环境配置

```bash
# ubuntu
RUN sed -i 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list  
```

### 拷贝文件

```bash
docker cp \<source\> \<container\>:\<destination\>

# example
docker cp ./README.md my-container:/home/
```

### 配置 Path 文件

1.使用命令

```bash
ENV PATH="/root/app/node20/bin:/root/app/nvim/bin:${PATH}"
```

1. 在容器内部编辑source文件（不规范）

```bash
echo "export PATH=\$PATH:/home/nvim-linux64/bin" >> ./pathFile
echo "export PATH=\$PATH:/home/node-v18.20.4-linux-arm64/bin" >> ./pathFile
source ~/pathFile
```


