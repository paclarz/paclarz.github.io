---
title: git upstream
description: git的upstream两种实现方法研究
date: 2024-12-01 12:00:00 +0800
categories: [problem, fundamental]
tags: [git]
author: paclarz
---

## 问题来源

在研究本博客的时候，发现上游的代码有更新，但是最初clone本仓库的时候没有设置，只是一个纯粹的main分支，不方便更新合并代码，于是便开始研究。
在网上查找解决办法的时候，很容易就搜索到了`upstream`这个单词，也很容易就发现了这是一个配置项。但是在一定的研究后，发现这两个选项：

1. 配置main分支的上游分支
2. 将上游分支拉取到本地作为一个和main分支平行的分支

并没有很明显的优势。而且，看似不够规范的方法二反而有更加清晰的博客文章。

于是便开始研究如何配置这两个选项，都实现一下。

p.s.这个问题应该挺基础的，但是中文互联网上没有很显然的教程，lol。

## 两种解决方案



### 方法一：平级分支

首先是不太标准的方法一，配置一个平行的分支来存储上游代码。


1. 简单新增一个upstream仓库,并拉取相关代码

```bash
➜ git remote add upstream git@github.com:cotes2020/chirpy-starter.git

➜ git remote -v
origin  git@github.com:paclarz/paclarz.github.io.git (fetch)
origin  git@github.com:paclarz/paclarz.github.io.git (push)
upstream        git@github.com:cotes2020/chirpy-starter.git (fetch)
upstream        git@github.com:cotes2020/chirpy-starter.git (push)

➜ git fetch upstream
remote: Enumerating objects: 485, done.
remote: Counting objects: 100% (108/108), done.
remote: Compressing objects: 100% (62/62), done.
remote: Total 485 (delta 64), reused 72 (delta 45), pack-reused 377 (from 1)
Receiving objects: 100% (485/485), 100.40 KiB | 237.00 KiB/s, done.
Resolving deltas: 100% (232/232), done.
From github.com:cotes2020/chirpy-starter
 * [new branch]      main       -> upstream/main
 * [new tag]         v7.2.2     -> v7.2.2
 * [new tag]         v3.1.0     -> v3.1.0
 * [new tag]         v3.2.0     -> v3.2.0
 * [new tag]         v3.3.0     -> v3.3.0
 * [new tag]         v4.0.0     -> v4.0.0

......

 * [new tag]         v7.1.0     -> v7.1.0
 * [new tag]         v7.1.1     -> v7.1.1
 * [new tag]         v7.2.1     -> v7.2.1


```

> `TODO` 这里的tag同样也是一个知识点 

2. 创建并切换到upstream_main分支,并切换到v7.2.1准备合并

```bash

➜ git checkout upstream upstream     
error: pathspec 'upstream' did not match any file(s) known to git
error: pathspec 'upstream' did not match any file(s) known to git

➜ git checkout -b upstream_main upstream/main
branch 'upstream_main' set up to track 'upstream/main'.
Switched to a new branch 'upstream_main'

➜ git log
commit aa0fd48ad0de60984ecdd04961d931c490d2b80a (HEAD -> upstream_main, tag: v7.2.2, upstream
Date:   Fri Dec 6 17:07:40 2024 +0000

    Update critical file(s) according to Chirpy v7.2.2

Author: GitHub Actions <github-actions[bot]@users.noreply.github.com>
Date:   Thu Dec 5 13:34:44 2024 +0000


commit 59ad287fb0144fd9a3e1b46826a18fdce42646d1 (tag: v7.2.0)
Author: GitHub Actions <github-actions[bot]@users.noreply.github.com>
Date:   Thu Nov 28 09:00:29 2024 +0000
    Update critical file(s) according to Chirpy v7.2.0

➜ git reset v7.2.1 

```

3. 回到main分支，合并upstream_main分支

```bash

➜ git checkout main
Switched to branch 'main'
Your branch is up to date with 'origin/main'.

➜ git merge upstream_main
fatal: refusing to merge unrelated histories

➜ git merge upstream_main --allow-unrelated-histories
CONFLICT (add/add): Merge conflict in .gitignore
Auto-merging .vscode/settings.json
CONFLICT (add/add): Merge conflict in .vscode/settings.json
Auto-merging Gemfile
CONFLICT (add/add): Merge conflict in Gemfile
Auto-merging README.md
CONFLICT (add/add): Merge conflict in README.md
Auto-merging _config.yml
CONFLICT (add/add): Merge conflict in _config.yml
......

```

4. 解决冲突，提交代码

### 方法二：配置main分支的上游分支

1. 按照上一节的方法，配置upstream仓库，并拉取相关代码，达到如下效果
```bash

➜ git branch -vv
* main          f3a7d3f [origin/main: ahead 69] correct merge
  upstream_main 333ce46 [upstream/main: behind 1] Update critical file(s) according to Chirpy v7.2.1

```

p.s. 这里的`ahead`和`behind`表示当前分支和上游分支的差异，`ahead`表示当前分支比上游分支多，`behind`表示当前分支比上游分支少，所以如果全是ahead才是最新。

2. 直接进行合并

```bash

➜ git branch --set-upstream-to=upstream/main main
branch 'main' set up to track 'upstream/main'.

```

这样就配置好了main分支的上游分支，并且可以直接进行合并。

```bash
➜ git merge upstream/main
Auto-merging Gemfile
CONFLICT (content): Merge conflict in Gemfile
Auto-merging _config.yml
Automatic merge failed; fix conflicts and then commit the result.
```

这样我们就没有依赖新的branch也成功进行了合并。

3. 解决冲突，提交代码

## 总结

两种方法都可以实现上游代码的更新，但是方法一不太规范，方法二更加规范。同时没有研究如果想合并上游代码的某一个版本（tag）应该怎么操作。但是应当不是问题。

总的来说，upstream就应当是，不能被本仓库更改，保证代码的稳定，因而不应该被设置成为一个branch。

但由此又导出一个新的问题：已经合并过的操作会被git记忆。如本文中记录的，我第一次通过分支合并时，解决了大量冲突，但第二次合并的时候，已经解决过的冲突没有被再次报出，这有待研究。

## 遗留问题

- tag与哈希值之间的关系，以及如何操作tag和哈希值及分支版本
- 已经解决的冲突想再次进行合并，即，upstream中有一个文件，在之前的一次合并后被解决冲突，但是后来的一次合并，感觉上一次提交的冲突解决不正确，想要把当下的文件，与upstream的文件进行重新比较，如何操作？