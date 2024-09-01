---
title: docker 环境变量问题
description: 在使用dockerfile配置环境变量遇到的问题和完美的docker-jekyll开发环境。
date: 2024-09-01
categories: [problem]
tags: [docker]
author: paclarz
image:
  path: /assets/img/blogs/2024-08-30-docker-path/docker-jekyll-dev-env.png
  alt: "docker-jekyll开发环境"
---

### 背景描述

docker-jekyll 有疑似官方的开发环境，但是貌似缺乏维护，而且使用时会莫名其妙报错，且不透明而缺少文档。在此使用自己开发的 docker 镜像，并主要遇到了一个大 docker 问题。

### 问题描述

常规的环境变量是使用类似`~/.bashrc`或`~/.zshrc`文件进行配置的，而在 docker 中，这遇到了诸多限制。

- 每个`RUN`命令为了便于分层，都会在容器内创建一个新的进程，因此环境变量的设置只对当前进程有效。

- 使用`source`命令，包括`RUN source ~/.bashrc && other_command`，`CMD`，`RUN bash -c "command_file.sh"`都没有成功。这些内容会在后文部分说明。

- 关于`SHELL`命令，只能用于指定默认 shell，而不能用于设置环境变量，例如`source`。

接下来进行尝试过程的内容进行部分记录。

### 问题复现

#### 初始 dockerfile

```Dockerfile

FROM ubuntu:22.04

# 配置清华源
RUN sed -i 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list && \
    sed -i 's/security.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list

RUN apt update

# 安装基本依赖
RUN apt-get install -y \
    git \
    build-essential \
    python3 \
    nodejs

RUN apt install -y \
    libz-dev libssl-dev libffi-dev libyaml-dev

# 安装ruby版本管理工具rbenv
RUN apt install -y  rbenv

RUN  git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build

RUN  echo 'eval "$(rbenv init -)"' >> ~/.bashrc

# 安装ruby
RUN  rbenv install 3.2.5

RUN  rbenv global 3.2.5

# 安装bundler
RUN apt install -y bundler

EXPOSE 4000
WORKDIR /app

# # 测试模板
RUN git clone https://github.com/cotes2020/chirpy-starter.git
WORKDIR /app/chirpy-starter
# # 开发模板，使用watch和copy将源代码复制到此处
# WORKDIR /app/jekyll

# 安装依赖 ------------------ 问题所在
RUN bundle

# # 调试命令
CMD ["tail", "-f", "/dev/null"]

# #启动命令
# CMD bundle exec jekyll s --host 0.0.0.0

```

如上所示，`RUN bundle`会出现严重问题

```powershell

 => ERROR [jekyll-docker-3 15/15] RUN bundle                     7.4s
------
 > [jekyll-docker-3 15/15] RUN bundle:
0.395 Don't run Bundler as root. Bundler can ask for sudo if it is needed, and
0.395 installing your bundle as root will break this application for all non-root
0.395 users on this machine.
3.317 Fetching gem metadata from https://rubygems.org/...........
7.353 Resolving dependencies...
7.365 Bundler found conflicting requirements for the Ruby version:
7.365   In Gemfile:
7.365     Ruby
7.365
7.365     html-proofer (~> 5.0) was resolved to 5.0.9, which depends on
7.365       Ruby (< 4.0, >= 3.1)
------
failed to solve: process "/bin/sh -c bundle" did not complete successfully: exit code: 6
```

报错内容很简单，ruby 版本不正确，但是已经明确安装了 global 的 3.2.5。

#### 错误分析

首先，注释掉 bundle，并进入容器来进行 debug

```powershell
# bash
root@8fe2a148f6e2:/app/chirpy-starter# ruby -v
ruby 3.2.5 (2024-07-26 revision 31d0f1a2e7) [x86_64-linux]
root@8fe2a148f6e2:/app/chirpy-starter# ls
Gemfile  LICENSE  README.md  _config.yml  _data  _plugins  _posts  _tabs  assets  index.html  tools
root@8fe2a148f6e2:/app/chirpy-starter# bundle
Don't run Bundler as root. Installing your bundle as root will break this application for all non-root users on this machine.
Fetching gem metadata from https://rubygems.org/...........
Resolving dependencies...
Fetching rake 13.2.1
Installing rake 13.2.1
Fetching concurrent-ruby 1.3.4
...

```

