---
title: node内存泄漏
date: 2021-01-13 21:01:05
permalink: /pages/ea4df0/
categories:
  - 前端
  - 前端BUG
tags:
  - 
---
# Ineffective mark-compacts near heap limit Allocation failed - JavaScript heap out of memory

## 问题场景

vuepress 博客，自动化打包部署时出现的问题，因为之前打包部署的时候是没有遇到这种问题的，一开始，我还以为是自己github action 还有语言评论等插件等原因导致的问题，发现分析的方向不太对。后来根据报错信息:

![image-20210113210726159](https://gitee.com/claa/tuci/raw/master/img/image-20210113210726159.png)

```js
FATAL ERROR: Ineffective mark-compacts near heap limit Allocation failed - JavaScript heap out of memory

<--- Last few GCs --->

[2946:0x32c08c0]   255802 ms: Mark-sweep 1355.5 (1423.2) -> 1355.3 (1423.8) MB, 1247.9 / 0.0 ms  (average mu = 0.144, current mu = 0.054) allocation failure GC in old space requested
[2946:0x32c08c0]   256928 ms: Mark-sweep 1355.3 (1423.8) -> 1355.3 (1424.2) MB, 1125.7 / 0.0 ms  (average mu = 0.076, current mu = 0.000) allocation failure GC in old space requested


<--- JS stacktrace --->

==== JS stack trace =========================================

    0: ExitFrame [pc: 0x345cf3dbf1d]
    1: InternalFrame [pc: 0x345cf39232c]
    2: arguments adaptor frame: 1->0
Security context: 0x0ac12c89e6c1 <JSObject>
    3: _render [0x321e18603431] [/home/runner/work/vuepress-theme-vdoing/vuepress-theme-vdoing/node_modules/vue/dist/vue.runtime.common.dev.js:~3514] [pc=0x345d1d5a408](this=0x300a94e15a11 <VueComponent map = 0x3061e4f3e951>)
    4: renderComponent(aka renderComponent) [0x36cef92fda...
```



## 解决方案

根据报错信息，就是JavaScript heap out of memory 内存泄漏，是因为node 在打包时导致的问题，用搜索引擎查询了一下，需要调整一下下面两个文件。

文件的位置：

![image-20210113211320441](https://gitee.com/claa/tuci/raw/master/img/image-20210113211320441.png)

**将 --max-old-space-size=8000    改为   --max-old-space-size=32768**

**npm.cmd**

```js
@IF EXIST "%~dp0\node.exe" (
  "%~dp0\node.exe --max-old-space-size=32768"  "%~dp0\..\npm\bin\npm-cli.js" %*
) ELSE (
  @SETLOCAL
  @SET PATHEXT=%PATHEXT:;.JS;=;%
  node --max-old-space-size=32768  "%~dp0\..\npm\bin\npm-cli.js" %*
```



**webpack.cmd**

```js
@IF EXIST "%~dp0\node.exe" (
  "%~dp0\node.exe --max-old-space-size=32768"  "%~dp0\..\webpack\bin\webpack.js" %*
) ELSE (
  @SETLOCAL
  @SET PATHEXT=%PATHEXT:;.JS;=;%
  node --max-old-space-size=32768  "%~dp0\..\webpack\bin\webpack.js" %*
)
```

**打包成功**

![image-20210113211828688](https://gitee.com/claa/tuci/raw/master/img/image-20210113211828688.png)

