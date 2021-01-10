---
title: 使用Gitee Action自动持续集成
date: 2020-11-28 21:58:06
permalink: /pages/df866e/
categories:
  - Java后端
  - 博客搭建
tags:
  - 
---
#  使用Gitee Action自动持续集成

## 背景

目前已经在gitee上搭建好了博客，具体效果如下：

![image-20201128210318655](https://gitee.com/claa/tuci/raw/master/img/image-20201128210318655.png)

<mark>[访问博客](http://claa.gitee.io/vuepress-theme-vdoing/)</mark>

## 问题

博客就像日记一样，会经常记录，所以发布的时候，越简单就越好。

github pages 直接用deploy.sh 脚本部署也挺方便的，不过我的博客是搭建在gitee 上的，这种方法不太适用。我看到开发这个[vuepress-theme-vdoing](https://doc.xugaoyi.com/vuepress-theme-vdoing-doc/) 主题元素的作者是使用的github action 自动集成在自己域名的网页上的.

所以我想采用gitee action 来自动发布gitee pages服务，整体思路就是

先在github 上push 自己的新博客，然后自动打包，然后把包上传到gitee上，再调用gitee action 自动发布gitee pages。

## 两个重要的文件

### ci.yml

```
name: CI

# 在master分支发生push事件时触发。
on: 
  push:
    branches:
      - main
jobs: # 工作流
  build:
    runs-on: ubuntu-latest #运行在虚拟机环境ubuntu-latest

    strategy:
      matrix:
        node-version: [10.x]

    steps: 
      - name: Checkout # 步骤1
        uses: actions/checkout@v1 # 使用的动作。格式：userName/repoName。作用：检出仓库，获取源码。 官方actions库：https://github.com/actions
      - name: Use Node.js ${{ matrix.node-version }} # 步骤2
        uses: actions/setup-node@v1 # 作用：安装nodejs
        with:
          node-version: ${{ matrix.node-version }} # 版本
      - name: run deploy.sh # 步骤3 （同时部署到github和coding）
        env: # 设置环境变量
          GITHUB_TOKEN: ${{ secrets.ACCESS_TOKEN }} # toKen私密变量
        run: npm install && npm run deploy # 执行的命令  
        # package.json 中添加 "deploy": "bash deploy.sh"
       - name: Build Gitee Pages
        uses: yanglbme/gitee-pages-action@main
        with:
          # 注意替换为你的 Gitee 用户名
          gitee-username: claa
          # 注意在 Settings->Secrets 配置 GITEE_PASSWORD
          gitee-password: ${{ secrets.GITEE_PASSWORD }}
          # 注意替换为你的 Gitee 仓库，仓库名严格区分大小写，请准确填写，否则会出错
          gitee-repo: vuepress-theme-vdoing
          # 要部署的分支，默认是 master，若是其他分支，则需要指定（指定的分支必须存在）
          branch: master

```

### deploy.sh

```
#!/usr/bin/env sh

# 确保脚本抛出遇到的错误
set -e

# 生成静态文件
npm run docs:build

# 进入生成的文件夹
cd docs/.vuepress/dist

# deploy to github
if [ -z "$GITHUB_TOKEN" ]; then
  msg='deploy'
  githubUrl=git@github.com:xugaoyi/vuepress-theme-vdoing.git
else
  msg='来自github actions的自动部署'
  githubUrl=https://claa:${GITHUB_TOKEN}@github.com/claa/vuepress-theme-vdoing.git
  git config --global user.name "claa"
  git config --global user.email "736238785@qq.com"
fi
git init
git add .
git commit -m 'deploy'
git remote add origin https://[用户名]:[密码]@gitee.com/claa/vuepress-theme-vdoing.git
git push -u origin master -f
git push -u origin master

#git push -f git@gitee.com:claa/vuepress-theme-vdoing.git master:gh-pages


cd - # 退回开始所在目录
rm -rf docs/.vuepress/dist
```



## 参考文章

[GitHub Actions 实现自动部署静态博客](https://xugaoyi.com/pages/6b9d359ec5aa5019/#%E5%89%8D%E8%A8%80)

 [GitHub Actions 入门教程](http://www.ruanyifeng.com/blog/2019/09/getting-started-with-github-actions.html?20191227113947#comment-last)