非常恶心且出乎意料的，无需任何操作直接就是正常的
这也正是这个问题的恶心所在

#### 其他特征

在进行本文的记录前，作者进行了大量的尝试，且与后文中默认 shell 等问题交叉，在此不再进行更多的复现，凭借记忆，此问题还有以下这些特征：

- source 命令无法跨越 RUN 命令
- source 命令无法跨越&&符号（bash -c）
- 环境变量输出到文件时`echo $PATH > file`，一直保持最原始的状态，无法改变
- rbenv 命令输出正常
- `which ruby`命令一直异常，无论 source 前后，即不是 rbenv 软件下载的新版 ruby

### 解决方案（应该非最优）

#### 获取完整的环境变量

> RUN echo $(rbenv init -) >> ./rbenvpath.txt

得到结果（手动格式化）：

```powershell

# 设置环境变量
export PATH="/root/.rbenv/shims:${PATH}"
export RBENV_SHELL=sh

# 初始化 rbenv
command rbenv rehash 2>/dev/null

rbenv() {
    local command
    command="${1:-}"
    if [ "$#" -gt 0 ]; then
        shift
    fi
    case "$command" in
        rehash|shell)
            eval "$(rbenv "sh-$command" "$@")"
            ;;
        *)
            command rbenv "$command" "$@"
            ;;
    esac
}

```

由此看来，有用的部分就是设置了一个新 path，外加另外的一个意义不明的环境变量。
那么洁癖患者自然选择只追加这一个 path 而已。

p.s.使用 GPT 时，生成的内容会额外增加一个 bin，但是经过容器内检测，并无这个文件夹存在

```powershell
# ls -a
.  ..  plugins  shims  version  versions
```

而且在运行 bundle 安装依赖前后文件夹格式完全一样
因此更加坚定的只添加`/root/.rbenv/shims`

#### 解决问题

```Dockerfile


FROM ubuntu:22.04

# 配置清华源
RUN sed -i 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list && \
    sed -i 's/security.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list

RUN apt update

# 安装基本依赖
RUN apt-get install -y \
    git \
    build-essential \
    python3 \
    nodejs

RUN apt install -y \
    libz-dev libssl-dev libffi-dev libyaml-dev

# 安装ruby版本管理工具rbenv
RUN apt install -y  rbenv

RUN  git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build

RUN  echo 'eval "$(rbenv init -)"' >> ~/.bashrc

# 安装ruby并配置环境变量
RUN  rbenv install 3.2.5
RUN  rbenv global 3.2.5
ENV PATH /root/.rbenv/shims:$PATH

# 安装bundler
RUN apt install -y bundler

EXPOSE 4000
WORKDIR /app

# 测试模板

RUN git clone https://github.com/cotes2020/chirpy-starter.git
WORKDIR /app/chirpy-starter

# 安装依赖
RUN bundle

# # 开发模板
# WORKDIR /app/jekyll

# 测试命苦
# CMD ["tail", "-f", "/dev/null"]
# 启动服务
CMD bundle exec jekyll serve --host 0.0.0.0

```

{: file='docker-compose.yml'}

```yaml
services:
  jekyll-docker-3:
    build: .
    container_name: jekyll-docker-3
    ports:
      - "4000:4000"
    restart: unless-stopped
    develop:
      watch:
        - action: sync
          path: ./
          target: /app/jekyll
```

使用`docker-compose up`启动容器，并在浏览器中访问`http://localhost:4000`

### 其他问题

#### 关于 bash 和 sh

docekrfile 中的`SHELL`命令只能用于指定默认 shell。
ubuntu 中自带两种 shell，存在暴力替换的方法

```Dockerfile

# 使用性能更好的bash
SHELL ["/bin/bash", "-c"]

# 默认
SHELL ["/bin/sh", "-c"]

# 强行替换
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

```

除了这些文档中提到的基础知识，有问题如下：

1. 在终端使用 exec 进入，和在 dockerdesktop 进入，情况分别如何
2. 在 SHELL 命令之后追加`source ~/.bashrc`是否会生效？

接下来依次解答

##### exec 命令

