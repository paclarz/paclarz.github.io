---
title: javascript import export 问题
description: javascript import export 问题
date: 2024-12-10 12:00:00 +0800
categories: [problem, language]
tags: [javascript]
author: paclarz
---

## 问题

javascript 文件导入和导出问题

本文为[此博客](https://www.samanthaming.com/tidbits/79-module-cheatsheet/)的中文翻译总结

## 概述

``` javascript
// Name Export | Name Import
export const name = 'value'
import { name } from '...'

// Default Export | Default Import
export default 'value'
import anyName from '...'

// Rename Export | NameImport
export { name as newName }
import { newName } from '...'

// Name + Default | Import All
export const name = 'value'
export default 'value'
import * as anyName from '...'

// Export List + Rename | Import List + Rename
export {
  name1,
  name2 as newName2
}
import {
  name1 as newName1,
  newName2
} from '...'

```

## 详细说明

#### 命名导入

```javascript

// export
export const name = 'value';

// import
import { name } from 'some-path/file';

```

#### 默认导入

```javascript

// export
export default 'value'
 
// import
import anyName from 'some-path/file';
 
```

#### 混合导入

```javascript

// export
export const name = 'value';
export default 'value'

// import    
import anyName, { name } from 'some-path/file';

```

#### 列表导入

```javascript

// export
const name1 = 'value1';
const name2 = 'value2';

export {
  name1,
  name2
}
 
// import
import {
  name1,
  name2
} from 'some-path/file'
 
```

注意，不要在此处使用object的性质，本质上这个导入后是个List，不是object。

#### 重命名

```javascript

// export
const name1 = 'value1';
const name2 = 'value2';

export {
  name1,
  name2 as newName2
}
 
 
// import
import {
  name1 as newName1,
  newName2
} from '...'

console.log(newName1); // 'value1'
console.log(newName2); // 'value2'

name1; // undefined
name2; // undefined

```

#### 导入所有

```javascript

// export
export const name = 'value';
export default 'defaultValue';
 
 
// import
import * as anyName from 'some-path/file';

console.log(anyName.name); // 'value'
console.log(anyName.default); // 'defaultValue'
 
 
```

注意，ES6模块的导入导出没有在这里总结


![cheatsheet](/assets/img/blogs/2024-12-10-javascript-import/js_import_cheatsheet.png){: width="300" height="300" }
_Javascript import export cheatsheet_