---
title: jekyll 重复使用icon配置文件报错问题
description: 本博客开发问题的记录
date: 2024-12-01 12:00:00 +0800
categories: [Problem, jekyll]
tags: [jekyll,unsolved]
author: paclarz
---

#### docker控制台报错问题

> Dec. 3th. 2024

在控制台启动docker后存在一些报错

```
paclarz.github.io  |           Conflict: The following destination is shared by multiple files.
paclarz.github.io  |                     The written file may end up with unexpected contents.
paclarz.github.io  |                     /app/jekyll/_site/assets/img/favicons/browserconfig.xml
paclarz.github.io  |                      - assets/img/favicons/browserconfig.xml
paclarz.github.io  |                      - /app/jekyll/assets/img/favicons/browserconfig.xml
paclarz.github.io  |
paclarz.github.io  |           Conflict: The following destination is shared by multiple files.
paclarz.github.io  |                     The written file may end up with unexpected contents.
paclarz.github.io  |                     /app/jekyll/_site/assets/img/favicons/site.webmanifest
paclarz.github.io  |                      - assets/img/favicons/site.webmanifest
paclarz.github.io  |                      - /app/jekyll/assets/img/favicons/site.webmanifest

```

经查找资料为非jekyll问题
github连接[https://github.com/jekyll/jekyll/issues/8522]
暂时暴力解决方法是，把这几个报错文件进行重命名

```
-a----         2024/12/9     18:04            255 change_browserconfig.xml
-a----         2024/12/9     18:04           1393 change_site.webmanifest

```

原版删除`\paclarz.github.io\assets\img\favicons\`下文件的开头的`change_`即可。


