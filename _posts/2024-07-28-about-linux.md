---
title: Linux 
description: 一些linux基础的app使用
date: 2024-07-28 12:00:00 +0800
categories: [Record]
tags: [linux, app]
author: paclarz
---

## 前言

## TODOs

- [ ] ubuntu 镜像存在 security，待研究其镜像

## 镜像

### 环境配置

```bash

# 清华源 - 已验证
RUN sed -i 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list  

# 华为云
sudo sed -i "s@//.*archive.ubuntu.com@//mirrors.huaweicloud.com@g" /etc/apt/sources.list.d/ubuntu.sources

# 华为云ports 适用于arm版本
sudo sed -i "s@//.*ports.ubuntu.com@//mirrors.huaweicloud.com@g" /etc/apt/sources.list

```

## TODOs

- [ ] curl文件下载

- [ ] wget

- [ ] 压缩/tar/7zip

