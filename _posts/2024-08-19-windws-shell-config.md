---
title: windws shell 配置和美化
description: windows shell 配置和美化
date: 2024-08-19
categories: [record, application]
tags: [windows, shell, config, oh-my-posh]

pin: false
math: true
mermaid: true
image:
  path: /assets/img/blogs/2024-08-19-windws-shell-config/final.png
  alt: "windws shell 配置和美化"
---

## 前言

重装系统后需要重新配置 shell。本文介绍使用 windows terminal 和 oh-my-posh 配置 windows shell 的步骤。

windows terminal 是微软推出的新一代终端，可以替代 cmd 和 powershell，并且可以安装多个不同主题和插件，需要在微软商店下载。

oh-my-posh 是一款 powershell 主题，可以使 powershell 更加美观，本文介绍不使用官方脚本，不污染环境变量的简洁绿色安装方案。如果第一次使用，建议按照官方文档来安装。

## 安装准备

### 安装字体

通俗的办法来讲，普通的字体缺少很多花里胡哨的内容，需要额外自己安装`nerd font` 内涵各种像是 🚀，  之类的内容。

<https://www.nerdfonts.com/>

并自行安装到 windows 系统中。

### 微软商店

如果发现微软商店异常，或者加载太慢，主要有三种可能

- 微软商店没有更新

点击图中，位于 `设置 > 更新和安全` 中,检查更新，等待安装，并重启电脑，如此反复数次，知道没有更新需求，此时 windows 商店应该可以正常使用。

![update windows](/assets/img/blogs/2024-08-19-windws-shell-config/update_windows.png){: width="500" }
_更新微软商店_

- 科学上网没有关闭

猜测微软商店指定从国内数据库获取数据，即使定向到境外服务器会回到国内去获取数据，导致不能下载。需要关闭。

- DNS 不合适

更新 dns 方法网上有很多。注意使用 ping 命令查看延迟选择最适合自己的 dns。
以下是我使用的 dns 的延迟情况：分别是阿里云 dns 和谷歌 dns

```shell
➜ ping 223.5.5.5

正在 Ping 223.5.5.5 具有 32 字节的数据:
来自 223.5.5.5 的回复: 字节=32 时间=9ms TTL=117
来自 223.5.5.5 的回复: 字节=32 时间=9ms TTL=117
来自 223.5.5.5 的回复: 字节=32 时间=9ms TTL=117
来自 223.5.5.5 的回复: 字节=32 时间=9ms TTL=117

223.5.5.5 的 Ping 统计信息:
    数据包: 已发送 = 4，已接收 = 4，丢失 = 0 (0% 丢失)，
往返行程的估计时间(以毫秒为单位):
    最短 = 9ms，最长 = 9ms，平均 = 9ms
➜ ping 8.8.8.8

正在 Ping 8.8.8.8 具有 32 字节的数据:
来自 8.8.8.8 的回复: 字节=32 时间=48ms TTL=52
来自 8.8.8.8 的回复: 字节=32 时间=48ms TTL=52
来自 8.8.8.8 的回复: 字节=32 时间=48ms TTL=52
来自 8.8.8.8 的回复: 字节=32 时间=49ms TTL=52

8.8.8.8 的 Ping 统计信息:
    数据包: 已发送 = 4，已接收 = 4，丢失 = 0 (0% 丢失)，
往返行程的估计时间(以毫秒为单位):
    最短 = 48ms，最长 = 49ms，平均 = 48ms
```

### powershell 的脚本执行权限问题

默认情况下，powershell 脚本的执行权限是禁用的，也就是不能直接运行 ps1 脚本，即使是自己编辑的。需要手动开启。

1. 以管理员身份打开 powershell

![open powershell as admin](/assets/img/blogs/2024-08-19-windws-shell-config/launch_powershell.png){: width="500"}
_以管理员身份打开 powershell_

2. 输入以下命令，开启脚本执行权限

```powershell
Set-ExecutionPolicy RemoteSigned
```

此处附带参数解释：

