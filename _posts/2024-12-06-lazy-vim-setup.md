---
title: lazy vim setup 接口问题
description: lazy vim对插件的对接问题
date: 2024-12-06 12:00:00 +0800
categories: [problem, application]
tags: [neovim,lazyvim]
author: paclarz
---

## 问题来源

lazyvim的工程结构十分规范优美，每个插件使用一个文件进行配置。但是colorscheme不是平凡的插件，依赖等级较高，导致配置起来比较麻烦。

## 问题描述

#### plugins文件

这个文件是plugins的范例，我们可以在[官网](https://lazy.folke.io/spec/examples)看到规范的描述

``` lua

return {
  -- the colorscheme should be available when starting Neovim
  {
    "folke/tokyonight.nvim",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      -- load the colorscheme here
      vim.cmd([[colorscheme tokyonight]])
    end,
  },

 ...

  {
    "dstein64/vim-startuptime",
    -- lazy-load on a command
    cmd = "StartupTime",
    -- init is called during startup. Configuration for vim plugins typically should be set in an init function
    init = function()
      vim.g.startuptime_tries = 10
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    -- load cmp on InsertEnter
    event = "InsertEnter",
    -- these dependencies will only be loaded when cmp loads
    -- dependencies are always lazy-loaded unless specified otherwise
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
    },
    config = function()
      -- ...
    end,
  },

 ...

}

```

这里是最规范的文件，同时是后文中最有可能方案的来源。
这里展示的代码是后续内容的基础，暂时不深入。


#### init文件


这个文件是lazyvim的启动文件，在[官网](https://www.lazyvim.org/configuration/lazy.nvim)同样有详细描述


``` lua
...
require("lazy").setup({
  spec = {
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- import/override with your plugins
    { import = "plugins" },
  },
  ...
  install = { colorscheme = { "tokyonight", "habamax" } },
  ...
})

```

我们可以看到，colorscheme被单独配置，但是放在一个很匪夷所思的install下，大概率是插件名字。

#### cappucin官方配置

cappucin的配置就是问题的根源，出现了setup，可以参考[doc](https://github.com/catppuccin/nvim)

``` lua
require("catppuccin").setup({
    flavour = "auto", -- latte, frappe, macchiato, mocha
    background = { -- :h background
        light = "latte",
        dark = "mocha",
    },
    transparent_background = false, -- disables setting the background color.

    ...

})

``` 

虽然这个setup多半来自于neovim官方

这里只截取一点就好了，可以看到一个flavor，剩下都是自定义配色的配置。

## 三种usage 

基于以上的信息，总结出三种接口：

1. init文件中`install`属性里配置
2. LazyVim插件中引入colorscheme并配置
3. cappucin插件属性内部的配置，包括`config`, `opts`等

这些可能的接口存在各种组合，内部各种写法，纷繁复杂

#### youtub教程

优质的指导视频从零开始配置[Lazyvim](https://www.youtube.com/watch?v=S-xzYgTLVJE&list=PLsz00TDipIffreIaUNk64KxTIkQaGguqn&index=3)

这里指导的config内部调用require，是最终的暂行方案，私以为不规范，但暂无其他跑通方案。

``` lua

return {
    "catppuccin/nvim",
    lazy = false,
    name = "catppuccin",
    priority = 1000,

    opts = custom_opts, -- 无效

    config = function()

      require("catppuccin").setup({ -- succ
          flavour = "latte" -- latte, frappe, macchiato 
      })
      vim.cmd.colorscheme "catppuccin"

    end
}


```


#### 暂行解决方案

这里在上一个基础上拓展，传入自定义配色成功跑通

``` lua

return {
    "catppuccin/nvim",
    lazy = false,
    name = "catppuccin",
    priority = 1000,

    opts = custom_opts, -- 无效

    config = function()

  require("catppuccin").setup({ -- succ
      flavour = "latte" -- latte, frappe, macchiato 
  })
  vim.cmd.colorscheme "catppuccin"


        require("catppuccin").setup(custom_opts)
        -- vim.cmd.colorscheme "catppuccin"
        vim.cmd([[colorscheme catppuccin]])

    end
}


```


#### cappucin官方

可以在官方文档[官方文档](https://github.com/catppuccin/nvim)中看到usage

``` lua
colorscheme catppuccin 
-- catppuccin-latte, catppuccin-frappe, catppuccin-macchiato, catppuccin-mocha
vim.cmd.colorscheme "catppuccin"
```

实际上，这个也需要像暂行解决方案中放到config函数中，没有指导配置项

#### cappucin社区的Lazyvim

来自[cappucin社区](https://github.com/cappuccin/nvim)的lazyvim的[配置](https://github.com/nullchilly/CatNvim/blob/64cd8694d738a608e371acecbb8e391d3ce6c4fc/lua/plugins/colorscheme.lua)

同时应用了lazyvim插件和opts选项，应当是规范的，但是其他可行方法都不适应opts配置项

``` lua

return {
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = function()
				require("catppuccin").load()
			end,
		},
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		opts = {
			no_italic = true,
			term_colors = true,
			transparent_background = false,
    ...
		},
	},
}

```

属于一个全新的入口，但也实在疲于探索了




## 主要研究


``` lua

-- 全自定义的配置，原版没有flavour配置
local custom_opts = {
    no_italic = true,
    term_colors = true,
    transparent_background = false
    ...
}

return {
    "catppuccin/nvim",
    lazy = false,
    name = "catppuccin",
    priority = 1000,

    -- spec 无效
    -- spec = {  
    -- flavour = "frappe", -- latte, frappe, macchiato, mocha
    -- },

    -- opts 无效
    -- opts = { 
    --     flavour = "latte", -- latte, frappe, macchiato, mocha 
    -- },
    
    -- 同样的opts 无效
    -- opts = custom_opts,

    -- init 必须是函数 无效
    -- init = function() 
    --     return  { flavour = "latte" }
    -- end,



    config = function()

        -- 组合一
        require("catppuccin").setup({ -- succ
            flavour = "latte" -- latte, frappe, macchiato 
        })
        vim.cmd.colorscheme "catppuccin"

        -- 组合二
        -- vim.cmd([[colorscheme catppuccin-latte]]) 

        -- 组合三，类似组合一
        -- require("catppuccin").setup(custom_opts)
        -- vim.cmd.colorscheme "catppuccin"

    end
}

```

这些尝试基本锁定了opts，并排出了其他配置项。

## 暂时的结论

1. opts是最有可能的正确传入方案，暂未证实
2. init文件中的install确实可以让插件在lazy之前被加载，应该不会影响是否能够实现
> 在init文件中的配置是确实生效的，体现在如果lazyvim要安装新的插件，会先更新外观，还是安装完成后再更新外观
3. Lazy和Lazyvim插件的关系有待研究，也就是下方的报错原因有待研究以解决此问题
4. config内调用require是正确的,setup函数传入运行正常
5. vim.cmd的两种写法都可行，传入catppuccin-latte和catppuccin都可以

## 最有可能的正确方案

``` lua
return {"LazyVim/LazyVim", opts = {colorscheme = "catppuccin"}}
```

这个插件导致如下报错

``` bash

Failed loading lazyvim.config.keymaps

...ocal/share/nvim/lazy/LazyVim/lua/lazyvim/util/format.lua:182: attempt to index global 'Snacks' (a nil value)

# stacktrace:
  - /LazyVim/lua/lazyvim/util/format.lua:182 _in_ **snacks_toggle**
  - /LazyVim/lua/lazyvim/config/keymaps.lua:123
  - /LazyVim/lua/lazyvim/config/init.lua:252
  - /LazyVim/lua/lazyvim/config/init.lua:251 _in_ **_load**
  - /LazyVim/lua/lazyvim/config/init.lua:259 _in_ **load**
  - /LazyVim/lua/lazyvim/config/init.lua:185

```