```powershell
➜ docker exec -it 600e46a7cf5f bash
root@600e46a7cf5f:/app/chirpy-starter# echo $PATH
/root/.rbenv/shims:/root/.rbenv/shims:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
root@600e46a7cf5f:/app/chirpy-starter# exit
exit

➜ docker exec -it 600e46a7cf5f sh
# ls
Gemfile  Gemfile.lock  LICENSE  README.md  _config.yml  _data  _plugins  _posts  _site  _tabs  assets  index.html  tools
# echo $PATH
/root/.rbenv/shims:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
#
```

如上所述，使用 exec 进入，需要是定 bash 或者 sh 命令。也显然，bash 会自动 source ~/.bashrc，而 sh 不会。因而前者的$PATH 内涵两条 rbenv 路径，后者只有一条。

##### 强行删除替换方法

此方法有效，但强烈不建议，因为会导致系统的其他部分也发生变化，导致不可预测的后果，在此不做复现。
主要影响为通过 docker desktop 进入时会自动得到类似 bash 的效果。

##### 追加 source 命令

此问题非常奇怪，奇怪到使人直接放弃。虽然在 docker 文档中解释的时，SHELL 用于对 RUN 等指令的翻译，以达到分层的目的，理论上应该能够实现 source

```Dockerfile

# 追加 source 命令
SHELL ["/bin/bash", "-c", "source ~/.bashrc"]

RUN echo $PATH
```

```powershell

# 理论上的翻译结果
bash -c "source ~/.bashrc && echo $PATH"
```

但是实际上，并没有生效，甚至没有报错，而是很匪夷所思的，让`git clone`命令无法正常执行，使得目标文件夹为空。因惊愕此二者的联系，出于后怕而立即放弃此方向。

### jekyll 文件冲突问题

在新版的 dockerfile 中仍然存在一种报错

```powershell
jekyll-docker-3  |       Generating...
jekyll-docker-3  |           Conflict: The following destination is shared by multiple files.
jekyll-docker-3  |                     The written file may end up with unexpected contents.
jekyll-docker-3  |                      - assets/img/favicons/site.webmanifest
jekyll-docker-3  |                      - /app/jekyll/assets/img/favicons/site.webmanifest


```

这个报错意义比较明确，同一个文件有两个来源。此文件是在 icon 生成网站上生成 icon 的套装之二，删除（此处移动到 backup 文件夹下了）就能解决

至此我们得到了完美无效的 jekyll-docker 开发环境

### 完整应用

在完成开发后，可以不再使用 dockerhub 上疑似缺乏维护的 jekyll 镜像，使用自己的 dockerfile 和 docker-compose.yml 文件，构建自己的镜像。

```powershell
# 启动容器
docker compose up --build --watch
```

这样，每次修改代码，都会自动重启容器，并自动更新网站内容。

docker-compose.yml 文档如上方所示，此处展现完整的 dockerfile

```Dockerfile


FROM ubuntu:22.04

# 配置清华源
RUN sed -i 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list && \
    sed -i 's/security.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list

RUN apt update

# 安装基本依赖
RUN apt-get install -y \
    git \
    build-essential \
    python3 \
    nodejs

RUN apt install -y \
    libz-dev libssl-dev libffi-dev libyaml-dev

# 安装ruby版本管理工具rbenv
RUN apt install -y  rbenv

RUN  git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build

RUN  echo 'eval "$(rbenv init -)"' >> ~/.bashrc

# 安装ruby并配置环境变量
RUN  rbenv install 3.2.5
RUN  rbenv global 3.2.5
ENV PATH /root/.rbenv/shims:$PATH

# 安装bundler
RUN apt install -y bundler

EXPOSE 4000
WORKDIR /app

# -------------------------------------------------------------- 开发模板

WORKDIR /app/jekyll
COPY Gemfile .
RUN bundle

COPY . .

CMD bundle exec jekyll serve --host 0.0.0.0

# -------------------------------------------------------------- 测试模板

# RUN git clone https://github.com/cotes2020/chirpy-starter.git

# WORKDIR /app/chirpy-starter

# # 安装依赖
# RUN bundle

# # 测试命苦
# # CMD ["tail", "-f", "/dev/null"]
# # 启动服务
# CMD bundle exec jekyll serve --host 0.0.0.0


```