> - Restricted：这是默认设置，不允许运行任何 PowerShell 脚本。
> - RemoteSigned：允许远程执行脚本，但不允许执行未签名的脚本。
> - AllSigned：允许执行所有已签名的脚本。
> - Restricted：禁止执行所有脚本。

3. 输入以下命令，确认脚本执行权限已开启

```powershell
Get-ExecutionPolicy
```

回显内容如上解释内容。

## 安装 windows terminal

1. 下载 windows terminal

![download windows terminal](/assets/img/blogs/2024-08-19-windws-shell-config/install_wt.png){: width="400" }
_下载 windows terminal_

2. 查看配置文件位置

运行 windows terminal，使用命令`echo $profile`查看配置文件位置。

```

➜ echo $PROFILE
C:\data\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1PowerShell_profile.ps1

```

之后可以使用喜欢的编辑器来编辑这个文件内容。

{: .prompt-info }

> 这个文件以及文件夹可能都不存在，应当一层层创建到指定位置。

3. 测试配置文件

默认文件为空时，之际启动 windows terminal 会有一些默认信息

{: file='powershell'}

```text
Windows PowerShell
版权所有 (C) Microsoft Corporation。保留所有权利。

尝试新的跨平台 PowerShell https://aka.ms/pscore6

PS C:\data\Desktop>
```

非常的朴实无华。

首先可以加一个`clear`来清除这些内容，汽其次可以在此输出一些自己喜欢的内容，以后每次启动终端都会看到。

以下是我的配置文件内容：

```powershell

# 这里就是清屏命令（clear）也可以，但是我的vscode插件建议我使用这个
Clear-Host

# 使得输出内容居中显示
function display_center {
    param (
        [string]$file
    )
    try {
        $columns = [math]::Floor($Host.UI.RawUI.WindowSize.Width / 2)
        $content = Get-Content $file -ErrorAction Stop
        foreach ($line in $content) {
            $padding = $columns - [math]::Floor($line.Length / 2)
            "{0,$padding}{1}" -f ' ', $line
        }
    }
    catch {
        Write-Error "Error processing file: $file. $_"
    }
}

# 调用函数输出一个我外号的字符画
display_center("C:\data\Documents\WindowsPowerShell\myname.txt")
```

输出一些自己喜欢的内容

{: file='C:\data\Documents\WindowsPowerShell\myname.txt'}

```text

	                  _
	                 | |
	 _ __   __ _  ___| | __ _ _ __ ____
	| '_ \ / _` |/ __| |/ _` | '__|_  /
	| |_) | (_| | (__| | (_| | |   / /
	| .__/ \__,_|\___|_|\__,_|_|  /___|
	| |
	|_|

```

## 安装 oh-my-posh

### 基本资料和介绍

- 官方网站 <https://ohmyposh.dev/>

- 官方安装方式
  <https://ohmyposh.dev/docs/installation/windows#installation>
  第一次使用可以安装官方要求来,在 windows 上主要就这俩方式：

```powershell
#使用winget
winget install JanDeDobbeleer.OhMyPosh -s winget

#自动下载powershell脚本并执行安装
Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://ohmyposh.dev/install.ps1'))
```

官方介绍到此为止了，接下来说明我的绿色安装过程。

### 下载可执行文件并配置

1. 在 github 的 releses 页面下载最新版的可执行文件，下载地址为：<https://github.com/JanDeDobbeleer/oh-my-posh/releases>

此处我下载的版本为 `posh-windows-amd64.exe` 虽然是 exe 但是并不是安装文件，可放心使用。

2.将可执行文件放在任意长期存储位置，我的位置是 `"D:\Application\sys_tools\posh\posh-windows-amd64.exe"`

3.在配置文件中添加以下内容

```shell
(@(
    & 'D:\Application\sys_tools\posh\posh-windows-amd64.exe' init pwsh `
        --print
) -join "`n") | Invoke-Expression
```

{: .prompt-warning }

> ps1 脚本，使用反引号为转义符号，末尾的反引号和`\n`类似常见的反斜线转义

此时，排除此文件中可能已有的 clear 或者 echo 命令，当启动 shell 的时候至少已经看到全新的 posh 提示了。

![oh-my-posh init](/assets/img/blogs/2024-08-19-windws-shell-config/init_posh.png){: width="800" }
_oh-my-posh 初始化_

至此，oh-my-posh 安装完成，接下来安装自定义主题。

### 安装自定义主题

1.是下载官方主题包
<https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/v23.6.6/themes.zip>
此链接位于 github releases ， 跟上述 oh-my-posh.exe 并列。

2.选择自己喜欢的主题

下载完成后，解压可以看到一堆名字很长的 json 文件，每个文件对应一个主题。接下来建议到官网去预览，选择自己喜欢的主题。

<https://ohmyposh.dev/docs/themes>

选定后，能够在刚刚解压的安装包中找到名字对应的 json 文件。

![select themes](/assets/img/blogs/2024-08-19-windws-shell-config/select_theme.png){: width="500" }
_选择主题_

3.设置主题配置文件

复制喜欢主题文件全部内容，另存为自己的主题 json 文件，方便自定义修改，也减少对全部主题的大文件夹的依赖。以下是我的配置文件位置和内容：

{: file='C:\data\Documents\WindowsPowerShell\my-theme.json'}

```json
{
  "$schema": "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json",
  "blocks": [
    {
      "alignment": "left",
      "segments": [
        {
          "background": "#f1184c",
          "foreground": "#242424",
          "powerline_symbol": "\ue0c4",
          "style": "powerline",
          "template": "\uf0e7",
          "type": "root"
        },
        //  。。。
        // 此后省略
    }
}
```

4.再次修改 windows terminal 配置文件

```powershell

(@(
    & 'D:\Application\sys_tools\posh\posh-windows-amd64.exe' init pwsh `
        --print `
        # 这一行是新增，指定自定义主题配置文件
        --config='C:\data\Documents\WindowsPowerShell\my-theme.json' `
) -join "`n") | Invoke-Expression

```

5.重启 windows terminal 生效

首先展示完整的 windows terminal 配置文件，至此本文对此文件的全部修改已经完成。
{: file='C:\data\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1'}

```powershell

# 定义剧中输出的函数
function display_center {
    param (
        [string]$file
    )
    try {
        $columns = [math]::Floor($Host.UI.RawUI.WindowSize.Width / 2)
        $content = Get-Content $file -ErrorAction Stop
        foreach ($line in $content) {
            $padding = $columns - [math]::Floor($line.Length / 2)
            "{0,$padding}{1}" -f ' ', $line
        }
    }
    catch {
        Write-Error "Error processing file: $file. $_"
    }
}


# 加载 oh-my-posh
(@(
    & 'D:\Application\sys_tools\posh\posh-windows-amd64.exe' init pwsh `
        --config='C:\data\Documents\WindowsPowerShell\my-theme.json' `
        --print
) -join "`n") | Invoke-Expression

# 清除屏幕
Clear-Host

# 剧中输出文件内容
display_center("C:\data\Documents\WindowsPowerShell\myname.txt")

```

![oh-my-posh done](/assets/img/blogs/2024-08-19-windws-shell-config/posh_done.png){: width="800" }
_oh-my-posh 配置完成_

## 补充

### windows terminal 设置

![windows terminal settings](/assets/img/blogs/2024-08-19-windws-shell-config/entry_of_setting.png){: width="500" }
_windows terminal 设置入口_

进入设置页面，先从左侧导航栏选择 powershell，在在右侧找到`外观`进入子菜单

![windows terminal settings](/assets/img/blogs/2024-08-19-windws-shell-config/setting_1.png){: width="500" }
_windows terminal 设置_

- 字体：选择上述安装的 nerd font 字体
- 背景图片
- 复古效果：会让终端文字有类似荧光的效果，不方便辨认但是好看！
- 其他

### 最终效果

![windows terminal done](/assets/img/blogs/2024-08-19-windws-shell-config/final.png){: width="800" }
_windows terminal 终端效果_
